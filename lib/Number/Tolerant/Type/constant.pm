use strict;
use warnings;
# ABSTRACT: a tolerance "m == n"

package
  Number::Tolerant::Type::constant;
use parent qw(Number::Tolerant::Type);

sub construct { shift; $_[0] }

sub parse {
  my $self = shift;
  return $self->normalize_number($_[0]);
}

sub valid_args {
  my $self = shift;

  my $number = $self->normalize_number($_[0]);

  return unless defined $number;

  return $number if @_ == 1;

  return;
}

1;
