#!/usr/bin/env perl
use strict;    # might be moot by now
use warnings;  # might be moot by now
use v12;       # yup

my $parent_var = q{hi};

# NOTE: in OpenMP, 'atomic' is a region; here it's just a non-ref scalar (I guess could be more)
# https://www.openmp.org/spec-html/5.0/openmpsu95.html
# also being used in this example as a 'barrier' - https://www.openmp.org/spec-html/5.0/openmpsu90.html
atomic $atm_wait_my_turn = 0;

# NOTE: I reference OpenMP a lot; I just do so because it's a very well tested abstraction of an easy
# to access threaded 'fork'/'join' model that is consistent with the environment perl is providing

# scalar reference to a thread safe array
my_r $mailbox_rref = [];

my $NUM_THREADS = 8;

# begin threaded section ("thread scope")
map_r($NUM_THREADS) {
    # NOTE: 'atomic', 'my_r' are not available in 'thread scope'

    # NOTE: 'local' - used to initialize local variable with a extra-thread scope; potential optimization - 'copy on write'
    local $thread_var = $parent_var;

    # ... do something with $thread_var to trigger COW as a thread scope variable

    # thread private via 'my'
    my $thread_id = tid(); # tid() being meaninful only inside of a thread scope

    # safe (via $thread_id coordination) update of elements in thread safe anonymous array
    $mailbox_rref->[$thread_id] = qq{Hello from thread # $thread_id};

    # throw some substantial jitter in threads arriving to the barrier below
    sleep int rand(5);

    # $wait_my_turn, an 'atomic' scalar is acting as a barrier here - threads
    # get here in any order, but necessarily have to wait their turn to proceed
    $atm_wait_my_turn++;
   
    #...threads do some more stuff

}
# end of thread scope is an implicit barrier (e.g., 'wait')
# NOTE: all thread scope variables are destroyed when the thread is destroyed;
# above those variables would be: $thread_var, $thread_id

# $wait_my_turn survives, and has a value equal to the number of threads that
# encountered it

print qq{$atm_wait_my_turn threads just wrapped up, and boy are my caches tired!\n\n};

# outside of threaded scope
foreach my $msg (@$mailbox_rref) {
    say $msg;
}

__END__
Output (I think):

8 threads just wrapped up, and boy are my caches tired!

Hello from thread # 0
Hello from thread # 1
Hello from thread # 2
Hello from thread # 3
Hello from thread # 4
Hello from thread # 5
Hello from thread # 6
Hello from thread # 7 
