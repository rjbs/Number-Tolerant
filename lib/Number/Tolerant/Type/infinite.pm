package Number::Tolerant::Type::infinite;
use base qw(Number::Tolerant::Type);

use strict;
use warnings;

our $VERSION = '1.52';

my $number = $Number::Tolerant::Type::number;
my $X = $Number::Tolerant::Type::X;

sub construct { shift; { value => 0 } }

sub parse { shift;
  Number::Tolerant::tolerance('infinite')
    if ($_[0] =~ m!\Aany number\z!)
}

sub valid_args { shift;
  return ($_[0]) if @_==1 and defined $_[0] and $_[0] eq 'infinite';
  return;
}

1;
