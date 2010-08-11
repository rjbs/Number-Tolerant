use strict;
use warnings;

package Number::Tolerant::Type::offset;
use base qw(Number::Tolerant::Type);

our $VERSION = '1.700';

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

  my $lhs_number   = $self->normalize_number($_[0]);
  my $minus_number = $self->normalize_number($_[2]);
  my $plus_number  = $self->normalize_number($_[3]);

  return ($lhs_number, $minus_number, $plus_number)
    if  (grep { defined } @_) == 4
    and defined $lhs_number
    and $_[1] eq 'offset'
    and defined $minus_number
    and defined $plus_number;

  return;
}

1;
