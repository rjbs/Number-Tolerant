use strict;
use warnings;

package Number::Tolerant::Type::less_than;
use base qw(Number::Tolerant::Type);

our $VERSION = '1.700';

sub construct { shift; { value => $_[0], max => $_[0], exclude_max => 1 } }

sub parse {
  my ($self, $string, $factory) = @_;

  my $number = $self->number_re;
  my $X = $self->variable_re;
  return $factory->new(less_than => "$1") if $string =~ m!\A$X?<\s*($number)\z!;
  return $factory->new(less_than => "$1") if $string =~ m!\A($number)\s*>$X\z!;

  return $factory->new(less_than => "$1")
    if $string =~ m!\Aless\s+than\s+($number)\z!;

  return;
}

sub valid_args {
  my $self = shift;

  return unless 2 == grep { defined } @_;

  for my $i ( [0,1], [1,0] ) {
    if (
      $_[ $i->[0] ] eq 'less_than'
      and defined (my $num = $self->normalize_number($_[ $i->[1] ]))
    ) {
      return $num;
    }
  }

  return;
}

1;
