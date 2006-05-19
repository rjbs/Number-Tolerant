package Number::Tolerant::Type::or_less;
use base qw(Number::Tolerant::Type);

use strict;
use warnings;

our $VERSION = '1.540';

my $number = $Number::Tolerant::Type::number;
my $X = $Number::Tolerant::Type::X;

sub construct { shift; { value => $_[0], max => $_[0] } }

sub parse { shift;
  return Number::Tolerant::tolerance("$1", 'or_less')
    if ($_[0] =~ m!\A$X?<=\s*($number)\z!);
  return Number::Tolerant::tolerance("$1", 'or_less')
    if ($_[0] =~ m!\A($number)\s*>=$X\z!);
  return Number::Tolerant::tolerance("$1", 'or_less')
    if ($_[0] =~ m!\A($number)\s+or\s+less\z!);
  return;
}

sub valid_args { shift;
  return ($_[0])
    if ((grep { defined } @_) == 2)
    and ($_[0] =~ $number) and ($_[1] eq 'or_less');
  return;
}

1;
