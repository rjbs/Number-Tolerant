use strict;
use warnings;
package Number::Tolerant;
# ABSTRACT: tolerance ranges for inexact numbers

use Sub::Exporter::Util;
use Sub::Exporter 0.950 -setup => {
  exports => { tolerance => Sub::Exporter::Util::curry_class('new'), },
  groups  => { default   => [ qw(tolerance) ] },
};

use Carp ();
use Scalar::Util ();

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

=head3 new

=head3 tolerance

There is a C<new> method on the Number::Tolerant class, but it also exports a
simple function, C<tolerance>, which will return an object of the
Number::Tolerant class.  Both use the same syntax:

 my $range = Number::Tolerant->new( $x => $method => $y);

 my $range = tolerance( $x => $method => $y);

The meaning of C<$x> and C<$y> are dependent on the value of C<$method>, which
describes the nature of the tolerance.  Tolerances can be defined in five ways,
at present:

  method              range
 -------------------+------------------
  plus_or_minus     | x +/- y
  plus_or_minus_pct | x +/- (y% of x)
  or_more           | x to Inf
  or_less           | x to -Inf
  more_than         | x to Inf, not x
  less_than         | x to -Inf, not x
  to                | x to y
  infinite          | -Inf to Inf
  offset            | (x + y1) to (x + y2)

For C<or_less> and C<or_more>, C<$y> is ignored if passed.  For C<infinite>,
neither C<$x> nor C<$y> is used; "infinite" should be the sole argument.  The
first two arguments can be reversed for C<more_than> and C<less_than>, to be
more English-like.

Offset tolerances are slightly unusual.  Here is an example:

  my $offset_tolerance = tolerance(10 => offset => (-3, 5));
  # stringifies to: 10 (-3 +5)

An offset is very much like a C<plus_or_minus> tolerance, but its center value
is not necessarily the midpoint between its extremes.  This is significant for
comparisons and numifications of the tolerance.  Given the following two
tolerances:

  my $pm_dice = tolerance(10.5 => plus_or_minus => 7.5);
  my $os_dice = tolerance(11 => offset => (-8, 7));

The first will sort as numerically less than the second.

If the given arguments can't be formed into a tolerance, an exception will be
raised.

=cut

# these are the default plugins
my %_plugins;

sub _plugins {
  keys %_plugins
}

sub disable_plugin {
  my ($class, $plugin) = @_;
  $class->_boot_up;
  delete $_plugins{ $plugin };
  return;
}

sub enable_plugin {
  my ($class, $plugin) = @_;
  $class->_boot_up;

  # XXX: there has to be a better test to use here -- rjbs, 2006-01-27
  unless (eval { $plugin->can('construct') }) {
    eval "require $plugin" or die $@;
  }

  unless (eval { $class->validate_plugin($plugin); }) {
    Carp::croak "class $plugin is not a valid Number::Tolerant plugin: $@";
  }

  $_plugins{ $plugin } = undef;
  return;
}

sub validate_plugin {
  my ($class, $plugin) = @_;
  for (qw(parse valid_args construct)) {
    die "can't $_" unless $plugin->can($_);
  }
  return 1;
}

my $booted;
sub _boot_up {
  return if $booted;
  $booted = 1;
  my @_default_plugins =
    map { "Number::Tolerant::Type::$_" }
    qw(
      constant    infinite        less_than
      more_than   offset          or_less 
      or_more     plus_or_minus   plus_or_minus_pct
      to
    );

  __PACKAGE__->enable_plugin($_) for @_default_plugins;
}

