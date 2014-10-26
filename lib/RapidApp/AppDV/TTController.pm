package RapidApp::AppDV::TTController;
use Moose;

use RapidApp::Include qw(sugar perlutil);

use RapidApp::RecAutoload;

has 'AppDV' => (
	is => 'ro',
	isa => 'RapidApp::AppDV',
	required => 1
);


sub dataview_id {
	my $self = shift;
	return $self->AppDV->get_extconfig_param('id');
}




sub div_wrapper {
	my $self = shift;
	return '<div class="appdv-tt-generated ' . $self->dataview_id . '">' . 
		(shift) . 
	'</div>';
}




sub div_clickable {
	my $self = shift;
	return $self->div_wrapper(
		'<div class="clickable">' . 
			(shift) . 
		'</div>'
	);
}



sub delete_record {
	my $self = shift;
	return $self->div_clickable('<div class="delete-record">Delete</div>');
}

sub print_view {
	my $self = shift;
	return $self->div_clickable('<div class="print-view">Print View</div>');
}


sub div_editable_value{
	my $self = shift;
	my $name = shift;
	
	return $self->div_clickable(
		
		'<div class="editable-value">' .
			'<div class="field-name" style="display:none;">' . $name . '</div>' .
			(shift) .
		'</div>'
	);
}

sub data_wrapper_div {
	my $self = shift;
	my $name = shift;
	my $display = shift;
	$display = $name unless ($display);
	
	my $div = '<div class="data-holder"';
	
	my $Column = $self->AppDV->get_column($name);
	if($Column) {
		my $style = $Column->get_field_config->{data_wrapper_style};
		$div .= ' style=" ' . $style . '"' if ($style);
	}
	
	return '<div class="data-wrapper">' .
		$div . '>{' . $display . '}</div>' .
		'<div class="field-holder"></div>' .
	'</div>' ;
}



sub div_edit_field {
	my $self = shift;
	my $name = shift;
	my $display = shift;
	$display = $name unless ($display);
	return $self->div_editable_value($name,
		'<div class="appdv-edit-field">' .	
			'<table border="0" cellpadding="0" cellspacing="0"><tr>' .
				'<td>' . $self->data_wrapper_div($name,$display) . '</td>' .
								
				'<td class="icons">' .
					'<div class="edit">&nbsp;</div>' .
					'<div class="save" title="save">&nbsp;</div>' .
					'<div class="cancel" title="cancel">&nbsp;</div>' .
				'</td>' .
			'</tr></table>' .
		'</div>'
	);
}


sub div_edit_field_no_icons {
	my $self = shift;
	my $name = shift;
	my $display = shift;
	$display = $name unless ($display);
	return $self->div_editable_value($name,
		'<div class="appdv-edit-field">' .	
			'<table border="0" cellpadding="0" cellspacing="0"><tr>' .
				'<td>' . $self->data_wrapper_div($name,$display) . '</td>' .

			'</tr></table>' .
		'</div>'
	);
}



sub div_bigfield {
	my $self = shift;
	my $name = shift;
	my $display = shift;
	$display = $name unless ($display);
	
	return $self->div_editable_value($name,
		'<div class="appdv-edit-bigfield require-edit-click">' .
			$self->data_wrapper_div($name,$display)  . 
			'<div class="icons">' .
				'<div class="edit">edit</div>' .
				'<div class="cancel">cancel</div>' .
				'<div class="save">save</div>' .
			'</div>' .
		'</div>'
	);
}



has 'field' => (
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return RapidApp::RecAutoload->new( process_coderef => sub {
			my $name = shift;
			my $Column = $self->AppDV->get_column($name) or return '';
			$self->FieldCmp->{$Column->name} = $self->AppDV->json->encode($Column->get_field_config);
			
			return '<div class="' . $Column->name . '">{' . $Column->name . '}</div>';
		});
	
	}
);



has 'edit_field' => (
	is => 'ro',
	lazy => 1,
	isa => 'RapidApp::RecAutoload',
	default => sub {
		my $self = shift;
		return RapidApp::RecAutoload->new( process_coderef => sub {
			my $name = shift;
			my $display = shift;
			$display = $name unless ($display);
			my $Column = $self->AppDV->get_column($name) or return '';
			
			$self->AppDV->FieldCmp->{$Column->name} = $self->AppDV->json->encode($Column->get_field_config);

			return $self->div_edit_field($Column->name,$display);
		});
	}
);


