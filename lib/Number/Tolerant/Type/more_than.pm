use strict;
use warnings;

package Number::Tolerant::Type::more_than;
use base qw(Number::Tolerant::Type);

our $VERSION = '1.601';

sub construct { shift; { value => $_[0], min => $_[0], exclude_min => 1 } }

sub parse {
  my ($self, $string, $factory) = @_;

  my $number = $self->number_re;
  my $X = $self->variable_re;

  return $factory->new(more_than => "$1") if $string =~ m!\A($number)\s*<$X\z!;
  return $factory->new(more_than => "$1") if $string =~ m!\A$X?>\s*($number)\z!;

  return $factory->new(more_than => "$1")
    if $string =~ m!\Amore\s+than\s+($number)\z!;
  return;
}

sub valid_args {
  my $self = shift;
  my $number = $self->number_re;

  if ((grep { defined } @_) == 2) {
    return ($_[1]) if ($_[1] =~ $number) and ($_[0] eq 'more_than');
    return ($_[0]) if ($_[0] =~ $number) and ($_[1] eq 'more_than');
  }
  return;
}

1;
