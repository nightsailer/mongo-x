use strict;
use warnings;

use Test::More tests => 22;

use MongoX::Context;

MongoX::Context::add_connection host => 'mongodb://127.0.0.1';

isa_ok(MongoX::Context::get_connection('default'),'MongoDB::Connection');

ok(!defined MongoX::Context::context_connection,'context connection is null first');
MongoX::Context::use_connection;
isa_ok(MongoX::Context::context_connection,'MongoDB::Connection');

MongoX::Context::use_db 'test';
isa_ok(MongoX::Context::context_db,'MongoDB::Database');
is(MongoX::Context::context_db->name,'test','switch context db');

my $col =MongoX::Context::use_collection 'foo';
my $col2 = MongoX::Context::context_collection;

is($col,$col2, 'switch context collection');

# reset
{
    MongoX::Context::reset;
    is(MongoX::Context::context_db,undef,'reset/db');
    is(MongoX::Context::context_connection,undef,'reset/connection');
    is(MongoX::Context::context_collection,undef,'reset/collection');
}

# quick boot
{
    MongoX::Context::boot host => 'mongodb://127.0.0.1',db => 'foo2';
    ok(MongoX::Context::context_connection,'boot/use_connection');
    is(MongoX::Context::context_db->name,'foo2','boot/use_db');
}

# with_context
{
    MongoX::Context::reset;
    MongoX::Context::boot host => 'mongodb://127.0.0.1',db => 'test';
    MongoX::Context::with_context {
        MongoX::Context::use_db 'test2';
        MongoX::Context::use_collection 'foo';
    };
    is(MongoX::Context::context_connection->host,'mongodb://127.0.0.1','with_context/sandbox/connection');
    is(MongoX::Context::context_db->name,'test','with_context/sandbox/db');
    is(MongoX::Context::context_collection,undef,'with_context/sandbox/collection');
    
    MongoX::Context::with_context {
        is(MongoX::Context::context_db->name,'test2','with_context/switch new db');
        is(MongoX::Context::context_collection->name,'foo','with_context/switch new collection');
    } db => 'test2', collection => 'foo';

    MongoX::Context::with_context {
        MongoX::Context::use_db 'test1';
        MongoX::Context::with_context {
            is(MongoX::Context::context_db->name,'test2','with_context/nested/db');
            is(MongoX::Context::context_collection->name,'foo2','with_context/nested/collection');
            
            MongoX::Context::use_db 'test4';
            
        } db => 'test2',collection => 'foo2';
        is(MongoX::Context::context_db->name,'test1','with_context/nested/restore db,inner');
        is(MongoX::Context::context_collection->name,'foo1','with_context/nested/restor collection,inner');
    } collection => 'foo1';
    
    is(MongoX::Context::context_db->name,'test','with_context/sandbox/restor db,outer');
    is(MongoX::Context::context_collection,undef,'with_context/sandbox/restor collection,outer');
}