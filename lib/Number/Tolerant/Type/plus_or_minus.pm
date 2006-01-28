package Number::Tolerant::Type::plus_or_minus;
use base qw(Number::Tolerant::Type);

use strict;
use warnings;

my $number = $Number::Tolerant::Type::number;
my $X = $Number::Tolerant::Type::X;

sub construct { shift;
  {
    value => $_[0],
    variance => $_[1],
    min => $_[0] - $_[1],
    max => $_[0] + $_[1]
  }
}

sub parse { shift;
  Number::Tolerant::tolerance("$1", 'plus_or_minus', "$2")
    if ($_[0] =~ m!\A($number) \+/- ($number)\z!)
}

sub stringify { "$_[0]->{value} +/- $_[0]->{variance}"  }

sub valid_args { shift;
  return ($_[0],$_[2])
    if ((grep { defined } @_) == 3)
    and ($_[0] =~ $number)
    and ($_[1] eq 'plus_or_minus')
    and ($_[2] =~ $number);
  return;
}

1;
