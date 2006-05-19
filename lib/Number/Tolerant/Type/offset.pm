package Number::Tolerant::Type::offset;
use base qw(Number::Tolerant::Type);

use strict;
use warnings;

our $VERSION = '1.540';

my $number = $Number::Tolerant::Type::number;
my $X = $Number::Tolerant::Type::X;

sub construct { shift;
  {
    value => $_[0],
    min   => $_[0] + $_[1],
    max   => $_[0] + $_[2]
  }
}

sub parse {
  my (undef, $string) = @_;

  return Number::Tolerant::tolerance("$1", 'offset', "$2", "$3")
    if ($string =~ m!\A($number)\s+\(?\s*($number)\s+($number)\s*\)?\s*\z!);

  return;
}

sub stringify {
  my ($self) = @_;
  return sprintf "%s (-%s +%s)",
    $_[0]->{value},
    ($_[0]->{value} - $_[0]->{min}),
    ($_[0]->{max} - $_[0]->{value});
}

sub valid_args { shift;
  return ($_[0],$_[2], $_[3])
    if  (grep { defined } @_) == 4
    and $_[0] =~ $number
    and $_[1] eq 'offset'
    and $_[2] =~ $number
    and $_[3] =~ $number;

  return;
}

1;
