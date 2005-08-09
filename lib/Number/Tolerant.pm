package Number::Tolerant;
our $VERSION = "1.42";

use strict;
use warnings;

use base qw(Exporter);
our @EXPORT = qw(tolerance);

use Carp;

=head1 NAME

Number::Tolerant -- tolerance ranges for inexact numbers

=head1 VERSION

version 1.42

 $Id: Tolerant.pm,v 1.30 2004/12/08 19:19:20 rjbs Exp $

=head1 SYNOPSIS

 use Number::Tolerant;

 my $range  = tolerance(10 => to => 12);
 my $random = 10 + rand(2);

 die "I shouldn't die" unless $random == $range;

 print "This line will always print.\n";

=head1 DESCRIPTION

Number::Tolerant creates a number-like object whose value refers to a range of
possible values, each equally acceptable.  It overloads comparison operations
to reflect this.

I use this module to simplify the comparison of measurement results to
specified tolerances.

 reject $product unless $measurement == $specification;

=head1 METHODS

=head2 Instantiation

=head3 C<< Number::Tolerance->new( ... ) >>

=head3 C<< tolerance( ... ) >>

There is a C<new> method on the Number::Tolerant class, but it also exports a
simple function, C<tolerance>, which will return an object of the
Number::Tolerant class.  Both use the same syntax:

 my $range = tolerance( $x => $method => $y);

The meaning of C<$x> and C<$y> are dependant on the value of C<$method>, which
describes the nature of the tolerance.  Tolerances can be defined in five ways,
at present:

  method              range
 -------------------+------------------
  plus_or_minus     | x ± y
  plus_or_minus_pct | x ± (y% of x)
  or_more           | x to Inf
  or_less           | x to -Inf
  more_than         | x to Inf, not x
  less_than         | x to -Inf, not x
  to                | x to y
  infinite          | -Inf to Inf

For C<or_less> and C<or_more>, C<$y> is ignored if passed.  For C<infinite>,
neither C<$x> nor C<$y> is used; "infinite" should be the sole argument.  The
first two arguments can be reversed for C<more_than> and C<less_than>, to be
more English-like.

=cut

my $number = qr/(?:[+-]?)(?=\d|\.\d)\d*(?:\.\d*)?(?:[Ee](?:[+-]?\d+))?/;
sub _number_re { $number }

my %tolerance_type = ();

sub _tolerance_type { \%tolerance_type }
require Number::Tolerant::BasicTypes;

sub tolerance { __PACKAGE__->new(@_); }

sub new {
	my $class = shift;
	return unless @_;
	my $self;

	for my $type (keys %tolerance_type) {
		next unless $type->can('valid_args');
		next unless my @args = $type->valid_args(@_);
		my $guts = $type->construct(@args);

		return $guts unless ref $guts;

		if (
			defined $guts->{min} and defined $guts->{max} and
			$guts->{min} == $guts->{max} and
			not $guts->{constant}
		) { 
			@_ = ($class, $guts->{min});
			goto &new;
		}
		$self = { method => $type, %$guts };
		last;
	}

	return unless $self;
	bless $self => $self->{method};
}

=head3 C<< from_string($stringification) >>

A new tolerance can be instantiated from the stringification of an old
tolerance.  For example:

 my $range = Number::Tolerant->from_string("10 to 12");

 die "Everything's OK!" if 11 == $range; # program dies of joy

This will I<not> yet parse stringified unions, but that will be implemented in
the future.  (I just don't need it yet.)

=cut

sub from_string {
 	my ($class, $string) = @_;
 	croak "from_string is a class method" if ref $class;
	for my $type (keys %tolerance_type) {
		next unless $type->can('parse');
		if (my $tolerance = $type->parse($string)) {
			return $tolerance;
		}
	}
	return;
}

sub stringify {
	my ($self) = @_;
	return 'any number' unless $self->{min} || $self->{max};
	my $string = '';
	if ($self->{min}) {
		$string .= "$self->{min} <" . ($self->{exclude_min} ? '' : '=') . ' ';
	}
	$string .= 'x';
	if ($self->{max}) {
		$string .= ' <' . ($self->{exclude_max} ? '' : '=') .  " $self->{max}";
	}
	return $string;
}

=head2 C<< stringify_as($type) >>

This method does nothing!  Someday, it will stringify the given tolerance as a
different type, if possible.  "10 +/- 1" will
C<stringify_as('plus_or_minus_pct')> to "10 +/- 10%" for example.

=cut

sub stringify_as { }

sub _num_eq  { not( _num_gt($_[0],$_[1]) or _num_lt($_[0],$_[1]) ) }

sub _num_ne { not _num_eq(@_) }

sub _num_gt  { $_[2] ? goto &_num_lt_canonical : goto &_num_gt_canonical }

sub _num_lt  { $_[2] ? goto &_num_gt_canonical : goto &_num_lt_canonical }

sub _num_gte { $_[1] == $_[0] ? 1 : goto &_num_gt; }

sub _num_lte { $_[1] == $_[0] ? 1 : goto &_num_lt; }

sub _num_gt_canonical {
	return 1 if $_[0]{exclude_min} and $_[0]{min} == $_[1];
	defined $_[0]->{min} ? $_[1] <  $_[0]->{min} : undef
}

sub _num_lt_canonical {
	return 1 if $_[0]{exclude_max} and $_[0]{max} == $_[1];
	defined $_[0]->{max} ? $_[1] >  $_[0]->{max} : undef
}

sub _union {
	require Number::Tolerant::Union;
	return Number::Tolerant::Union->new($_[0],$_[1]);
}

sub _intersection {
	return $_[0] == $_[1] ? $_[1] : () unless ref $_[1];

	my ($min, $max);
	my ($exclude_min, $exclude_max);

	if (defined $_[0]->{min} and defined $_[1]->{min}) {
		($min) = sort {$b<=>$a}  ($_[0]->{min}, $_[1]->{min});
	} else {
		$min = $_[0]->{min} || $_[1]->{min};
	}
	$exclude_min = 1
		if ($_[0]{min} and $min == $_[0]{min} and $_[0]{exclude_min})
		or ($_[1]{min} and $min == $_[1]{min} and $_[1]{exclude_min});

	if (defined $_[0]->{max} and defined $_[1]->{max}) {
		($max) = sort {$a<=>$b} ($_[0]->{max}, $_[1]->{max});
	} else {
		$max = $_[0]->{max} || $_[1]->{max};
	}
	$exclude_max = 1
		if ($_[0]{max} and $max == $_[0]{max} and $_[0]{exclude_max})
		or ($_[1]{max} and $max == $_[1]{max} and $_[1]{exclude_max});

	return tolerance('infinite') unless defined $min || defined $max;
	return tolerance($min => ($exclude_min ? 'more_than' : 'or_more'))
		unless defined $max;
	return tolerance($max => ($exclude_max ? 'less_than' : 'or_less'))
		unless defined $min;
	bless {
		max => $max,
		min => $min,
		exclude_max => $exclude_max,
		exclude_min => $exclude_min
	} => 'Number::Tolerant::Type::to';
}

=head2 Overloading

Tolerances overload a few operations, mostly comparisons.

=over

=item boolean

Tolerances are always true.

=item numify

Most tolerances numify to undef.

=item stringify

A tolerance stringifies to a short description of itself, generally something
like "m < x < n"

 infinite  - "any number"
 to        - "m <= x <= n"
 or_more   - "m <= x"
 or_less   - "x <= n"
 more_than - "m < x"
 less_than - "x < n"
 plus_or_minus     - "x +/- y"
 plus_or_minus_pct - "x +/- y%"

=item equality

A number is equal to a tolerance if it is neither less than nor greater than
it.  (See below).

=item comparison

A number is greater than a tolerance if it is greater than its maximum value.

A number is less than a tolerance if it is less than its minimum value.

No number is greater than an "or_more" tolerance or less than an "or_less"
tolerance.

"...or equal to" comparisons include the min/max values in the permissible
range, as common sense suggests.

=item tolerance intersection

A tolerance C<&> a tolerance or number is the intersection of the two ranges.
Intersections allow you to quickly narrow down a set of tolerances to the most
stringent intersection of values.

 tolerance(5 => to => 6) & tolerance(5.5 => to => 6.5);
 # this yields: tolerance(5.5 => to => 6)

If the given values have no intersection, C<()> is returned.

An intersection with a normal number will yield that number, if it is within
the tolerance.

=item tolerance union

A tolerance C<|> a tolerance or number is the union of the two.  Unions allow
multiple tolerances, whether they intersect or not, to be treated as one.  See
L<Number::Tolerant::Union> for more information.

=cut

use overload
	fallback => 1,
	'bool'   => sub { 1 },
	'0+'  => sub { ($_[0]{min} and $_[0]{max} and $_[0]{min} == $_[0]{max}) ? $_[0]{min} : undef },
	'<=>' => sub { $_[2] ? ($_[1] <=> $_[0]->{value}) : ($_[0]->{value} <=> $_[1]) },
	'""' => 'stringify',
	'==' => '_num_eq',
	'!=' => '_num_ne',
	'>'  => '_num_gt',
	'<'  => '_num_lt',
	'>=' => '_num_gte',
	'<=' => '_num_lte',
	'|'  => '_union',
	'&'  => '_intersection';

=back

=head2 EXTENDING

This feature is slighly experimental, but it's here.  Custom tolerance types
can be created by adding entries to the hash returned by the C<_tolerance_type>
method.  Keys are package names, and values are ignored.  (This registration
interface is all but sure to be rewritten in the near future.)

The packages should contain classes that subclass Number::Tolerant, providing
at least these methods:

 construct  - returns the reference to be blessed into the tolerance object
 parse      - used by from_string; returns the object that represents the string
              or undef, if the string doesn't represent this kind of tolerance
 valid_args - passed args from ->new() or tolerance(); if they indicate this 
              type of tolerance, this sub returns args to be passed to
              construct

The Number::Tolerant constructor looks through the list of packages for one
whose C<valid_args> likes the arguments passed to the constructor.  That
package's C<construct> is used to build the guts of the object.  (This is a
simplification; some other logic is applied, including passing literal numbers
through unblessed by default.)

