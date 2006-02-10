package Number::Tolerant::Type::plus_or_minus_pct;
use base qw(Number::Tolerant::Type);

use strict;
use warnings;

our $VERSION = '1.52';

my $number = $Number::Tolerant::Type::number;
my $X = $Number::Tolerant::Type::X;

sub construct { shift;
  {
    value    => $_[0],
    variance => $_[1],
    min      => $_[0] - $_[0]*($_[1]/100),
    max      => $_[0] + $_[0]*($_[1]/100)
  }
}

sub parse { shift;
  Number::Tolerant::tolerance("$1", 'plus_or_minus_pct', "$2")
    if ($_[0] =~ m!\A($number) \+/- ($number)%\z!) 
}

sub stringify { "$_[0]->{value} +/- $_[0]->{variance}%" }

sub valid_args { shift;
  return ($_[0],$_[2])
    if ((grep { defined } @_) == 3)
    and ($_[0] =~ $number)
    and ($_[1] eq 'plus_or_minus_pct')
    and ($_[2] =~ $number);
  return;
}

1;
