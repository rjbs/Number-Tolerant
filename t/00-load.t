#!perl -T

use Test::More tests => 14;

BEGIN {
  use_ok( 'Number::Tolerant' );
  use_ok( 'Number::Tolerant::Type' );
  use_ok( 'Number::Tolerant::Type::constant' );
  use_ok( 'Number::Tolerant::Type::infinite' );
  use_ok( 'Number::Tolerant::Type::less_than' );
  use_ok( 'Number::Tolerant::Type::more_than' );
  use_ok( 'Number::Tolerant::Type::offset' );
  use_ok( 'Number::Tolerant::Type::or_less' );
  use_ok( 'Number::Tolerant::Type::or_more' );
  use_ok( 'Number::Tolerant::Type::plus_or_minus' );
  use_ok( 'Number::Tolerant::Type::plus_or_minus_pct' );
  use_ok( 'Number::Tolerant::Type::to' );
  use_ok( 'Number::Tolerant::Type' );
  use_ok( 'Number::Tolerant::Union' );

  # vv removed due to Devel::Cover bug
  # use_ok( 'Number::Tolerant::Constant' );
}

diag( "Testing Number::Tolerant $Number::Tolerant::VERSION" );
