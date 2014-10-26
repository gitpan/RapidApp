package RapidApp::DbicAppGrid3;
use strict;
use Moose;
extends 'RapidApp::AppGrid2';
with 'RapidApp::Role::DbicLink2';

use RapidApp::Include qw(sugar perlutil);

has 'show_base_conditions_in_header', is => 'ro', isa => 'Bool', default => 1;

has 'toggle_edit_cells_init_off', default => sub {
  my $self = shift;
  # Set to the same value as 'use_add_form' (defaults to false, see DataStore2).
  # If there is no add form, it doesn't make sense to have cell editing
  # off by default. Otherwise, intial edit state defaults to off
  return $self->use_add_form ? 1 : 0;
}, is => 'ro', isa => 'Bool', lazy => 1;

sub BUILD {
	my $self = shift;
	
	if ($self->updatable_colspec) {
		$self->apply_extconfig( 
			xtype => 'appgrid2ed',
			clicksToEdit => 1,
		);
    
    # allow toggling
    $self->add_plugin('grid-toggle-edit-cells');
	}
	
	$self->apply_extconfig( 
    setup_bbar_store_buttons => \1,
    toggle_edit_cells_init_off => $self->toggle_edit_cells_init_off ? \1 : \0,
    
    # Sane default for the add button/tab:
    store_button_cnf => {
      add => {
        text    => 'Add ' . $self->ResultClass->TableSpec_get_conf('title'),
        iconCls => 'ra-icon-add'
      },
    }
  );
	
	$self->apply_default_tabtitle;
	
	# New AppGrid2 nav feature. Need to always fetch the column to use for grid nav (open)
	push @{$self->always_fetch_columns}, $self->open_record_rest_key
		if ($self->open_record_rest_key);
	
}

has '+open_record_rest_key', default => sub {
	my $self = shift;
	return try{$self->ResultClass->TableSpec_get_conf('rest_key_column')};
};

sub apply_default_tabtitle {
	my $self = shift;
	# ---- apply default tab title and icon:
	my $class = $self->ResultClass;
	
	my $title = try{$class->TableSpec_get_conf('title_multi')} || try{
		my $from = $self->ResultSource->from;
		$from = (split(/\./,$from,2))[1] || $from; #<-- get 'table' for both 'db.table' and 'table' format
		return $from;
	};
	
	my $iconCls = try{$class->TableSpec_get_conf('multiIconCls')};
	$self->apply_extconfig( tabTitle => $title ) if ($title);
	$self->apply_extconfig( tabIconCls => $iconCls ) if ($iconCls);
	# ----
}

# Show that a base condition is in effect in the panel header, unless
# the panel header is already set. This is to help users to remember
# that a given grid was followed from a multi-rel column, for instance
# TODO: better styling
around 'content' => sub {
  my $orig = shift;
  my $self = shift;
  
  my $ret = $self->$orig(@_);
  
  if($self->show_base_conditions_in_header) {
    my $resultset_condition = try{$ret->{store}->parm->{baseParams}{resultset_condition}};
    if ($resultset_condition) {
    
      my $cls = 'blue-text';
      $ret->{tabTitleCls} = $cls;
      
      $ret->{headerCfg} //= {
        tag => 'div',
        cls => 'panel-borders ra-footer',
        style => 'padding:3px;',
        html => '<i><span class="' . $cls . '"><b>Base Condition:</b></span> ' . 
          $resultset_condition . '</i>'
      };
    }
  }
    
  return $ret;
};





#### --------------------- ####


no Moose;
#__PACKAGE__->meta->make_immutable;
1;