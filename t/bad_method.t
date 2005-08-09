use Test::More tests => 17;

use strict;
use warnings;

use_ok("Number::Tolerant");

## this test right here... it used to test for a bad method
## but it ain't like that no more
## a tolerance of a number is that number
## and that's just the way it is.
is(
	Number::Tolerant->new(5),
	5,
	"constants return constants"
);

is(
	Number::Tolerant->new(5 => 'thingie' => 0.5),
	undef,
	"there is no 'thingie' method"
);

is(
	Number::Tolerant->new(5 => 'to'),
	undef,
	"'to' requires two values"
);

is(
	Number::Tolerant->new(5 => to => 'life'),
	undef,
	"'to' requires two numbers"
);

is(
	Number::Tolerant->new(5 => 'plus_or_minus'),
	undef,
	"'plus_or_minus' requires two values"
);

is(
	Number::Tolerant->new(5 => 'plus_or_minus_pct'),
	undef,
	"'plus_or_minus_pct' requires two values"
);

is(
	Number::Tolerant->new(5 => 'plus_or_minus' => 'zero'),
	undef,
	"'plus_or_minus' requires two numbers"
);

is(
	Number::Tolerant->new(5 => 'plus_or_minus_pct' => 'zero'),
	undef,
	"'plus_or_minus_pct' requires two numbers"
);

is(
	Number::Tolerant->new(five => 'exactly'),
	undef,
	"invalid two-arg construction"
);

is(
	Number::Tolerant->new(just_about => 12),
	undef,
	"invalid two-arg construction"
);

is(
	Number::Tolerant->new(),
	undef,
	"at least one param required"
);

is(
	Number::Tolerant->new('things'),
	undef,
	"single, non-numeric argument"
);

is(
	Number::Tolerant->new(undef),
	undef,
	"single, undefined argument"
);

is(
	Number::Tolerant->new(''),
	undef,
	"single, pseudo-numeric argument"
);

is(
	Number::Tolerant->new(undef , 'to' , undef),
	undef,
	"undef-undef range not valid (should it be?)"
);

is(
	Number::Tolerant->new('string' => 'broken' => 'args'),
	undef,
	"three invalid params"
);
