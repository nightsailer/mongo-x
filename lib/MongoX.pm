package MongoX;
# ABSTRACT: DSL sugar for MongoDB
use strict;
use warnings;

our $VERSION = '0.01';
use parent qw( Exporter );
use MongoX::Context;

our @EXPORT = qw(
    boot
    add_connection
    use_connection
    use_collection
    use_db
    context_db
    context_connection
    context_collection
);


=method use_connection

    # create a default connection
    use_connection;
    # use another connection with id:'con2'
    use_connection 'con2';

Switch to given connection, set the context connection to this connection. 

=cut

sub use_connection { MongoX::Context::use_connection(@_) }

=method use_db

    use_db 'foo';

Switch to the database, set the context database to this database;

=cut

sub use_db { MongoX::Context::use_db(@_) }

=method use_collection

    use_collection 'user'

Set 'user' collection  as context collection.

=cut

sub use_collection { MongoX::Context::use_collection(@_) }

=attr context_db

    my $db = context_db;

Return current L<MongoDB::Database> object in context;

=cut

sub context_db { MongoX::Context::context_db }

=attr context_connection

    my $con = context_connection;

Return current L<MongoDB::Connection> object in context.

=cut

sub context_connection { MongoX::Context::context_connection }


=attr context_collection

    my $col = context_collection;

Return current L<MongoDB::Collection> object in context, you can replace the object
with L</use_collection>.

=cut

sub context_collection { MongoX::Context::context_collection }

=method add_connection

    add_connection id => 'default', host => 'mongodb://127.0.0.1:27017'

Register a connnection with the id, if omit, will add as default connection.
All options exclude 'id' will direct pass to L<MongoDB::Connection>.

=cut

sub add_connection { MongoX::Context::add_connection(@_) }

=method boot

    boot host => 'mongodb://127.0.0.1',db => 'test'
    # same as:
    add_connection host => 'mongodb://127.0.0.1', id => 'default';
    use_connection;
    use_db 'test';

Boot is equivalent to call add_connection,use_connection,use_db.

=cut
sub boot { MongoX::Context::boot(@_) }


sub import {
    my ( $class,   %options ) = @_;
    $class->export_to_level( 1, $class, @EXPORT );
    boot %options if %options;
}



1;
__END__

=head1 SYNOPSIS

    # quick bootstrap, add connection and switch to db:'test'
    use MongoX { host => 'mongodb://127.0.0.1',db => 'test' };

    # common way
    use MongoX;
    #register default connection;
    add_connection host => '127.0.0.1';
    # switch to default connection;
    use_connection;
    # use database 'test'
    use_db 'test';
    
    #add/register another connection with id "remote2"
    add_connection host => '192.168.1.1',id => 'remote2';
    
    # switch to this connection
    use_connection 'remote2';
    
    #get a collection object (from the db in current context)
    my $foo = get_collection 'foo';
    
    # use 'foo' as default context collection
    use_collection 'foo';
    
    # use context's db/collection
    say 'total rows:',context_collection->count();
    
    my $id = context_collection->insert({ name => 'Pan', home => 'Beijing' });
    my $gridfs = context_db->get_gridfs;
    ...

=head1 DESCRIPTION

MongoX is a light wrapper to L<MongoDB> driver, it provide a versy simple but handy DSL syntax.
It also will provide some usefull helpers like builtin mongoshell, you can quick work with MongoDB.

=head1 OPTIONS

MongoX takes a set of options for the class construction at compile time
as a HASH parameter to the "use" line.

As a convenience, you can pass the default connection parameters and default database,
then when MongoX import, it will apply these options to L</add_connection> and L</use_db>,
so the following code:

    use MongoX { host => 'mongodb://127.0.0.1',db => 'test' };

is equivalent to:

    use MongoX;
    add_connection host => 'mongodb://127.0.0.1';
    use_connection;
    use_db 'test';
