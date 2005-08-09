#!perl -T

use Test::More tests => 4;

use_ok( 'Number::Tolerant' );
use_ok( 'Number::Tolerant::BasicTypes' );
use_ok( 'Number::Tolerant::Constant' );
use_ok( 'Number::Tolerant::Union' );

diag( "Testing Number::Tolerant $Number::Tolerant::VERSION" );
