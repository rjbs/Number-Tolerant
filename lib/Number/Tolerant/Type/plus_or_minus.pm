package Number::Tolerant::Type::plus_or_minus;
use base qw(Number::Tolerant::Type);

use strict;
use warnings;

our $VERSION = '1.550';

sub construct { shift;
  {
    value => $_[0],
    variance => $_[1],
    min => $_[0] - $_[1],
    max => $_[0] + $_[1]
  }
}

sub parse {
  my $self = shift;
  my $number = $self->number_re;

  return Number::Tolerant::tolerance("$1", 'plus_or_minus', "$2")
    if ($_[0] =~ m!\A($number)\s*\+/-\s*($number)\z!);
  return;
}

sub stringify { "$_[0]->{value} +/- $_[0]->{variance}"  }

sub valid_args {
  my $self = shift;
  my $number = $self->number_re;

  return ($_[0],$_[2])
    if ((grep { defined } @_) == 3)
    and ($_[0] =~ $number)
    and ($_[1] eq 'plus_or_minus')
    and ($_[2] =~ $number);
  return;
}

1;
