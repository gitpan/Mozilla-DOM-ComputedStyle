use strict;
use warnings FATAL => 'all';

use Test::More tests => 5;
use Mozilla::Mechanize;
use URI::file;

BEGIN { use_ok('Mozilla::DOM::ComputedStyle') };

my $url = URI::file->new_abs("t/test.html")->as_string;
my $moz = Mozilla::Mechanize->new(quiet => 1, visible => 0);

my @_last_call;
ok($moz->get($url));
is($moz->title, "Test-forms Page");

my $p = $moz->get_document->GetElementById("p1");
isnt($p, undef);

is(Get_Computed_Style_Property($moz->get_window, $p, "color"), "rgb(0, 0, 0)");

$moz->close();
