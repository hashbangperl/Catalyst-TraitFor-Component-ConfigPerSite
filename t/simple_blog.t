use Test::More;
use Test::More;
use HTTP::Request;
use HTTP::Request::Common;

use Catalyst::Test qw(TestBlogApp);

my ($url, $desc)=@_;
$desc = $desc || "can fetch $url";
my $hr = HTTP::Request->new('GET', $url);
$hr->header(Cookie=>$cookie);

my $r=request($hr);

unless(ok($r->is_success, $desc)) {
    if($r->code == 500) {
	diag "$url: internal server error";
	#           diag "content : \n--------------------------------\n", $r->content, "\n-----------------------------------------\n";
    } else {
	diag "$url: ".$r->code;
    }
    diag "test_request failed, caller : ", join(' ', caller), "\n";
}
return $r;
