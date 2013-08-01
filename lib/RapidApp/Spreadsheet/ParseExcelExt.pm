package RapidApp::Spreadsheet::ParseExcelExt;

1;

package Spreadsheet::ParseExcel::Worksheet;

sub cell_text {
	my $self= shift;
	my $cell= $self->get_cell(@_);
	defined($cell) or return '';
	my $text= $cell->Value;
	$text =~ s/^\s+//;
	$text =~ s/\s+$//;
	return $text;
}

1;