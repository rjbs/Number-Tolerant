use Test::More;

use strict;
use warnings;

BEGIN {
  if ($^V lt v5.10.0) {
    plan skip_all => "switch only in Perl 5.10 and newer";
    exit;
  }
}
use feature qw<switch>;

use Number::Tolerant;

my $range = Number::Tolerant->new(4.75 => offset => (-0.25, 0.75));

guess($range, 5, 1);
guess($range, 5.5, 1);
guess($range, 5.6, 0);
guess($range, 4.5, 1);
guess($range, 4.4, 0);

sub guess {
  my ($range, $guess, $should_match) = @_;

  my $verb = $should_match ? 'matches' : q[doesn't match];
  my $msg = "guess $guess $verb $range in when";

  given ($guess) {
    when ($range) {
      ok $should_match, $msg;
    }
    default {
      ok !$should_match, $msg;
    }
  }

}

done_testing;
