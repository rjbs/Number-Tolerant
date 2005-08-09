package Number::Tolerant::BasicTypes;
our $VERSION = "1.40";

use strict;
use warnings;

use Carp;
use Number::Tolerant;

=head1 NAME

Number::Tolerant::BasicTypes -- basic built-in tolerance types

=head1 VERSION

version 1.40

 $Id: BasicTypes.pm,v 1.4 2004/12/07 20:30:31 rjbs Exp $

=head1 SYNOPSIS

 use Number::Tolerant;

 my $range  = tolerance(10 => to => 12);
 my $random = 10 + rand(2);

 die "I shouldn't die" unless $random == $range;

 print "This line will always print.\n";

=head1 DESCRIPTION

This module is used by Number::Tolerant to configure its basic built-in
tolerance types.

=cut

our $number = Number::Tolerant->_number_re;
our $X      = qr/(?:\s*x\s*)/;

package Number::Tolerant::Type::constant;
use base qw(Number::Tolerant);

sub construct { shift; $_[0] }

sub parse { shift; $_[0] if ($_[0] =~ m!\A($number)\Z!) }

sub valid_args { shift;
	return $_[0] if @_==1 and defined $_[0] and $_[0] =~ $number;
	return
}

Number::Tolerant->_tolerance_type->{'Number::Tolerant::Type::constant'} = 1;

package Number::Tolerant::Type::plus_or_minus;
use base qw(Number::Tolerant);

sub construct { shift;
	{
		value => $_[0],
		variance => $_[1],
		min => $_[0] - $_[1],
		max => $_[0] + $_[1]
	}
}

sub parse { shift;
	Number::Tolerant::tolerance("$1", 'plus_or_minus', "$2")
		if ($_[0] =~ m!\A($number) \+/- ($number)\Z!)
}

sub stringify { "$_[0]->{value} +/- $_[0]->{variance}"  }

sub valid_args { shift;
	return ($_[0],$_[2])
		if ((grep { defined } @_) == 3)
		and ($_[0] =~ $number)
		and ($_[1] eq 'plus_or_minus')
		and ($_[2] =~ $number);
	return;
}

Number::Tolerant->_tolerance_type->{'Number::Tolerant::Type::plus_or_minus'} = 1;

package Number::Tolerant::Type::plus_or_minus_pct;
use base qw(Number::Tolerant);

sub construct { shift;
	{
		value    => $_[0],
		variance => $_[1],
		min      => $_[0] - $_[0]*($_[1]/100),
		max      => $_[0] + $_[0]*($_[1]/100)
	}
}

sub parse { shift;
	Number::Tolerant::tolerance("$1", 'plus_or_minus_pct', "$2")
		if ($_[0] =~ m!\A($number) \+/- ($number)%\Z!) 
}

sub stringify { "$_[0]->{value} +/- $_[0]->{variance}%" }

sub valid_args { shift;
	return ($_[0],$_[2])
		if ((grep { defined } @_) == 3)
		and ($_[0] =~ $number)
		and ($_[1] eq 'plus_or_minus_pct')
		and ($_[2] =~ $number);
	return;
}

Number::Tolerant->_tolerance_type->{'Number::Tolerant::Type::plus_or_minus_pct'} = 1;

package Number::Tolerant::Type::or_more;
use base qw(Number::Tolerant);

sub construct { shift; { value => $_[0], min => $_[0] } }

sub parse { shift; 
	return Number::Tolerant::tolerance("$1", 'or_more')
		if ($_[0] =~ m!\A($number)\s*<=$X\Z!);
	return Number::Tolerant::tolerance("$1", 'or_more')
		if ($_[0] =~ m!\A$X?>=\s*($number)\Z!);
	return Number::Tolerant::tolerance("$1", 'or_more')
		if ($_[0] =~ m!\A($number) or more\Z!);
}

sub valid_args { shift;
	return ($_[0])
		if ((grep { defined } @_) == 2)
		and ($_[0] =~ $number) and ($_[1] eq 'or_more');
	return;
}

Number::Tolerant->_tolerance_type->{'Number::Tolerant::Type::or_more'} = 1;

package Number::Tolerant::Type::more_than;
use base qw(Number::Tolerant);

sub construct { shift; { value => $_[0], min => $_[0], exclude_min => 1 } }

sub parse { shift;
	return Number::Tolerant::tolerance(more_than => "$1")
		if ($_[0] =~ m!\A($number)\s*<$X\Z!);
	return Number::Tolerant::tolerance(more_than => "$1")
		if ($_[0] =~ m!\A$X?>\s*($number)\Z!);
	return Number::Tolerant::tolerance(more_than => "$1")
		if ($_[0] =~ m!\Amore than ($number)\Z!);
}

