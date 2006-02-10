package Number::Tolerant::Type::more_than;
use base qw(Number::Tolerant::Type);

use strict;
use warnings;

our $VERSION = '1.52';

my $number = $Number::Tolerant::Type::number;
my $X = $Number::Tolerant::Type::X;

sub construct { shift; { value => $_[0], min => $_[0], exclude_min => 1 } }

sub parse { shift;
  return Number::Tolerant::tolerance(more_than => "$1")
    if ($_[0] =~ m!\A($number)\s*<$X\z!);
  return Number::Tolerant::tolerance(more_than => "$1")
    if ($_[0] =~ m!\A$X?>\s*($number)\z!);
  return Number::Tolerant::tolerance(more_than => "$1")
    if ($_[0] =~ m!\Amore than ($number)\z!);
}

sub valid_args { shift;
  if ((grep { defined } @_) == 2) {
    return ($_[1]) if ($_[1] =~ $number) and ($_[0] eq 'more_than');
    return ($_[0]) if ($_[0] =~ $number) and ($_[1] eq 'more_than');
  }
  return;
}

1;
