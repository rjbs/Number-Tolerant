use strict;
use warnings;

package Number::Tolerant::Type;
use base qw(Number::Tolerant);

our $VERSION = "1.600";

=head1 NAME

Number::Tolerant::Type - a type of tolerance

=head1 VERSION

version 1.600

=head1 SYNOPSIS

=cut

=head1 METHODS

=head2 valid_args

  my @args = $type_class->valid_args(@_);

If the arguments to C<valid_args> are valid arguments for this type of
tolerance, this method returns their canonical form, suitable for passing to
C<L</construct>>.  Otherwise this method returns false.

=head2 construct

  my $object_guts = $type_class->construct(@args);

This method is passed the output of the C<L</valid_args>> method, and should
return a hashref that will become the guts of a new tolerance.

=head2 parse

  my $tolerance = $type_class->parse($string);

This method returns a new, fully constructed tolerance from the given string
if the given string can be parsed into a tolerance of this type.

=head2 number_re

  my $number_re = $type_class->number_re;

This method returns the regular expression (as a C<qx> construct) used to match
number in parsed strings.

=cut

my $number;
BEGIN { $number = qr/(?:[+-]?)(?=\d|\.\d)\d*(?:\.\d*)?(?:[Ee](?:[+-]?\d+))?/; }

sub number_re { return $number; }

=head2 variable_re

  my $variable_re = $type_class->variable_re;

This method returns the regular expression (as a C<qx> construct) used to match
the variable in parsed strings.

When parsing "4 <= x <= 10" this regular expression is used to match the letter
"x."

=cut

my $X;
BEGIN { $X =  qr/(?:\s*x\s*)/; }

sub variable_re { return $X; }

=head1 SEE ALSO

=over 4

=item * L<Number::Tolerant>

=back

=head1 AUTHOR

Ricardo SIGNES, E<lt>rjbs@cpan.orgE<gt>

=head1 COPYRIGHT

(C) 2004-2006, Ricardo SIGNES.  Number::Tolerant is available under the same
terms as Perl itself.

=cut

1;
