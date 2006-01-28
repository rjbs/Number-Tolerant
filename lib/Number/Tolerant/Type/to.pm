package Number::Tolerant::Type::to;
use base qw(Number::Tolerant::Type);

use strict;
use warnings;

my $number = $Number::Tolerant::Type::number;
my $X = $Number::Tolerant::Type::X;

sub construct { shift;
  ($_[0],$_[1]) = sort { $a <=> $b } ($_[0],$_[1]);
  {
    value    => ($_[0]+$_[1])/2,
    variance => $_[1] - ($_[0]+$_[1])/2,
    min      => $_[0],
    max      => $_[1]
  }
}

sub parse { shift;
  return Number::Tolerant::tolerance("$1", 'to', "$2")
    if ($_[0] =~ m!\A($number)\s*<=$X<=\s*($number)\z!);
  return Number::Tolerant::tolerance("$2", 'to', "$1")
    if ($_[0] =~ m!\A($number)\s*>=$X>=\s*($number)\z!);
  return Number::Tolerant::tolerance("$1", 'to', "$2")
    if ($_[0] =~ m!\A($number) to ($number)\z!)
}

sub valid_args { shift;
  return ($_[0],$_[2])
    if ((grep { defined } @_) == 3)
    and ($_[0] =~ $number) and ($_[1] eq 'to') and ($_[2] =~ $number);
  return;
}

1;
