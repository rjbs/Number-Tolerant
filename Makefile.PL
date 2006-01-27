use strict;
use warnings;

use inc::Module::Install;
use File::Find;

name          ('Number-Tolerant');
author        ('Ricardo SIGNES <rjbs@cpan.org>');
license       ('perl');
version_from  ('lib/Number/Tolerant.pm');

# require 5.6 for warnings and 'our'
# require 5.8 to avoid bizarre segv when 0+ yields undef
perl_version  ('5.008');

my $files = '';
find( sub { $files .= " $File::Find::name" if -f && /\.t$/ }, "t" );

tests         ($files);

sign(1);

WriteAll();
