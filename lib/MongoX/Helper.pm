package MongoX::Helper;
# ABSTRACT: implements some common Mongo shell helpers.
use strict;
use warnings;

use Carp 'croak';
use namespace::autoclean;

use Tie::IxHash;
use MongoX::Context;
use Any::Moose;


# private
sub _db { MongoX::Context::context_db }

sub _connection { MongoX::Context::context_connection }

sub _collection { MongoX::Context::context_collection }

=method admin_fsync_lock

    my $ok = admin_fsync_lock;

call fsync_lock on current server.

=cut

sub admin_fsync_lock {
    _connection->get_database('admin')->run_command(Tie::IxHash->new('fsync' => 1, 'lock' => 1));
    return 1;
}

=method admin_unlock

    my $ok = admin_unlock;
    
call unlock on current server.

=cut

sub admin_unlock {
    my $result = _connection->get_database('admin')->get_collection('$cmd.sys.unlock')->find_one();
    return $result->{ok} ? 1: 0;
}

=method admin_repair_db

    my $ok = admin_repair_db;

Repair current database.

=cut

sub admin_repair_db { _db->run_command({ repairDatabase => 1}) }

=method admin_server_stats

    my $stats_info = admin_server_stats;

Return current mongoDB server stats.

=cut

sub admin_server_stats { }

=method admin_shutdown_server

    $ok = admin_shutdown_server;

Shutdown current mongodb server.

=cut

sub admin_shutdown_server { }

=method admin_remove_user($username)

    $ok = admin_remove_user $username;

Remove given user from current database.

=cut

sub admin_remove_user { }

=method admin

    my $repl_info = admin_get_replication_info;

Get current server replication infomation;

=cut

sub admin_get_replication_info { }

=method admin_get_sister_db

    $sister_db = admin_get_sister_db;

Get sisiter database if any.

=cut

sub admin_get_sister_db { }

=method admin_auth

    $ok = admin_auth;

Do authetication with given username and password.

=cut

sub admin_auth { }

=method admin_clone_database

    $ok = admin_clone_database;

Clone a database from the host into this server.

=cut

sub admin_clone_database { }

=method admin_copy_database

    $ok = admin_copy_database;

Copy a database to another.

=cut

sub admin_copy_database { }

=method admin_sharding_status

    $stats_info = admin_sharding_status;

Get sharding status.

=cut

sub admin_sharding_status { }

=method admin_set_profiling_level

    $ok = admin_set_profiling_level 0;

Set profiling level.

=cut

sub admin_set_profiling_level { }

=method admin_add_clone_source

    $ok = admin_add_clone_source $host;

Add another host into current clone sources list.

=cut

sub admin_add_clone_source { }

=method db_stats

    my $stats_info = db_stats;

Return current database stats information;

=cut

sub db_stats { }

=method db_eval($code,$args?)

    my $result = db_eval '';

Run code server-side.

=cut

sub db_eval { }

=method db_current_op

    my $op = db_current_op;

Return current operation in the db.

=cut

sub db_current_op {
    _connection->get_database('local')->get_collection('$cmd.sys.inprog')->find_one();
}

=method db_kill_op

    my $ok = db_kill_op;

kills the current operation in the db 

=cut

sub db_kill_op { }

=method db_distinct

    $result = db_distinct;

Performance a distinct query.

=cut

sub db_distinct { }

=method db_group

    $result = db_group

Do group query on current collection.

=cut

sub db_group { }

=method db_command

    $result = db_command;

Run the command on current database. shortcut of L<MongoDB::Database/run_command>.

=cut

sub db_command { _db->run_command(@_) }


=method db_find_and_modify($options)

    my $next_val = db_find_and_modify {
        query => { _id => 'foo'},
        update => { '$inc' => { value => 1 } }
    }
    
    # simply remove the object to be returned
    my $obj = db_find_and_modify({
        query => { _id => 10 },
        remove => 1
    });

MongoDB 1.3+ supports  a "find, modify, and return" command.
This command can be used to atomically modify a document (at most one) and return it.
B<Note:that the document returned will not include the modifications made on the update>.
The options can include 'sort' option which is useful when storing queue-like data.

=head3 option parameters

At least one of the update or remove parameters is required; the other arguments are optional.

=over

=item C<query>

A query selector document for matching the desired document. default is {}.

=item C<sort>

if multiple docs match, choose the first one in the specified sort order as the object to manipulate. default is {}.

=item C<remove => boolean>

set to a true to remove the object before returning. default is false.

=item C<update>

a modifier object.  default is undef.

=item C<new => boolean>

set to true if you want to return the modified object rather than the original. Ignored for remove. default is false.

=back

=cut

sub db_find_and_modify {
    my ($options) = @_;

    my $cmd = Tie::IxHash->new(findandmodify => context_collection->name );

    $cmd->Push(query => $options->{query} || {});
    $cmd->Push(new => $options->{new}) if exists $options->{new};
    $cmd->Push(remove => $options->{remove}) if exists $options->{remove};
    $cmd->Push(update => $options->{update}) if exists $options->{update};
    $cmd->Push(sort => $options->{sort}) if exists $options->{sort};

    my $result;

    eval {
        $result = db_command($cmd);
    };
    if ($@) {
        croak $@;
    }
    unless (ref $result) {
        if ($result eq 'No matching object found') {
            return {};
        }
        croak $result;
    }
    return $result->{value};
}



=method db_find

    

=cut

=method db_count

    

=cut

=method db_increment

    

=cut

=method db_decrement

    

=cut

=method db_upsert

    

=cut

=method db_update_set

    

=cut


=method db_update

    

=cut


1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION
