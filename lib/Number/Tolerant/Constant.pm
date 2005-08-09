package Number::Tolerant::Constant;
use base qw(Number::Tolerant);
our $VERSION = "1.40";

use strict;
use warnings;

=head1 NAME

Number::Tolerant::Constant -- a blessed constant type

=head1 VERSION

version 1.40

 $Id: Constant.pm,v 1.3 2004/12/07 20:46:29 rjbs Exp $

=head1 SYNOPSIS

 use Number::Tolerant;
 use Number::Tolerant::Constant;

 my $range  = tolerance(10);
 ref $range; # "Number::Tolerant" -- w/o ::Constant, would be undef

=head1 DESCRIPTION

When Number::Tolerant is about to return a tolerance with zero variation, it
will return a constant instead.  This module will register a constant type that
will catch these constants and return them as Number::Tolerant objects.

I wrote this module to make it simpler to use tolerances with Class::DBI, which
would otherwise complain that the constructor hadn't returned a blessed object.

=cut

my $number = Number::Tolerant->_number_re;

package Number::Tolerant::Type::constant;
no warnings 'redefine';

sub construct { shift;
	{ value => $_[0], min => $_[0], max => $_[0], constant => 1 }
};

sub parse { shift; $_[0] if ($_[0] =~ m!\A($number)\Z!) }

sub stringify { $_[0]->{value} }

sub valid_args { shift;
	return $_[0] if @_==1 and $_[0] =~ $number;
	return
}

=head1 TODO

=head1 AUTHOR

Ricardo SIGNES, E<lt>rjbs@cpan.orgE<gt>

=head1 COPYRIGHT

(C) 2004, Ricardo SIGNES.  Number::Tolerant::Constant is available under the
same terms as Perl itself.

=cut

1;
