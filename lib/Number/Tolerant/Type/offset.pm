use strict;
use warnings;
# ABSTRACT: a tolerance "m (-l or +n)"

package
  Number::Tolerant::Type::offset;
use parent qw(Number::Tolerant::Type);

sub construct { shift;
  {
    value => $_[0],
    min   => $_[0] + $_[1],
    max   => $_[0] + $_[2]
  }
}

sub parse {
  my ($self, $string, $factory) = @_;

  my $number = $self->number_re;
  return $factory->new("$1", 'offset', "$2", "$3")
    if $string =~ m!\A($number)\s+\(?\s*($number)\s+($number)\s*\)?\s*\z!;

  return;
}

sub stringify {
  my ($self) = @_;
  return sprintf "%s (-%s +%s)",
    $_[0]->{value},
    ($_[0]->{value} - $_[0]->{min}),
    ($_[0]->{max} - $_[0]->{value});
}

sub valid_args {
  my $self = shift;

  return if @_ > 4;

  return unless defined(my $lhs_number   = $self->normalize_number($_[0]));
  return unless defined(my $minus_number = $self->normalize_number($_[2]));
  return unless defined(my $plus_number  = $self->normalize_number($_[3]));

  return unless $_[1] eq 'offset';
  return unless $minus_number <= 0;
  return unless $plus_number  >= 0;

  return ($lhs_number, $minus_number, $plus_number)
}

1;
