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
    with_context
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

=method with_context(&@)

    
    # sandbox
    use_db 'test';
    with_context {
        use_db 'tmp_db';
        # now context db is 'tmp_db'
        ...
    };
    # context db auto restor to 'test'
    
    # temp context
    with_context {
        context_collection->do_something;
    } connection => 'id2', db => 'test2', 'collecton' => 'user';
    
    # alternate style
    my $db2 = context_connection->get_database('test2');
    with_context {
        # context db is $db2,collection is 'foo'
        print context_collection->count;
    } db => $db2, 'collection' => 'foo';

C<with_context> let you create a temporary context(sandbox) to invoke the code block.
Before execute the code block, current context will be saved, them build a temporary
context to invoke the code, after code executed, saved context will be restored.

You can explicit setup the sandbox context include connection,db,collection,
or just applied from parent container(context).

with_context allow nested, any with_context will build its context sanbox to run
the attached code block.

    use_db 'test';

    with_context {
        # context db is 'db1'
        with_context {
            # context db is 'db2'
        } db => 'db2';
        # context db restore to 'db1'
    } db => 'db1';

    # context db restore to 'test'

with_context options key:

=over

=item connection =>  connection id or L<MongoDB::Connection>

=item db =>  database name or L<MongoDB::Database>

=item connection =>  connection id or L<MongoDB::Connection>

=item collection =>  collection name or L<MongoDB::Collection>

=back

=cut

sub with_context(&@) { MongoX::Context::with_context {shift}, @_ }


sub import {
    my ( $class,   %options ) = @_;
    $class->export_to_level( 1, $class, @EXPORT );
    boot %options if %options;
}



1;
__END__

=head1 SYNOPSIS

    # quick bootstrap, add connection and switch to db:'test'
    use MongoX ( host => 'mongodb://127.0.0.1',db => 'test' );

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

MongoX is a light wrapper to L<MongoDB> driver, it provide a very simple but handy DSL syntax.
It also will provide some usefull helpers like builtin mongoshell, you can quick work with MongoDB.

=head1 OVERVIEW

MongoX takes a set of options for the class construction at compile time
as a HASH parameter to the "use" line.

As a convenience, you can pass the default connection parameters and default database,
then when MongoX import, it will apply these options to L</add_connection> and L</use_db>,
so the following code:

    use MongoX ( host => 'mongodb://127.0.0.1',db => 'test' );

is equivalent to:

    use MongoX;
    add_connection host => 'mongodb://127.0.0.1';
    use_connection;
    use_db 'test';

C<context_connection>,C<context_db>, C<context_collection> are implicit MongoDB::Connection,
MongoDB::Database and MongoDB::Collection.