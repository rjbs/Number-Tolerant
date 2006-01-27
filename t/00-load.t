#!perl -T

use Test::More tests => 3;

BEGIN {
  use_ok( 'Number::Tolerant' );
  use_ok( 'Number::Tolerant::BasicTypes' );
  # vv removed due to Devel::Cover bug
  # use_ok( 'Number::Tolerant::Constant' );
  use_ok( 'Number::Tolerant::Union' );
}

diag( "Testing Number::Tolerant $Number::Tolerant::VERSION" );
