use strict;
use warnings;
use Test::More tests => 5;

use MongoX host => 'mongodb://127.0.0.1', db => 'mongox_test' ;

isa_ok(context_connection,'MongoDB::Connection');
isa_ok(context_db,'MongoDB::Database');


use_collection 'foo2';
isa_ok(context_collection, 'MongoDB::Collection');
is(context_collection->name,'foo2','use_collection');

context_db->drop();

use_db 'mongox_test2';
is(context_db->name,'mongox_test2','use_db');

context_db->drop();

