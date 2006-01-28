package Number::Tolerant::Type;
use base qw(Number::Tolerant);

use strict;
use warnings;

our $VERSION = "1.50";

=head1 NAME

Number::Tolerant::Type - a type of tolerance

=head1 VERSION

version 1.50

 $Id$

=head1 SYNOPSIS

=cut

# a number!
our $number = qr/(?:[+-]?)(?=\d|\.\d)\d*(?:\.\d*)?(?:[Ee](?:[+-]?\d+))?/;

# a variable name!
our $X      = qr/(?:\s*x\s*)/;

=head1 METHODS

=head2 C< valid_args >

  my @args = $type_class->valid_args(@_);

If the arguments to C<valid_args> are valid arguments for this type of
tolerance, this method returns their canonical form, suitable for passing to
C<L</construct>>.  Otherwise this method returns false.

=head2 C< construct >

  my $object_guts = $type_class->construct(@args);

This method is passed the output of the C<L</valid_args>> method, and should
return a hashref that will become the guts of a new tolerance.

=head2 C< parse >

  my $tolerance = $type_class->parse($string);

This method returns a new, fully constructed tolerance from the given string
if the given string can be parsed into a tolerance of this type.

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
