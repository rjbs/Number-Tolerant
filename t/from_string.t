use Test::More tests => 17;

use strict;
use warnings;

BEGIN { use_ok("Number::Tolerant"); }

{ # plusminus
	my $tol = Number::Tolerant->from_string("10 +/- 2");
	is($tol, "10 +/- 2", "plus_or_minus");
}

{ # plusminus_pct
	my $tol = Number::Tolerant->from_string("10 +/- 10%");
	is($tol, "10 +/- 10%", "plus_or_minus_pct");
}

{ # or_less
	my $tol = Number::Tolerant->from_string("10 or less");
	is($tol, "x <= 10", "or_less");
	undef $tol;
	   $tol = Number::Tolerant->from_string("<= 10");
	is($tol, "x <= 10", "or_less");
}

{ # less_than
	my $tol = Number::Tolerant->from_string("less than 10");
	is($tol, "x < 10", "or_less");
	undef $tol;
	   $tol = Number::Tolerant->from_string("< 10");
	is($tol, "x < 10", "less_than");
}

{ # or_more
	my $tol = Number::Tolerant->from_string("10 or more");
	is($tol, "10 <= x", "or_more");
	undef $tol;
	   $tol = Number::Tolerant->from_string(">= 10");
	is($tol, "10 <= x", "or_more");
}

{ # more_than
	my $tol = Number::Tolerant->from_string("more than 10");
	is($tol, "10 < x", "or_more");
	undef $tol;
	   $tol = Number::Tolerant->from_string("> 10");
	is($tol, "10 < x", "more_than");
}

{ # x_to_y
	my $tol = Number::Tolerant->from_string("8 to 12");
	is($tol, "8 <= x <= 12", "to");
}


{ # infinite
	my $tol = Number::Tolerant->from_string("any number");
	is($tol, "any number", "infinite");
}

{ # constant
	is( Number::Tolerant->from_string("10.12"), "10.12", "constant: 10.12");
	is( Number::Tolerant->from_string("1012"),  "1012",  "constant:  1012");
}

{ # bad string
	my $tol = Number::Tolerant->from_string("is this thing on?");
	is($tol, undef, "invalid string: undef");
}

{ # instance method call should die
	my $tol = tolerance(10 => to => 20);
	eval { $tol->from_string("10 to 30"); };
	ok("$@", "from_string is a class method only");
}

