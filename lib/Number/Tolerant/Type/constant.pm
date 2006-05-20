package Number::Tolerant::Type::constant;
use base qw(Number::Tolerant::Type);

use strict;
use warnings;

our $VERSION = '1.550';

sub construct { shift; $_[0] }

sub parse {
  my $self = shift;
  my $number = $self->number_re;
  return $_[0] if ($_[0] =~ m!\A($number)\z!);
  return;
}

sub valid_args {
  my $self = shift;
  my $number = $self->number_re;
  return $_[0] if @_==1 and defined $_[0] and $_[0] =~ m!\A($number)\z!;
  return;
}

1;
