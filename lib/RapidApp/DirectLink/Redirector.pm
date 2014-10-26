package RapidApp::DirectLink::Redirector;

use strict;
use warnings;
use Moose::Role;

use Try::Tiny;
use Data::Dumper;
use Hash::Merge;
use RapidApp::Error;

=head1 NAME

RapidApp::DirectLink::Redirector

=head1 SYNOPSIS

  package MyController;
  use Moose;
  use namespace::autoclean;
  BEGIN { extends 'Catalyst::Controller'; }
  with 'RapidApp::DirectLink::Redirector';
  
  sub directLink: Path("/DirectLink") {
    my ($self, $c, @args)= @_;
    my $linkUid= $c->req->params->{id};
    my $link= $c->model('DB')->directLink->loadByUid($linkUid);
    $self->dispatchToLink($c, $link);
    - or -
    $self->redirectToLink($c, $link);
  }
  
  # optional custom handling for when a session already exists
  sub directLink_handleAuthDiscrepancy {
    my ($self, $c, $curUser, $newUser)= @_;
    ...
  }
  
  1;
  
=head1 DESCRIPTION

This Moose Role provides the functionality of doing everything needed in order for a user to
get to a RapidApp module.

If the user does not have a session, this module will first create one, using the data in the link,
and then respond to the client with a redirect to come back to the desired URL.

If the user does have a session, this module will check to see whether the same user is being used,
and if not, attempt to dispatch to the specified link as the current user, WITHOUT augmenting the
permissions.  (rationale: switching the user would require killing the active session, which would
lead to all sorts of problems in the other browser window.  Alternatively, augmenting the current
user with the other user's permissions might indicate a violation of security)

Note: we should probably actually redirect to a page explaining that the user should log out first
before following the link.

Some useful things to know regarding this module's interaction with the rest of the system:

Catalyst::Session tries to instantiate a session (deliver a cookie, etc) as soon as you write
something to the "->session" field.  Assuming the user has cookies enabled, you can simply create
the session on the spot and continue to fill the first request.  Or, if you like, you can send a
redirect with the cookie to ensure that the session looks valid after a round trip, before showing
the user anything.

Catalyst::Authentication writes a user object into the session after you call ->authenticate,
assuming it succeeds.  ->authenticate simply passes your hash to a plugin which does something
with that hash to determine whether the login succeeds or fails.  It also runs that hash through
Store plugin, which will find an actual blessed User object based on the hash values.
Calling ->authenticate is currently the only published method for officially initializing a user
into the session.

=head1 METHODS

=cut

=head2 $self->dispatchToLink( $c, $link )

Processes a link's authentication parts, and then dispatches to the target of the link.

Returns a hash containing a 'success' key, and possibly diagnostics.

=cut

sub followLink($$) {
	my ($self, $c, $link)= @_;
	$c->isa('Catalyst') && $link->isa('RapidApp::DirectLink::Link') or die "invalid params";
	
	$self->directLink_handleAuth($c, $link);
	
	my $hashMerge= Hash::Merge->new('LEFT_PRECEDENT');
	
	$c->stash($hashMerge->merge($link->stash || {}, $c->stash));
	$c->session($hashMerge->merge($link->session || {}, $c->session));
	
	if ($link->isRedirect) {
		my $destUri= URI->new($link->targetUrl);
		$c->log->debug('DirectLink URI = '.$destUri->as_string);
		$destUri->query_form($hashMerge->merge($destUri->query_form, $link->requestParams));
		$c->log->info('Redirecting client to '.$destUri->as_string);
		return $c->response->redirect($destUri->as_string);
	}
	else {
		$c->request->parameters($link->requestParams || {});
		my @newArgs= @{$link->targetAction};
		$c->log->info('Re-dispatching with arguments: ('.join(', ',@newArgs).')');
		my $action= shift @newArgs;
		return $c->visit($action, \@newArgs);
	}
}

=head2 $self->directLink_handleAuth( $c, $link )

Returns a hash specifying a boolean 'success' key, and possible diagnostics.

This method handles the creation of a session and user authentication from the auth parameter
of the DirectLink.  The default behavior should fit most situations, but you can override it
for special handling.

=cut
sub _hashToStr {
	my $hash= shift;
	return '{ '.(join ', ', map { $_.'="'.$hash->{$_}.'"' } sort keys %$hash).' }';
};
sub directLink_handleAuth($$) {
	my ($self, $c, $link)= @_;
	
	my $hasUser= $c->session_is_valid && $c->user_exists;
	
	# We allow the auth data to also specify the realm.
	my $realm= $link->auth->{realm};
	
	$c->log->debug("DirectLink: HandleAuth: autologin = ".($link->auth->{autologin}?'true':'false')
		.", curuser = ".($hasUser? $c->user->id : 'undef').", auth = "._hashToStr($link->auth));
	
	# we only auto-authenticate if that flag was set in the auth hash
	if ($link->auth->{autologin}) {
		# If there is no session, try authenticating the user
		if (!defined $c->user) {
			# first, try using just the link, as a credential:
			my $user= $c->authenticate({ directLink => $link }, $realm? $realm : ());
			# if that fails, try authenticating with the auth data in the link
			defined $user
				or $user= $c->authenticate( $link->auth, $realm? $realm : ());
			
			defined $user or die "Failed to authenticate user using link credentials";
			
			return 1;
		}
		else {
			my $user= $c->find_user($link->auth, $realm? $realm : ());
			defined $user or die "Failed to find user by link auth params";
			
			return $self->directLink_handleAuthDiscrepancy($c, $c->user, $user);
		}
	}
	# else we merely advise the auth system of what user should be used
	else {
		my $user= $c->find_user($link->auth, $realm? $realm : ());
		if ($user) {
			my $uname= $user->get("username");
			$c->log->info("defaulting login-username to ".$uname);
			$c->session->{RapidApp_username}= $uname;
		}
		else {
			$c->log->warn("didn't find the user specified by the link");
		}
	}
}

=head2 $self->directLink_handleAuthDiscrepancy( $c, $curUser, $newUser )

The users are objects generated by your Catalyst::Authentication::Store plugin.

Returns a hash specifying a boolean 'success' key, and possible diagnostics.

This is a sub-step of the default directLink_handleAuth.  It resolves the differences between
the current user and the user specified by the DirectLink.  The default behavior is to inherit
any permissions from the DirectLink user into the current user if and only if they are the same
user id.  Otherwise a warning is logged and no permissions are changed.

Override this method for custom processing.

=cut

sub directLink_handleAuthDiscrepancy($$$) {
	my ($self, $c, $curUser, $newUser)= @_;
	
	if ($curUser->id eq $newUser->id) {
		if ($curUser->can('inheritAccess')) {
			$curUser->inheritAccess($newUser);
			$c->persist_user();
		}
		else {
			$c->log->warn(
				"User object does not support inheriting access.  ".
				"Cannot add permissions from DirectLink.");
		}
	}
	else {
		$c->log->warn(
			"Followed a link for user '".$newUser->id."', but active session is for user '".$curUser->id."'.  "
			."Refusing to augment access, but continuing anyway.");
	}
	return { success => 1 };
}

=head1 SEE ALSO

L<Catalyst::Plugin::Session>

L<Catalyst::Plugin::Authentication>

L<Catalyst::Authentication::User>

L<RapidApp::DirectLink::Link>

L<RapidApp::DirectLink::LinkFactory>

=cut

1;