=head1 TODO

Extend C<from_string> to cover unions.

Extend C<from_string> to include Number::Range-type specifications.

Allow translation into forms not originally used:

 $range = tolerance(9 => to => 17); 
 $range->convert_to('plus_minus');
 $range->stringify_as('plus_minus_pct');

C<stringify_as> can be faked, for a few tolerance types, with something like
this:

 Number::Tolerance->_tolerance_type->{'destination_type'}->stringify($range);

Besides being ugly, it's a side-effect that isn't tested or guaranteed to work
very often.

=head1 SEE ALSO

The module L<Number::Range> provides another way to deal with ranges of
numbers.  The major differences are: N::R is set-like, not range-like; N::R
does not overload any operators.  Number::Tolerant will not (like N::R) attempt
to parse a textual range specification like "1..2,5,7..10" unless specifically
instructed to.  (The valid formats for strings passed to C<from_string> does
not match Number::Range exactly.  See TODO.)

The C<Number::Range> code:

 $range = Number::Range->new("10..15","20..25");

Is equivalent to the C<Number::Tolerant> code:

 $range = Number::Tolerant::Union->new(10..15,20..25);

...while the following code expresses an actual range:

 $range = tolerance(10 => to => 15) | tolerance(20 => to => 25);

=head1 THANKS

Thanks to Yuval Kogman and #perl-qa for helping find the bizarre bug that drove
the minimum required perl up to 5.8

=head1 AUTHOR

Ricardo SIGNES, E<lt>rjbs@cpan.orgE<gt>

=head1 COPYRIGHT

(C) 2004, Ricardo SIGNES.  Number::Tolerant is available under the same terms
as Perl itself.

=cut

"1 ± 0";
