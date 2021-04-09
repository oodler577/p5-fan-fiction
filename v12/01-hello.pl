#!/usr/bin/env perl
use strict;    # might be moot by now
use warnings;  # might be moot by now
use v12;       # yup

# scalar reference to a thread safe array
my_r $mailbox_rref = [];

# begin threaded section
my $NUM_THREADS = 8;
map_r($NUM_THREADS) {

    # thread private via 'local'
    local $thread_id = tid();

    # safe (via $thread_id coordination) update of elements in thread safe anonymous array
    $mailbox_rref->[$thread_id] = qq{Hello from thread # $thread_id};
}
foreach my $msg (@$mailbox_rref) {
    say $msg;
}

__END__
Output (I think):

Hello from thread # 0
Hello from thread # 1
Hello from thread # 2
Hello from thread # 3
Hello from thread # 4
Hello from thread # 5
Hello from thread # 6
Hello from thread # 7 
