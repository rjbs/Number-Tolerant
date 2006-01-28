package Number::Tolerant::Type::constant;
use base qw(Number::Tolerant::Type);

use strict;
use warnings;

my $number = $Number::Tolerant::Type::number;
my $X = $Number::Tolerant::Type::X;

sub construct { shift; $_[0] }

sub parse { shift;
  return $_[0] if ($_[0] =~ m!\A($number)\z!);
}

sub valid_args { shift;
  return $_[0] if @_==1 and defined $_[0] and $_[0] =~ m!\A($number)\z!;
  return
}

1;
