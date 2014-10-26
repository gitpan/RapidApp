package RapidApp::TableSpec::Column::Profile;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(get_set); 

use RapidApp::Include qw(sugar perlutil);

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

# Cache collapsed profile sets process-wide for performance:
my %Sets = ();
sub get_set {
  my @profiles = uniq(&DEFAULT_BASE_PROFILES(),@_);
  my $key = join('|',@profiles);
  unless (exists $Sets{$key}) {
    my $profile_defs = &DEFAULT_PROFILES();
    my $collapsed = {};
    foreach my $profile (@profiles) {
      my $opt = $profile_defs->{$profile} or next;
      $collapsed = merge($collapsed,$opt);
    }
    $Sets{$key} = $collapsed;
  }
  return $Sets{$key};
}

1;