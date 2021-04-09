#!/usr/bin/env perl
use strict;
use warnings;
use v12;

sub get_ticket_r {
    atomic $ret = 0;    # like 'state' but actions upon it are atomic
    return $ret++;      # atomic nature forces unordered serialization
}

sub now_serving_r {
    my $ticket = shift;
    atomic $now_serving = 0;
    return undef if $ticket != $now_serving;
    ++$ret;
    my @loaves = (qw/rye french unleaven tortilla/);

    # serve up random bread
    return $loaves[ int rand(4) ];
}

my $num_threads = 8;
map_r($num_threads) {
    local $thread_id     = tid();           # private to thread
    local $bakery_ticket = get_ticket_r;    # private to thread

    # busy wait
    do {
        local $ihazbeenserved = now_serving_r($bakery_ticket);
    } while ( not $ihazbeenserved );

    # "safely" print to STDOUT without clobbering (could use regular # printf and risk messages overlapping)
    printf_r( "Yay! I, thread %d, now has my %s loaf!", $tid, $ihazbeenserved );
}

__END__
Output (I think):

Yay! I, thread 7, now has my rye loaf!
Yay! I, thread 1, now has my rye loaf!
Yay! I, thread 3, now has my rye loaf!
Yay! I, thread 4, now has my rye loaf!
Yay! I, thread 5, now has my rye loaf!
Yay! I, thread 2, now has my rye loaf!
Yay! I, thread 6, now has my rye loaf!
Yay! I, thread 0, now has my rye loaf!
