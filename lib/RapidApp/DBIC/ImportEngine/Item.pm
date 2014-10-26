package RapidApp::DBIC::ImportEngine::Item;

use Moose;

use Try::Tiny;

# the operation this item describes, "insert", "update", "find"
has 'action' => ( is => 'rw', isa => 'Str', default => 'insert', ,required => 1 );

# the name of the DBIC source to perform the operation on
has 'source' => ( is => 'rw', isa => 'Str', required => 1 );

# the data which should be inserted or used for update
has 'data'   => ( is => 'rw', isa => 'Maybe[HashRef]' );

# the search criteria which should be used to locate a record for "find" or "update"
has 'search' => ( is => 'rw', isa => 'Maybe[HashRef]' );

# reference to the engine which should be used for calculations
has 'engine' => ( is => 'ro', isa => 'RapidApp::DBIC::ImportEngine', weak_ref => 1, required => 1 );

# an array of source/key/value items which describe other records which must be imported first
has 'dependencies' => ( is => 'rw', lazy_build => 1 );

# the data with its original keys translated to local keys
has 'remapped_data' => ( is => 'rw', lazy_build => 1 );

sub _build_dependencies {
	my $self= shift;
	my $engine= $self->engine;
	my @allDeps= $engine->get_deps_for_source($self->source);
	return [ grep { $_->is_relevant($engine, $self) } @allDeps ];
}

sub _build_remapped_data {
	my $self= shift;
	return $self->engine->default_build_remapped_data($self);
}

sub resolve_dependencies {
	my $self= shift;
	return $self->engine->default_process_dependencies($self);
}

sub insert {
	my $self= shift;
	die "Dependencies not resolved" unless scalar(@{$self->dependencies}) == 0;
	try {
		$self->engine->perform_insert($self->source, $self->data, $self->remapped_data);
	}
	catch {
		my $err= $_;
		$err= "$err" if (ref $err);
		$self->engine->try_again_later($self, $err);
	};
}

sub update {
	my $self= shift;
	$self->engine->perform_update($self->source, $self->search, $self->data, $self->remapped_data);
}

__PACKAGE__->meta->make_immutable;