has 'edit_bigfield' => (
	is => 'ro',
	lazy => 1,
	isa => 'RapidApp::RecAutoload',
	default => sub {
		my $self = shift;
		return RapidApp::RecAutoload->new( process_coderef => sub {
			my $name = shift;
			my $display = shift;
			$display = $name unless ($display);
			my $Column = $self->AppDV->get_column($name) or return '';
			
			$self->AppDV->FieldCmp->{$Column->name} = $self->AppDV->json->encode($Column->get_field_config);

			return $self->div_bigfield($Column->name,$display);
			
#			'<div class="appdv-click ' . $self->AppDV->get_extconfig_param('id') . '">' .
#			
#				#'<div class="appdv-click-el edit:' . $Column->name . '" style="float: right;padding-top:4px;padding-left:4px;cursor:pointer;"><img src="/assets/rapidapp/misc/static/images/pencil_tiny.png"></div>' .
#				'<div class="appdv-field-value ' . $Column->name . '" style="position:relative;">' .
#				#'<div style="overflow:auto;">' .
#					'<div class="data">{' . $display . '}</div>' .
#					'<div class="fieldholder"></div>' .
#					'<div class="appdv-click-el edit:' . $Column->name . ' appdv-edit-box">edit</div>' .
#					'<div class="appdv-click-el edit:' . $Column->name . ' appdv-edit-box save">save</div>' .
#					'<div class="appdv-click-el edit:' . $Column->name . ' appdv-edit-box cancel"><img class="cancel" src="/assets/rapidapp/misc/static/images/cross_tiny.png"></div>' .
#				'</div>' .
#			'</div>';

		});
	}
);
		
		
has 'edit_click_field' => (
	is => 'ro',
	lazy => 1,
	isa => 'RapidApp::RecAutoload',
	default => sub {
		my $self = shift;
		return RapidApp::RecAutoload->new( process_coderef => sub {
			my $name = shift;
			my $Column = $self->AppDV->get_column($name) or return '';
			
			$self->AppDV->FieldCmp->{$Column->name} = $self->AppDV->json->encode($Column->get_field_config);


			
			return
			
			'<div class="appdv-click ' . $self->AppDV->get_extconfig_param('id') . '">' .
			

					'<div class="data appdv-editable-value"><span>{' . $Column->name . '}</span></div>' .
					
			'</div>';

		});
	}
);




has 'autofield' => (
	is => 'ro',
	lazy => 1,
	isa => 'RapidApp::RecAutoload',
	default => sub {
		my $self = shift;
		return RapidApp::RecAutoload->new( process_coderef => sub {
			my $name = shift;
			my $display = shift;
			$display = $name unless ($display);
			my $Column = $self->AppDV->get_column($name) or return '';
			
			if($Column->renderer) {
				$display = '[this.renderField("' . $name . '",values,' . $Column->renderer->func . ')]';
			}
			
			# read-only:
			return '{' . $display . '}' unless ($Column->editor);
			
			# -- TODO: this breaks create without update unless "allow_add" is specifically set on the column
			# Needs fixed... probably the best way to handle it is to dynamically turn on "allow_add" when
			# it isn't explicitly set but it should otherwise be addable (i.e. set in creatable_colspec)
			return '{' . $display . '}' if (
				defined $Column->allow_edit and
				! jstrue($Column->allow_edit) and
				! jstrue($Column->allow_add)
			);
			# --
			
			my $config = $Column->get_field_config;
			
			
			# -- TODO: refactor AppDV for all the changes that came with TableSpec
			# in the mean time, this makes sure the editor/field isn't too small
			$config->{minHeight} = 22 unless ($config->{minHeight});
			$config->{minWidth} = $Column->width + 30 if ($Column->width and ! $config->{minWidth});
			# --

			
			##############
			### FIX ME ###
			##############
			
			## Temp hack workaround ##
			## for some reason 'checkbox' field doesn't work in AppDV. The checkbox is not clickable.
			## It is some kind of low-level browser issue
			## I spent a bunch of time trying to figure it out and then finally have up and wrote
			## 'logical-checkbox'.  (might be a fundamental flaw in AppDV)
			## This is ugly and needs to be fixed, as this workaround is "spooky action at a distance"
			$config->{xtype} = 'logical-checkbox' if ($config->{xtype} eq 'checkbox');
			##
			##
			
			##############
			##############
			##############
			
			
			
			$self->AppDV->FieldCmp->{$Column->name} = $self->AppDV->json->encode($config);
			
			# editable
			
			my @bigfield_types = qw(textarea htmleditor ra-htmleditor);
			my %bf_types = map {$_=>1} @bigfield_types;
			return $self->div_bigfield($Column->name,$display) if (
				$bf_types{$config->{xtype}}
			);
			
			my @no_icons_types = qw(cycle-field menu-field cas-upload-field cas-image-field);
			my %ni_types = map {$_=>1} @no_icons_types;
			return $self->div_edit_field_no_icons($Column->name,$display) if (
				$ni_types{$config->{xtype}}
			);
			
			return $self->div_edit_field($Column->name,$display);
		});
	}
);

	
		
