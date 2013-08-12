
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;

use File::ShareDir::Install;
install_share dist => "share";


my %WriteMakefileArgs = (
  "ABSTRACT" => "Turnkey ajaxy webapps",
  "AUTHOR" => "Henry Van Styn <vanstyn\@cpan.org>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30",
    "File::ShareDir::Install" => "0.03"
  },
  "DISTNAME" => "RapidApp",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "RapidApp",
  "PREREQ_PM" => {
    "AnyEvent" => 0,
    "AnyEvent::Handle" => 0,
    "AnyEvent::Util" => 0,
    "Attribute::Handlers" => 0,
    "CSS::Inliner" => 0,
    "CSS::Simple" => 0,
    "CSS::Tiny" => 0,
    "Carp" => 0,
    "Catalyst" => "5.90002",
    "Catalyst::Action" => 0,
    "Catalyst::Authentication::Store::DBIx::Class" => 0,
    "Catalyst::Controller" => 0,
    "Catalyst::Controller::AutoAssets" => "0.24",
    "Catalyst::Log" => 0,
    "Catalyst::Model" => 0,
    "Catalyst::Model::DBIC::Schema" => 0,
    "Catalyst::Model::DBIC::Schema::Types" => 0,
    "Catalyst::Plugin::Authorization::Roles" => 0,
    "Catalyst::Plugin::AutoAssets" => 0,
    "Catalyst::Plugin::Session::State::Cookie" => 0,
    "Catalyst::Plugin::Session::Store::DBIC" => 0,
    "Catalyst::Utils" => 0,
    "Catalyst::View" => 0,
    "Catalyst::View::TT" => 0,
    "CatalystX::InjectComponent" => 0,
    "Class::MOP::Class" => 0,
    "Clone" => 0,
    "Cwd" => 0,
    "DBIx::Class" => "0.08250",
    "DBIx::Class::Core" => 0,
    "DBIx::Class::ResultSet" => 0,
    "DBIx::Class::Schema" => 0,
    "Data::Dumper" => 0,
    "DateTime" => 0,
    "DateTime::Format::Flexible" => 0,
    "DateTime::Format::SQLite" => 0,
    "Devel::NYTProf" => 0,
    "Devel::StackTrace" => 0,
    "Devel::StackTrace::AsHTML" => 0,
    "Devel::StackTrace::WithLexicals" => 0,
    "Digest::MD5" => 0,
    "Digest::SHA1" => 0,
    "Email::MIME" => 0,
    "Email::MIME::CreateHTML" => 0,
    "Email::MIME::CreateHTML::Resolver::LWP" => 0,
    "Encode" => "2.21",
    "Errno" => 0,
    "Excel::Writer::XLSX" => 0,
    "Exception::Class" => 0,
    "Exporter" => 0,
    "Fcntl" => 0,
    "File::MimeInfo::Magic" => 0,
    "File::ShareDir" => 0,
    "FindBin" => 0,
    "Git::Repository" => 0,
    "HTML::Encoding" => 0,
    "HTML::Entities" => 0,
    "HTML::TokeParser::Simple" => 0,
    "HTTP::Status" => 0,
    "Hash::Diff" => 0,
    "Hash::Merge" => 0,
    "IO::All" => 0,
    "IO::File" => 0,
    "IO::Handle" => 0,
    "Image::Resize" => 0,
    "Image::Size" => 0,
    "JSON" => 0,
    "JSON::PP" => 0,
    "JSON::XS" => 0,
    "JavaScript::ExtJS::V3" => 0,
    "MIME::Base64" => 0,
    "MRO::Compat" => 0,
    "Module::Find" => 0,
    "Module::Runtime" => 0,
    "Moo" => 0,
    "MooX::Types::MooseLike::Base" => "0.23",
    "Moose" => 0,
    "Moose::Exporter" => 0,
    "Moose::Role" => 0,
    "Moose::Util" => 0,
    "Moose::Util::TypeConstraints" => 0,
    "MooseX::NonMoose" => 0,
    "MooseX::Traits" => 0,
    "MooseX::Types::Moose" => 0,
    "POSIX" => 0,
    "PPI" => 0,
    "PPI::HTML" => 0,
    "Params::Validate" => 0,
    "Path::Class" => 0,
    "SQL::Translator" => "0.11016",
    "Scalar::Util" => 0,
    "Socket" => 0,
    "Spreadsheet::ParseExcel" => 0,
    "Spreadsheet::ParseExcel::Utility" => 0,
    "Spreadsheet::WriteExcel" => 0,
    "Storable" => 0,
    "String::Random" => 0,
    "Sub::Name" => 0,
    "Sub::Quote" => 0,
    "Switch" => 0,
    "System::Command" => 0,
    "Template" => "2.25",
    "Template::Context" => 0,
    "Template::Provider" => 0,
    "Term::ANSIColor" => 0,
    "Text::Glob" => 0,
    "Text::Markdown" => "1.000031",
    "Text::SimpleTable" => 0,
    "Text::SimpleTable::AutoWidth" => 0,
    "Text::TabularDisplay" => 0,
    "Text::WagnerFischer" => 0,
    "Text::Wrap" => 0,
    "Time::HiRes" => 0,
    "Try::Tiny" => 0,
    "URI::Escape" => 0,
    "autodie" => 0,
    "base" => 0,
    "bytes" => 0,
    "constant" => 0,
    "integer" => 0,
    "namespace::autoclean" => 0,
    "overload" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.99015",
  "test" => {
    "TESTS" => ""
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);

{
package
MY;
use File::ShareDir::Install qw(postamble);
}


