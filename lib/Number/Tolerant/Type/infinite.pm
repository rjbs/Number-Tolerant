package Number::Tolerant::Type::infinite;
use base qw(Number::Tolerant::Type);

use strict;
use warnings;

our $VERSION = '1.550';

sub construct { shift; { value => 0 } }

sub parse { shift;
  return Number::Tolerant::tolerance('infinite')
    if ($_[0] =~ m!\Aany\s+number\z!);
  return;
}

sub valid_args { shift;
  return ($_[0]) if @_==1 and defined $_[0] and $_[0] eq 'infinite';
  return;
}

1;
