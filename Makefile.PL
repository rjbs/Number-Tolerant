use ExtUtils::MakeMaker;

use 5.008;
	# require 5.6 for warnings and 'our'
	# require 5.8 to avoid bizarre segv when 0+ yields undef

WriteMakefile(
	NAME			=> 'Number::Tolerant',
	VERSION_FROM	=> 'lib/Number/Tolerant.pm',
	dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean               => { FILES => 'Rubric-*' },
);

