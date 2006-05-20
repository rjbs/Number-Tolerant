package Number::Tolerant::Type::less_than;
use base qw(Number::Tolerant::Type);

use strict;
use warnings;

our $VERSION = '1.550';

sub construct { shift; { value => $_[0], max => $_[0], exclude_max => 1 } }

sub parse {
  my $self = shift;
  my $number = $self->number_re;
  my $X = $self->variable_re;
  return Number::Tolerant::tolerance(less_than => "$1")
    if ($_[0] =~ m!\A$X?<\s*($number)\z!);
  return Number::Tolerant::tolerance(less_than => "$1")
    if ($_[0] =~ m!\A($number)\s*>$X\z!);
  return Number::Tolerant::tolerance(less_than => "$1")
    if ($_[0] =~ m!\Aless\s+than\s+($number)\z!);
  return;
}

sub valid_args {
  my $self = shift;
  my $number = $self->number_re;
  if ((grep { defined } @_) == 2) {
    return ($_[1]) if ($_[1] =~ $number) and ($_[0] eq 'less_than');
    return ($_[0]) if ($_[0] =~ $number) and ($_[1] eq 'less_than');
  }
  return;
}

1;
