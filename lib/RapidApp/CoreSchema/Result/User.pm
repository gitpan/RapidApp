package RapidApp::CoreSchema::Result::User;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table('user');

__PACKAGE__->add_columns(
   "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "full_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "last_login_ts",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "disabled",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "disabled_ts",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("username", ["username"]);

__PACKAGE__->has_many(
  "user_to_roles",
  "RapidApp::CoreSchema::Result::UserToRole",
  { "foreign.username" => "self.username" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
  "saved_states",
  "RapidApp::CoreSchema::Result::SavedState",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
  "sessions",
  "RapidApp::CoreSchema::Result::Session",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


__PACKAGE__->load_components('+RapidApp::DBIC::Component::TableSpec');
__PACKAGE__->TableSpec_m2m( roles => "user_to_roles", 'role');
__PACKAGE__->apply_TableSpec;

__PACKAGE__->TableSpec_set_conf( 
	title => 'User',
	title_multi => 'Users',
	#iconCls => 'ra-icon-user',
	#multiIconCls => 'ra-icon-group',
	display_column => 'username',
  priority_rel_columns => 1,
  columns => {
    last_login_ts => { allow_edit => \0, allow_add => \0 },
    disabled => { profiles => ['bool'] }
  }
);


__PACKAGE__->meta->make_immutable;
1;
