package RapidApp::TableSpec::Column;
use strict;
use Moose;

use RapidApp::Include qw(sugar perlutil);


our $VERSION = '0.1';

# This configuration class defines behaviors of tables and
# columns in a general way that can be used in different places


# Base profiles are applied to all columns
sub DEFAULT_BASE_PROFILES {(
	'BASE'
)}


our @number_summary_funcs = (
	{ function => 'sum', title => 'Total' },
	{ function => 'max', title => 'Max Val' },
	{ function => 'min', title => 'Min Val' },
	{ function => 'count(distinct({x}))', title => 'Count Unique' },
	{ function => 'count', title => 'Count (Set)' },
);

our @text_summary_funcs = (
	{ function => 'count(distinct({x}))', title => 'Count Unique' },
	{ function => 'count', title => 'Count (Set)' },
	#{ function => 'max(length({x})', title => 'Longest' },
);

our @date_summary_funcs = (
	@number_summary_funcs,
	@text_summary_funcs,
	#{ function => 'CONCAT(DATEDIFF(NOW(),avg({x})),\' days\')', title => 'Ave Age (days)' }, #<-- doesn't work
	{ function => 'CONCAT(DATEDIFF(NOW(),min({x})),\' days\')', title => 'Oldest (days)' },
	{ function => 'CONCAT(DATEDIFF(NOW(),max({x})),\' days\')', title => 'Youngest (days)' },
	{ function => 'CONCAT(DATEDIFF(max({x}),min({x})),\' days\')', title => 'Age Range (days)' }
);

push @number_summary_funcs, (
	{ function => 'round(avg({x}),2)', title => 'Average' },
);

# Default named column profiles. Column properties will be merged
# with the definitions below if supplied by name in the property 'profiles'
sub DEFAULT_PROFILES {{
		
		BASE => {
      is_nullable => 1, #<-- initial/default
			renderer => ['Ext.ux.showNull'] ,
			editor => { xtype => 'textfield', minWidth => 80, minHeight => 22 },
			summary_functions => \@text_summary_funcs
		},
    
    relcol => {
      width => 175
    },
		
		nullable => {
      is_nullable => 1, #<-- redundant/default
			editor => { allowBlank => \1, plugins => [ 'emptytonull' ] }
		},
		
		notnull => {
      is_nullable => 0,
			editor => { allowBlank => \0, plugins => [ 'nulltoempty' ] }
		},
		
		number => {
			editor => { xtype => 'numberfield', style => 'text-align:left;' },
			multifilter_type => 'number',
			summary_functions => \@number_summary_funcs
		},
		int => {
			editor => { xtype => 'numberfield', style => 'text-align:left;', allowDecimals => \0 },
		},
		
		bool => {
			menu_select_editor => {
			
				#mode: 'combo', 'menu' or 'cycle':
				mode => 'menu',
			
				render_icon_only => 1,
			
				selections => [
					{
						iconCls => "ra-icon-cross-light-12x12",
						#iconCls => "ra-icon-cross-tiny",
						text	=> 'No',
						value	=> 0
					},
					{
						iconCls => "ra-icon-checkmark-12x12",
						#iconCls => "ra-icon-tick-tiny",
						text	=> 'Yes',
						value	=> 1
					}
				]
			},
			multifilter_type => 'bool'
		},
		
		bool_old => {
			# Renderer *not* in arrayref makes it replace instead of append previous
			# profiles with th renderer property as an arrayref
			renderer => 'Ext.ux.RapidApp.boolCheckMark',
			xtype => 'booleancolumn',
			#trueText => '1',
			#falseText => '0',
			editor => { xtype => 'checkbox'  }
			#editor => { xtype => 'logical-checkbox', plugins => [ 'booltoint' ] }
		},
		text => {
      width => 100,
			editor => { xtype => 'textfield', grow => \0 },
			summary_functions => \@text_summary_funcs 
		},
		bigtext => {
      width => 150,
			renderer 	=> ['Ext.util.Format.nl2br'],
			editor		=> { xtype => 'textarea', grow => \1 },
			summary_functions => \@text_summary_funcs 
		},
    monotext => {
      width => 150,
			renderer 	=> ['Ext.ux.RapidApp.renderMonoText'],
			editor		=> { xtype => 'textarea', grow => \1 },
			summary_functions => \@text_summary_funcs 
		},
		html => {
			width => 200,
      # We need this renderer in case the 'bigtext' profile above has been applied
			# automatically. For HTML we *don't* want to nl2br() as it will totally break markup
			renderer => 'Ext.ux.showNull',
			editor => {
				xtype		=> 'ra-htmleditor',
				resizable => \1, #<-- Specific to Ext.ux.RapidApp.HtmlEditor ('ra-htmleditor')
				#height => 200,
				minHeight => 200,
				minWidth	=> 400,
				anchor => '-25',
			},
		},
		email => {
      width => 100,
			editor => { xtype => 'textfield' },
			summary_functions => \@text_summary_funcs,
		},
		datetime => {
			editor => { 
				xtype => 'xdatetime2', 
				plugins => ['form-relative-datetime'], 
				minWidth => 200,
				editable => \0  #<-- force whole-field click/select
			},
      width => 130,
			renderer => ["Ext.ux.RapidApp.getDateFormatter('M d, Y g:i A')"],
			multifilter_type => 'datetime',
			summary_functions => \@date_summary_funcs
		},
		date => {
			editor => { 
				xtype => 'datefield', 
				plugins => ['form-relative-datetime'], 
				minWidth => 120,
				editable => \0 #<-- force whole-field click/select
			},
      width => 80,
			renderer => ["Ext.ux.RapidApp.getDateFormatter('M d, Y')"],
			multifilter_type => 'date',
			summary_functions => \@date_summary_funcs
		},
		money => {
			editor => { xtype => 'numberfield', style => 'text-align:left;', decimalPrecision => 2 },
			renderer => 'Ext.ux.showNullusMoney',
			summary_functions => \@number_summary_funcs
		},
		percent => {
			 editor => { xtype => 'numberfield', style => 'text-align:left;' },
			 renderer => ['Ext.ux.RapidApp.num2pct'],
			 summary_functions => \@number_summary_funcs
		},
		noadd => {
			allow_add => \0,
		},
		noedit => {
			editor => '',
			allow_edit => \0,
			allow_batchedit => \0
		},
		zipcode => {
			editor => { vtype => 'zipcode' }
		},
    filesize => {
      renderer => 'Ext.util.Format.fileSize',
    },
    autoinc => {
      allow_add => \0,
      allow_edit => \0,
      allow_batchedit => \0
    }

}};


