use strict;
use warnings;
use Test::More tests => 10;

use MongoX host => 'mongodb://127.0.0.1', db => 'mongox_test' ;
use MongoX::Context;

isa_ok(context_connection,'MongoDB::Connection');
isa_ok(context_db,'MongoDB::Database');


use_collection 'foo2';
isa_ok(context_collection, 'MongoDB::Collection');
is(context_collection->name,'foo2','use_collection');

context_db->drop();

use_db 'mongox_test2';
is(context_db->name,'mongox_test2','use_db');

context_db->drop();

# with_context
{
    
    MongoX::Context::reset;
    
    boot host => 'mongodb://127.0.0.1',db => 'mongo_test2';
    
    with_context {
        use_db 'test2';
        use_collection 'foo';
    };
    is(context_connection->host,'mongodb://127.0.0.1','with_context/sandbox/connection');
    is(context_db->name,'mongo_test2','with_context/sandbox/db');
    is(context_collection,undef,'with_context/sandbox/collection');

    with_context {
        is(context_db->name,'test2','with_context/switch new db');
        is(context_collection->name,'foo','with_context/switch new collection');
    } db => 'test2', collection => 'foo';

    with_context {
        use_db 'test1';
        with_context {
            is(context_db->name,'test2','with_context/nested/db');
            is(context_collection->name,'foo2','with_context/nested/collection');
            use_db 'test4';

        } db => 'test2',collection => 'foo2';
        is(context_db->name,'test1','with_context/nested/restore db,inner');
        is(context_collection->name,'foo1','with_context/nested/restor collection,inner');
    } collection => 'foo1';

    is(context_db->name,'mongo_test2','with_context/sandbox/restor db,outer');
    is(context_collection,undef,'with_context/sandbox/restor collection,outer');
    
    context_db->drop;
}


