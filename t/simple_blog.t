use Test::More;
use Test::More;
use HTTP::Request;
use HTTP::Request::Common;

use Catalyst::Test qw(TestBlogApp);

my $main_url = '/blog';
my $hr = HTTP::Request->new('GET', $main_url);
my $r=request($hr);

unless(ok($r->is_success, 'got main blog page ok')) {
    if($r->code == 500) {
	diag "$main_url: internal server error";
	diag "content : \n--------------------------------\n", $r->content, "\n-----------------------------------------\n";
    } else {
	diag "$main_url: ".$r->code;
    }
    diag "test_request failed, caller : ", join(' ', caller), "\n";
}

