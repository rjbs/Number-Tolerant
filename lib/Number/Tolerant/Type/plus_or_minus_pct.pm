use strict;
use warnings;

package Number::Tolerant::Type::plus_or_minus_pct;
use base qw(Number::Tolerant::Type);

our $VERSION = '1.700';

sub construct { shift;
  {
    value    => $_[0],
    variance => $_[1],
    min      => $_[0] - $_[0]*($_[1]/100),
    max      => $_[0] + $_[0]*($_[1]/100)
  }
}

sub parse {
  my ($self, $string, $factory) = @_;
  my $number = $self->number_re;

  return $factory->new("$1", 'plus_or_minus_pct', "$2")
    if $string =~ m!\A($number)\s*\+/-\s*($number)%\z!;
  return;
}

sub stringify { "$_[0]->{value} +/- $_[0]->{variance}%" }

sub valid_args {
  my $self = shift;

  return unless 3 == grep { defined } @_;
  return unless $_[1] eq 'plus_or_minus_pct';

  return unless defined (my $base = $self->normalize_number($_[0]));
  return unless defined (my $var  = $self->normalize_number($_[2]));

  return ($base, $var);
}

1;
