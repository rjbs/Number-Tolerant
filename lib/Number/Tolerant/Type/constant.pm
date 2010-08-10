use strict;
use warnings;

package Number::Tolerant::Type::constant;
use base qw(Number::Tolerant::Type);

our $VERSION = '1.601';

sub construct { shift; $_[0] }

sub parse {
  my $self = shift;
  my $number = $self->anchored_number_re;
  return $_[0] if $_[0] =~ $number;
  return;
}

sub valid_args {
  my $self = shift;
  my $number = $self->anchored_number_re;
  return $_[0] if @_==1 and defined $_[0] and $_[0] =~ $number;
  return;
}

1;