around BUILDARGS => sub {
	my $orig = shift;
	my $class = shift;
	my %params = (ref($_[0]) eq 'HASH') ? %{ $_[0] } : @_; # <-- arg as hash or hashref
	
	my $profile_defs = $class->_build_profile_definitions;
	$profile_defs = merge($profile_defs, delete $params{profile_definitions}) if ($params{profile_definitions});
	
	$params{properties_underlay} = {} unless ($params{properties_underlay});
	$params{profiles} = [ $params{profiles} ] if ($params{profiles} and not ref($params{profiles}));
	
	my @base_profiles = ( $class->DEFAULT_BASE_PROFILES );
	push @base_profiles, @{ delete $params{base_profiles} } if($params{base_profiles});
	my @profiles = @base_profiles;
	push @profiles, @{ delete $params{profiles} } if ($params{profiles});
	
	# Apply/merge profiles if defined:
	$class->collapse_apply_profiles($profile_defs,$params{properties_underlay},@profiles);
	
	$params{profile_definitions} = $profile_defs;
	$params{base_profiles} = \@base_profiles;
	return $class->$orig(%params);
};


sub collapse_apply_profiles {
	my $self = shift;
	my $profile_defs = shift;
	my $target = shift or die "collapse_apply_profiles(): missing arguments";
	my @base_profiles = @_;
	
	my $profiles = [];
	$profiles = delete $target->{profiles} if($target->{profiles});
	$profiles = [ $profiles ] unless (ref $profiles);
	@$profiles = (@base_profiles,@$profiles);
	
	return unless (scalar @$profiles > 0);
	
	my $collapsed = {};
	foreach my $profile (@$profiles) {
		my $opt = $profile_defs->{$profile} or next;
		$collapsed = merge($collapsed,$opt);
	}

	%$target = %{ merge($target,$collapsed) };
}




has 'name' => ( is => 'ro', isa => 'Str', required => 1 );
#has 'order' => ( is => 'rw', isa => 'Maybe[Int]', default => undef, clearer => 'clear_order' );
has 'permission_roles' => ( is => 'rw', isa => 'Maybe[HashRef[ArrayRef]]', default => undef );
has '_other_properties' => ( is => 'ro', isa => 'HashRef', default => sub {{}} );

has 'base_profiles' => ( is => 'ro', isa => 'ArrayRef', default => sub {[]} );

has 'profile_definitions' => ( is => 'ro', isa => 'HashRef', lazy_build => 1 );
sub _build_profile_definitions {
	my $self = shift;
	my $defs = $self->DEFAULT_PROFILES();
	
	# TODO collapse sub-profile defs
	return $defs;
}


