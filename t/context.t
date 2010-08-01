use strict;
use warnings;

use Test::More tests => 11;

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
