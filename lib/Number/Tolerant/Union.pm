package Number::Tolerant::Union;
our $VERSION = "1.42";

use strict;
use warnings;

=head1 NAME

Number::Tolerant::Union -- unions of tolerance ranges

=head1 VERSION

version 1.42

 $Id: Union.pm,v 1.10 2004/12/08 19:19:20 rjbs Exp $

=head1 SYNOPSIS

 use Number::Tolerant;

 my $range1 = tolerance(10 => to => 12);
 my $range2 = tolerance(14 => to => 16);

 my $union = $range1 | $range2;

 if ($11 == $union) { ... } # this will happen
 if ($12 == $union) { ... } # so will this
 
 if ($13 == $union) { ... } # nothing will happen here

 if ($14 == $union) { ... } # this will happen
 if ($15 == $union) { ... } # so will this

=head1 DESCRIPTION

Number::Tolerant::Union is used by L<Number::Tolerant> to represent the union
of multiple tolerances.  A subset of the same operators that function on a
tolerance will function on a union of tolerances, as listed below.

=head1 METHODS

=head2 C<< Number::Tolerant::Union->new( @options ) >>

There is a C<new> method on the Number::Tolerant::Union class, but unions are
meant to be created with the C<|> operator on a Number::Tolerant tolerance.

The arguments to C<new> are a list of numbers or tolerances to be unioned.

Intersecting ranges are not converted into a single range, but this may change
in the future.  (For example, the union of "5 to 10" and "7 to 12" is not "5 to
12.")

=cut

sub new {
	my $class = shift;
	bless { options => [ @_ ] } => $class;
}

=head2 options

This method will return a list of all the acceptable options for the union.

=cut

sub options {
	my $self = shift;
	return @{$self->{options}};
}

=head2 Overloading

Tolerance unions overload a few operations, mostly comparisons.

=over

=item numification

Unions numify to undef.  If there's a better idea, I'd love to hear it.

=item stringification

A tolerance stringifies to a short description of itself.  This is a set of the
union's options, parentheses-enclosed and joined by the word "or"

=item equality

A number is equal to a union if it is equal to any of its options.

=item comparison

A number is greater than a union if it is greater than all its options.

A number is less than a union if it is less than all its options.

=item union intersection

An intersection (C<&>) with a union is commutted across all options.  In other
words:

 (a | b | c) & d  ==yields==> ((a & d) | (b & d) | (c & d))

Options that have no intersection with the new element are dropped.  The
intersection of a constant number and a union yields that number, if the number
was in the union's ranges and otherwise yields nothing.

=cut

use overload
	'0+' => sub { undef },
	'""' => sub { join(' or ', map { "($_)" } $_[0]->options) },
	'==' => sub { for ($_[0]->options) { return 1 if $_ == $_[1] } return 0 },
	'!=' => sub { for ($_[0]->options) { return 0 if $_ == $_[1] } return 1 },
	'>'  =>
		sub {
			if ($_[2]) { for ($_[0]->options) { return 0 unless $_[1] > $_ } return 1 }
			else       { for ($_[0]->options) { return 0 unless $_[1] < $_ } return 1 }
		},
	'<'  =>
		sub {
			if ($_[2]) { for ($_[0]->options) { return 0 unless $_[1] < $_ } return 1 }
			else       { for ($_[0]->options) { return 0 unless $_[1] > $_ } return 1 }
		},
	'<=>' =>
		sub {
			if ($_[2]) { $_[0] < $_[1] ? 1 : $_[0] > $_[1] ? -1 : 0 }
			else       { $_[0] > $_[1] ? 1 : $_[0] < $_[1] ? -1 : 0 }
		},
	'|' => sub { __PACKAGE__->new($_[0]->options,$_[1]); },
	'&' => sub {
		UNIVERSAL::isa($_[1],'Number::Tolerant')
			? __PACKAGE__->new(map { $_ & $_[1] } $_[0]->options )
			: $_[1] == $_[0]
				? $_[1]
				: ();
		},
	fallback => 1;

=back

=head1 TODO

Who knows.  Collapsing overlapping options, probably.

=head1 AUTHOR

Ricardo SIGNES, E<lt>rjbs@cpan.orgE<gt>

=head1 COPYRIGHT

(C) 2004, Ricardo SIGNES.  Number::Tolerant::Union is available under the same
terms as Perl itself.

=cut

1;
