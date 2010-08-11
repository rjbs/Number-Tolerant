use strict;
use warnings;

package Number::Tolerant::Type::or_more;
use base qw(Number::Tolerant::Type);

our $VERSION = '1.700';

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

  return unless 2 == grep { defined } @_;
  return unless $_[1] eq 'or_more';

  return $self->normalize_number($_[0]);
}

1;
