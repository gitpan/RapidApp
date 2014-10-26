package Catalyst::Plugin::RapidApp::CoreSchema;
use Moose::Role;
use namespace::autoclean;

=pod

=head1 DESCRIPTION

Base Catalyst Role/Plugin for setting up the CoreSchema model.
This role should be loaded by any modules which use the CoreSchema,
such as AuthCore and NavCore

=cut

with 'Catalyst::Plugin::RapidApp';

use RapidApp::Include qw(sugar perlutil);
use CatalystX::InjectComponent;

# setupRapidApp is the main function which injects components
after 'setupRapidApp' => sub {
  my $c = shift;
  $c->injectUnlessExist(
    'Catalyst::Model::RapidApp::CoreSchema',
    'Model::RapidApp::CoreSchema'
  );
};

1;
