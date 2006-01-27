use Test::More tests => 33;

use strict;
use warnings;

BEGIN { use_ok("Number::Tolerant"); }

{ # plusminus
	my $tol = Number::Tolerant->from_string("10 +/- 2");
  isa_ok($tol, 'Number::Tolerant');
	is($tol, "10 +/- 2", "plus_or_minus");
}

{ # plusminus_pct
	my $tol = Number::Tolerant->from_string("10 +/- 10%");
  isa_ok($tol, 'Number::Tolerant');
	is($tol, "10 +/- 10%", "plus_or_minus_pct");
}

{ # or_less
  { # prosaic
    my $tol = Number::Tolerant->from_string("10 or less");
    isa_ok($tol, 'Number::Tolerant');
    is($tol, "x <= 10", "or_less");
  }
  { # algebraic
    my $tol = Number::Tolerant->from_string("<= 10");
    isa_ok($tol, 'Number::Tolerant');
    is($tol, "x <= 10", "or_less");
  }
}

{ # less_than
  { # prosaic
    my $tol = Number::Tolerant->from_string("less than 10");
    isa_ok($tol, 'Number::Tolerant');
    is($tol, "x < 10", "or_less");
  }
  { # algebraic
	  my $tol = Number::Tolerant->from_string("< 10");
    isa_ok($tol, 'Number::Tolerant');
    is($tol, "x < 10", "less_than");
  }
}

{ # or_more
  { # prosaic
    my $tol = Number::Tolerant->from_string("10 or more");
    isa_ok($tol, 'Number::Tolerant');
    is($tol, "10 <= x", "or_more");
  }
  { # algebraic
	  my $tol = Number::Tolerant->from_string(">= 10");
    isa_ok($tol, 'Number::Tolerant');
    is($tol, "10 <= x", "or_more");
  }
}

{ # more_than
  { # prosaic
    my $tol = Number::Tolerant->from_string("more than 10");
    isa_ok($tol, 'Number::Tolerant');
    is($tol, "10 < x", "or_more");
	}
  { # algebraic
	  my $tol = Number::Tolerant->from_string("> 10");
    isa_ok($tol, 'Number::Tolerant');
    is($tol, "10 < x", "more_than");
  }
}

{ # x_to_y
	my $tol = Number::Tolerant->from_string("8 to 12");
  isa_ok($tol, 'Number::Tolerant');
	is($tol, "8 <= x <= 12", "to");
}

{ # offset
  my $tol = Number::Tolerant->from_string("10 (-2 +5)");
  isa_ok($tol, 'Number::Tolerant');
  is($tol, "10 (-2 +5)", "offset");
}


{ # infinite
	my $tol = Number::Tolerant->from_string("any number");
  isa_ok($tol, 'Number::Tolerant');
	is($tol, "any number", "infinite");
}

{ # constant
  { # integer
	  my $tol = Number::Tolerant->from_string("1012");
    is(ref $tol, '', "a constant isn't really blessed");
    is($tol, "1012", "constant:  1012");
  }
  { # rational
	  my $tol = Number::Tolerant->from_string("10.12");
    is(ref $tol, '', "a constant isn't really blessed");
    is($tol, "10.12", "constant: 10.12");
  }
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

