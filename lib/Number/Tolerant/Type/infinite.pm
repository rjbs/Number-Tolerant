use strict;
use warnings;

package Number::Tolerant::Type::infinite;
use base qw(Number::Tolerant::Type);

our $VERSION = '1.700';

sub construct { shift; { value => 0 } }

sub parse {
  my ($self, $string, $factory) = @_;
  return $factory->new('infinite') if $string =~ m!\Aany\s+number\z!;
  return;
}

sub valid_args { shift;
  return ($_[0]) if @_ == 1 and defined $_[0] and $_[0] eq 'infinite';
  return;
}

1;
