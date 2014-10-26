package RapidApp::DbicAppGrid::EditItem;

use strict;
use warnings;
use Moose;
extends 'RapidApp::AppGrid::EditItem';



################################################################
################################################################



has 'tbar_icon' => ( is => 'ro', default => '/assets/rapidapp/misc/static/images/table_selection_row_32x32.png' );
has 'tbar_title' => ( is => 'ro', lazy_build => 1 );
sub _build_tbar_title {
	my $self = shift;
	return 'Edit row (' . $self->parent_module->db_name . '/' . $self->parent_module->table . ')';
}


1;
