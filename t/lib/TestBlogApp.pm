package TestBlogApp;

use base qw/ Catalyst /;

use Catalyst qw/
	ConfigLoader
	Static::Simple
	
/;


# Start the application
__PACKAGE__->setup;


1;
