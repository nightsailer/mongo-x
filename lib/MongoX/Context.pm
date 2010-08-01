package MongoX::Context;
# ABSTRACT: Implements DSL interface,context container.
use strict;
use warnings;

use Carp 'croak';
use MongoDB;

my %registry = ();
my %connection_pool = ();

# context
my $context_connection;
my $context_collection;
my $context_db;

sub get_connection {
    my ($id) = @_;
    $id ||= 'default';
    if (exists $connection_pool{$id}) {
        return $connection_pool{$id};
    }
    croak "connection_id:$id not exists in registry,forgot to add it?(add_connection)" unless exists $registry{$id};
    my $new_con = MongoDB::Connection->new(%{ $registry{$id} });
    $connection_pool{$id} = $new_con;
}

sub get_db {
    my ($dbname,$connection_id) = @_;
    if ($connection_id) {
        return get_connection($connection_id)->get_database($dbname);
    }
    return $context_connection->get_database($dbname);
}

sub use_db {
    $context_db = $context_connection->get_database(shift);
}

sub add_connection {
   my (%opts) = @_;
   my $id = $opts{id} || 'default';
   $registry{$id} = { @_ };
}

sub use_connection {
    my ($id) = @_;
    $id ||= 'default';
    $context_connection = get_connection($id);
}

sub use_collection {
    my ($collection_name) = @_;
    $context_collection = $context_db->get_collection($collection_name);
}

sub get_collection {
    my ($collection_name) = @_;
    $context_db->get_collection($collection_name);
}


sub context_db { $context_db }

sub context_connection { $context_connection }

sub context_collection { $context_collection }

sub boot {
    my (%opts) = @_;
    return unless %opts;
    add_connection(%opts);
    use_connection;
    use_db($opts{db}) if exists $opts{db};
}

sub reset {
    ($context_connection,$context_collection,$context_db) = undef;
    %registry = ();
    %connection_pool = ();
}

1;
__END__


=head1 SYNOPSIS
    
    use MongoX::Context;
    
    MongoX::Context::add_connection host => 'mongodb:://127.0.0.1';
    
    MongoX::Context::use_connection;
    
    MongoX::Context::use_db 'test';
    
    MongoX::Context::reset;
    
    MongoX::Context::boot host => 'mongodb://127.0.0.1',db => 'test2';
    
    my $col2 = MongoX::Context::context_db->get_collection('foo2');



=head1 DESCRIPTION

MongoX::Context implements the DSL syntax, track and hold internal MongoDB related objects.

