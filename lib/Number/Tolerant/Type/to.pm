use strict;
use warnings;

package Number::Tolerant::Type::to;
use base qw(Number::Tolerant::Type);

our $VERSION = '1.700';

sub construct { shift;
  ($_[0],$_[1]) = sort { $a <=> $b } ($_[0],$_[1]);
  {
    value    => ($_[0]+$_[1])/2,
    variance => $_[1] - ($_[0]+$_[1])/2,
    min      => $_[0],
    max      => $_[1]
  }
}

sub parse {
  my ($self, $string, $factory) = @_;
  my $number = $self->number_re;
  my $X = $self->variable_re;

  return $factory->new("$1", 'to', "$2")
    if ($string =~ m!\A($number)\s*<=$X<=\s*($number)\z!);
  return $factory->new("$2", 'to', "$1")
    if ($string =~ m!\A($number)\s*>=$X>=\s*($number)\z!);
  return $factory->new("$1", 'to', "$2")
    if ($string =~ m!\A($number)\s+to\s+($number)\z!);
  return;
}

sub valid_args {
  my $self = shift;

  return unless 3 == grep { defined } @_;
  return unless $_[1] eq 'to';

  return unless defined (my $from = $self->normalize_number($_[0]));
  return unless defined (my $to   = $self->normalize_number($_[2]));

  return ($from, $to);
}

1;