has 'submodule' => (
	is => 'ro',
	lazy => 1,
	isa => 'RapidApp::RecAutoload',
	default => sub {
		my $self = shift;
		return RapidApp::RecAutoload->new( process_coderef => sub {
			my $name = shift;
			
			my $Module = $self->AppDV->Module($name) or return '';
			
			return $self->div_module_content($name,$Module);
			
		});
	}
);


sub get_Module {
	my $self = shift;
	my $path = shift;
	
	my $Module = $self->AppDV->get_Module($path) or return '';
	
	$path =~ s/\//\_/g;
			
	return $self->div_module_content($path,$Module);
}

# Example tt usage:
# [% r.ajaxcmp('projects2','/main/explorer/projects2','{"p1":"p1val","p2":"p2val"}') %]
sub ajaxcmp {
	my $self = shift;
	my $name = shift;
	my $url = shift;
	my $params_enc = shift;
	
	my $params = {};
	$params = $self->AppDV->json->decode($params_enc) if (defined $params_enc);
	
	
	my $cnf = {
		xtype 	=> 'ajaxcmp',
		applyCnf => {
			plugins => [ 'autowidthtoolbars' ],
			autoHeight => \1
		},
		renderTarget => 'div.appdv-submodule.' . $name,
		applyValue => $self->AppDV->record_pk,
		autoLoad	=> {
			url		=> $url,
			params	=> $params
		},
	};
	
	return $self->div_module($name,$cnf);
}


sub div_module_content {
	my $self = shift;
	my $name = shift;
	my $Module = shift;
	
	my $cnf = {
		plugins => [ 'autowidthtoolbars' ],
		autoHeight => \1,
		renderTarget => 'div.appdv-submodule.' . $name,
		applyValue => $self->AppDV->record_pk,
		%{ $Module->content }
	};
	
	return $self->div_module($name,$cnf);
}


sub init_dynamic_ajaxcmp {
	my $self = shift;
	my $target = shift;
	my $name = $target;
	
	$name =~ s/\./\_/g;
	
	my $cnf = {
		renderDynTarget => $target
	};
	
	$self->div_module($name,$cnf);
	return '';
}





sub div_module {
	my $self = shift;
	my $name = shift;
	my $cnf = shift;
	
	# Apply optional overrides:
	$cnf = { %$cnf, %{ $self->AppDV->submodule_config_override->{$name} } } if ($self->AppDV->submodule_config_override->{$name});
	
	# Store component configs as serialized JSON to make sure
	# they come out the same every time on the client side:
	$self->AppDV->DVitems->{$name} = $self->AppDV->json->encode($cnf);
	
	return '<div class="appdv-submodule ' . $name . '"></div>';
}



sub toggle {
	my $self = shift;
	return {
		edit => $self->div_clickable(
			'<div class="edit-record-toggle">' .
				'<div class="edit">Edit</div>' .
				'<div class="save">Save</div>' .
				'<div class="cancel">Cancel</div>' .
			'</div>'
		),
						
		select	=> '<div class="appdv-toggle select"></div>'
	};
}



1;
