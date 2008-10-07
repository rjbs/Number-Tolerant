use strict;
use warnings;

package Number::Tolerant::Type::or_more;
use base qw(Number::Tolerant::Type);

our $VERSION = '1.601';

sub construct { shift; { value => $_[0], min => $_[0] } }

sub parse { 
  my ($self, $string, $factory) = @_;
  my $number = $self->number_re;
  my $X = $self->variable_re;

  return $factory->new("$1", 'or_more') if $string =~ m!\A($number)\s*<=$X\z!;
  return $factory->new("$1", 'or_more') if $string =~ m!\A$X?>=\s*($number)\z!;
  return $factory->new("$1", 'or_more')
    if $string =~ m!\A($number)\s+or\s+more\z!;

  return;
}

sub valid_args {
  my $self = shift;
  my $number = $self->number_re;

  return ($_[0])
    if ((grep { defined } @_) == 2)
    and ($_[0] =~ $number) and ($_[1] eq 'or_more');
  return;
}

1;