sub valid_args { shift;
	if ((grep { defined } @_) == 2) {
		return ($_[1]) if ($_[1] =~ $number) and ($_[0] eq 'more_than');
		return ($_[0]) if ($_[0] =~ $number) and ($_[1] eq 'more_than');
	}
	return;
}

Number::Tolerant->_tolerance_type->{'Number::Tolerant::Type::more_than'} = 1;

package Number::Tolerant::Type::or_less;
use base qw(Number::Tolerant);

sub construct { shift; { value => $_[0], max => $_[0] } }

sub parse { shift;
	return Number::Tolerant::tolerance("$1", 'or_less')
		if ($_[0] =~ m!\A$X?<=\s*($number)\Z!);
	return Number::Tolerant::tolerance("$1", 'or_less')
		if ($_[0] =~ m!\A($number)\s*>=$X\Z!);
	return Number::Tolerant::tolerance("$1", 'or_less')
		if ($_[0] =~ m!\A($number) or less\Z!);
}

sub valid_args { shift;
	return ($_[0])
		if ((grep { defined } @_) == 2)
		and ($_[0] =~ $number) and ($_[1] eq 'or_less');
	return;
}

Number::Tolerant->_tolerance_type->{'Number::Tolerant::Type::or_less'} = 1;

package Number::Tolerant::Type::less_than;
use base qw(Number::Tolerant);

sub construct { shift; { value => $_[0], max => $_[0], exclude_max => 1 } }

sub parse { shift;
	return Number::Tolerant::tolerance(less_than => "$1")
		if ($_[0] =~ m!\A$X?<\s*($number)\Z!);
	return Number::Tolerant::tolerance(less_than => "$1")
		if ($_[0] =~ m!\A($number)>$X\Z!);
	return Number::Tolerant::tolerance(less_than => "$1")
		if ($_[0] =~ m!\Aless than ($number)\Z!);
}

sub valid_args { shift;
	if ((grep { defined } @_) == 2) {
		return ($_[1]) if ($_[1] =~ $number) and ($_[0] eq 'less_than');
		return ($_[0]) if ($_[0] =~ $number) and ($_[1] eq 'less_than');
	}
	return;
}

Number::Tolerant->_tolerance_type->{'Number::Tolerant::Type::less_than'} = 1;

package Number::Tolerant::Type::to;
use base qw(Number::Tolerant);

sub construct { shift;
	($_[0],$_[1]) = sort { $a <=> $b } ($_[0],$_[1]);
	{
		value    => ($_[0]+$_[1])/2,
		variance => $_[1] - ($_[0]+$_[1])/2,
		min      => $_[0],
		max      => $_[1]
	}
}

sub parse { shift;
	return Number::Tolerant::tolerance("$1", 'to', "$2")
		if ($_[0] =~ m!\A($number)\s*<=$X<=\s*($number)\Z!);
	return Number::Tolerant::tolerance("$2", 'to', "$1")
		if ($_[0] =~ m!\A($number)\s*>=$X>=\s*($number)\Z!);
	return Number::Tolerant::tolerance("$1", 'to', "$2")
		if ($_[0] =~ m!\A($number) to ($number)\Z!)
}

sub valid_args { shift;
	return ($_[0],$_[2])
		if ((grep { defined } @_) == 3)
		and ($_[0] =~ $number) and ($_[1] eq 'to') and ($_[2] =~ $number);
	return;
}

Number::Tolerant->_tolerance_type->{'Number::Tolerant::Type::to'} = 1;

package Number::Tolerant::Type::infinite;
use base qw(Number::Tolerant);

sub construct { shift; { value => 0 } }

sub parse { shift;
	Number::Tolerant::tolerance('infinite')
		if ($_[0] =~ m!\Aany number\Z!)
}

sub valid_args { shift;
	return ($_[0]) if @_==1 and defined $_[0] and $_[0] eq 'infinite';
	return;
}

Number::Tolerant->_tolerance_type->{'Number::Tolerant::Type::infinite'}= 1;

=head1 TODO

=head1 SEE ALSO

=head1 AUTHOR

Ricardo SIGNES, E<lt>rjbs@cpan.orgE<gt>

=head1 COPYRIGHT

(C) 2004, Ricardo SIGNES.  Number::Tolerant is available under the same terms
as Perl itself.

=cut

1;