# properties that get merged under actual properties - collapsed from profiles:
has 'properties_underlay' => ( is => 'ro', isa => 'HashRef', default => sub {{}} );
sub apply_profiles {
	my $self = shift;
	my @profiles = @_;
	@profiles = @{$_[0]} if (ref $_[0]);
	
	return unless (scalar @profiles > 0);
	
	$self->collapse_apply_profiles(
		$self->profile_definitions,
		$self->properties_underlay,
		@profiles
	);
}

has 'exclude_attr_property_names' => ( 
	is => 'ro', isa => 'HashRef',
	default => sub {  
		my @list = (
			'exclude_property_names',
			'properties_underlay',
			'_other_properties',
			'extra_properties'
		);
		return { map {$_ => 1} @list };
});


sub get_property {
	my $self = shift;
	my $name = shift;
	
	my $attr = $self->meta->get_attribute($name);
	return $attr->get_value($self) if ($attr);
	
	return $self->_other_properties->{$name};
}

sub set_properties {
	my $self = shift;
	my %new = (ref($_[0]) eq 'HASH') ? %{ $_[0] } : @_; # <-- arg as hash or hashref
	
	$self->apply_profiles(delete $new{profiles}) if ($new{profiles});
	
	foreach my $key (keys %new) {
		my $attr = $self->meta->get_attribute($key);
		if ($attr and $attr->has_write_method) {
			$self->$key($new{$key});
		}
		else {
			$self->_other_properties->{$key} = $new{$key};
		}
	}
}

# Only sets properties not already defined:
sub set_properties_If {
	my $self = shift;
	my %new = (ref($_[0]) eq 'HASH') ? %{ $_[0] } : @_; # <-- arg as hash or hashref
	
	foreach my $prop (keys %new) {
		$self->get_property($prop) and delete $new{$prop};
	}
	
	return $self->set_properties(%new);
}

has 'extra_properties', is => 'ro', isa => 'HashRef', default => sub {{}};
sub all_properties_hash {
	my $self = shift;
	
	my %hash = %{ $self->_other_properties };
	
	foreach my $attr ($self->meta->get_all_attributes) {
		next if ($self->exclude_attr_property_names->{$attr->name});
		next unless ($attr->has_value($self));
		$hash{$attr->name} = $attr->get_value($self);
	}
	
	my $props = { %{$self->properties_underlay},%hash };
	
	# added 'extra_properties' for extra properties that can be merged (past the first
	# level), specifically, for 'editor'. Notice above that the merge with 'properties_underlay'
	# is one-layer. This has gotten complicated and ugly and needs refactoring...
	return merge($self->extra_properties,$props); 
}

# Returns a hashref of properties that match the list/hash supplied:
sub properties_limited {
	my $self = shift;
	my $map;
	
	if (ref($_[0]) eq 'HASH') 		{	$map = shift;								}
	elsif (ref($_[0]) eq 'ARRAY')	{	$map = { map { $_ => 1 } @{$_[0]} };	}
	else 									{	$map = { map { $_ => 1 } @_ };			}
	
	my $properties = $self->all_properties_hash;
	
	my @keys = grep { $map->{$_} } keys %$properties;
	
	my $set = {};
	foreach my $key (@keys) {
		$set->{$key} = $properties->{$key};
	}
	
	return $set;
}


sub copy {
	my $self = shift;
	my %opts = (ref($_[0]) eq 'HASH') ? %{ $_[0] } : @_; # <-- arg as hash or hashref
	
	my %attr = ();
	my %other = ();
	
	foreach my $opt (keys %opts) {
		if ($self->meta->find_attribute_by_name($opt)) {
			$attr{$opt} = $opts{$opt};
		}
		else {
			$other{$opt} = $opts{$opt};
		}
	}
	
	my $Copy = $self->meta->clone_object(Clone::clone($self),%attr);
		#$self,
		#%attr, 
		# This shouldn't be required, but is. The clone doesn't clone _other_properties!
		#_other_properties => { %{ $self->_other_properties } }
	#);
	
	$Copy->set_properties(%other);

	return $Copy;
}


has 'rapidapp_init_coderef' => ( is => 'rw', isa => 'Maybe[CodeRef]', default => undef );
sub call_rapidapp_init_coderef {
	my $self = shift;
	return unless ($self->rapidapp_init_coderef);
	
	### Call ###
	$self->rapidapp_init_coderef->($self,@_);
	############

	# Clear:
	$self->rapidapp_init_coderef(undef);
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;