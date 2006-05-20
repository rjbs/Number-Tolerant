package Number::Tolerant::Type::or_less;
use base qw(Number::Tolerant::Type);

use strict;
use warnings;

our $VERSION = '1.550';

sub construct { shift; { value => $_[0], max => $_[0] } }

sub parse {
  my $self = shift;
  my $number = $self->number_re;
  my $X = $self->variable_re;

  return Number::Tolerant::tolerance("$1", 'or_less')
    if ($_[0] =~ m!\A$X?<=\s*($number)\z!);
  return Number::Tolerant::tolerance("$1", 'or_less')
    if ($_[0] =~ m!\A($number)\s*>=$X\z!);
  return Number::Tolerant::tolerance("$1", 'or_less')
    if ($_[0] =~ m!\A($number)\s+or\s+less\z!);
  return;
}

sub valid_args {
  my $self = shift;
  my $number = $self->number_re;

  return ($_[0])
    if ((grep { defined } @_) == 2)
    and ($_[0] =~ $number) and ($_[1] eq 'or_less');
  return;
}

1;