sub new {
  my $class = shift;
  $class->_boot_up;
  return unless @_;
  my $self;

  for my $type ($class->_plugins) {
    next unless my @args = $type->valid_args(@_);
    my $guts = $type->construct(@args);

    return $guts unless ref $guts and not Scalar::Util::blessed($guts);

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

  Carp::confess("couldn't form tolerance from given args") unless $self;
  bless $self => $self->{method};
}

=head3 from_string

A new tolerance can be instantiated from the stringification of an old
tolerance.  For example:

 my $range = Number::Tolerant->from_string("10 to 12");

 die "Everything's OK!" if 11 == $range; # program dies of joy

This will I<not> yet parse stringified unions, but that will be implemented in
the future.  (I just don't need it yet.)

If a string can't be parsed, an exception is raised.

=cut

sub from_string {
  my ($class, $string) = @_;
  $class->_boot_up;
  Carp::croak "from_string is a class method" if ref $class;
  for my $type (keys %_plugins) {
    if (defined(my $tolerance = $type->parse($string, $class))) {
      return $tolerance;
    }
  }

  Carp::confess("couldn't form tolerance from given string");
}

sub stringify {
  my ($self) = @_;

  return 'any number' unless (defined $self->{min} || defined $self->{max});

  my $string = '';

  if (defined $self->{min}) {
    $string .= "$self->{min} <" . ($self->{exclude_min} ? q{} : '=') . q{ };
  }

  $string .= 'x';

  if (defined $self->{max}) {
    $string .= ' <' . ($self->{exclude_max} ? q{} : '=') .  " $self->{max}";
  }

  return $string;
}

=head2 stringify_as

  my $string = $tolerance->stringify_as($type);

This method does nothing!  Someday, it will stringify the given tolerance as a
different type, if possible.  "10 +/- 1" will
C<stringify_as('plus_or_minus_pct')> to "10 +/- 10%" for example.

=cut

sub stringify_as { }

=head2 numify

  my $n = $tolerance->numify;

This returns the numeric form of a tolerance.  If a tolerance has both a
minimum and a maximum, and they are the same, then that is the numification.
Otherwise, numify returns undef.

=cut

sub numify {
  # if a tolerance has equal min and max, it numifies to that number
  return $_[0]{min}
    if $_[0]{min} and $_[0]{max} and $_[0]{min} == $_[0]{max};
  ## no critic (ReturnUndef)
  return undef;
}

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

sub _union { $_[0]->union($_[1]); }

sub union {
  require Number::Tolerant::Union;
  return Number::Tolerant::Union->new($_[0],$_[1]);
}

sub _intersection { $_[0]->intersection($_[1]); }

sub intersection {
  if (! ref $_[1]) {
    return $_[1] if $_[0] == $_[1];
    Carp::confess "no valid intersection of ($_[0]) and ($_[1])";
  }

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

  return $_[0]->new('infinite') unless defined $min || defined $max;

  return $_[0]->new($min => ($exclude_min ? 'more_than' : 'or_more'))
    unless defined $max;

  return $_[0]->new($max => ($exclude_max ? 'less_than' : 'or_less'))
    unless defined $min;

  Carp::confess "no valid intersection of ($_[0]) and ($_[1])"
    if $max < $min or $min > $max;

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

Most tolerances numify to undef; see C<L</numify>>.

=item stringify

A tolerance stringifies to a short description of itself, generally something
like "m < x < n"

 infinite  - "any number"
 to        - "m <= x <= n"
 or_more   - "m <= x"
 or_less   - "x <= n"
 more_than - "m < x"
 less_than - "x < n"
 offset    - "x (-y1 +y2)"
 constant  - "x"
 plus_or_minus     - "x +/- y"
 plus_or_minus_pct - "x +/- y%"

=item equality

A number is equal to a tolerance if it is neither less than nor greater than
it.  (See below).

=item smart match

Same as equality.

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
  '0+'     => 'numify',
  '<=>' => sub {
    my $rv = $_[0] == $_[1] ? 0
           : $_[0] <  $_[1] ? -1
           : $_[0] >  $_[1] ? 1
           : die "impossible";
    $rv *= -1 if $_[2];
    return $rv;
  },
  '""' => 'stringify',
  '==' => '_num_eq',
  '~~' => '_num_eq',
  '!=' => '_num_ne',
  '>'  => '_num_gt',
  '<'  => '_num_lt',
  '>=' => '_num_gte',
  '<=' => '_num_lte',
  '|'  => '_union',
  '&'  => '_intersection';

=back

=head1 EXTENDING

This feature is slighly experimental, but it's here.

New tolerance types may be written as subclasses of L<Number::Tolerant::Type>,
providing the interface described in its documentation.  They can then be
enabled or disabled with the following methods:

=head2 C< enable_plugin >

  Number::Tolerant->enable_plugin($class_name);

This method enables the named class, so that attempts to create new tolerances
will check against this class.  Classes are checked against
C<L</validate_plugin>> before being enabled.  An exception is thrown if the
class does not appear to provide the Number::Tolerant::Type interface.

=head2 C< disable_plugin >

  Number::Tolerant->disable_plugin($class_name);

This method will disable the named class, so that future attempts to create new
tolerances will not check against this class.

=head2 C< validate_plugin >

  Number::Tolerant->validate_plugin($class_name);

This method checks (naively) that the given class provides the interface
defined in Number::Tolerant::Type.  If it does not, an exception is thrown.

=head1 TODO

=over 4

=item * Extend C<from_string> to cover unions.

=item * Extend C<from_string> to include Number::Range-type specifications.

=item * Allow translation into forms not originally used:

 my $range    = tolerance(9 => to => 17); 
 my $range_pm = $range->convert_to('plus_minus');
 $range->stringify_as('plus_minus_pct');

=item * Create a factory so that you can simultaneously work with two sets of plugins.

This one is very near completion.  There will now be two classes that should be
used:  Number::Tolerant::Factory, which produces tolerances, and
Number::Tolerant::Tolerance, which is a tolerance.  Both will inherit from
N::T, for supporting old code, and N::T will dispatch construction methods to a
default factory.

=back

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

Thanks to Tom Freedman, who reminded me that this code was fun to work on, and
also provided the initial implementation for the offset type.

=cut

"1 +/- 0";
