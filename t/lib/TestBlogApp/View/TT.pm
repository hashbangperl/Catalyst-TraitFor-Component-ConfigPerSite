package TestBlogApp::View::TT;

use base qw/Catalyst::View::TT/;

use Cwd;

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    INCLUDE_PATH=>[ 't/templates'  ],
    WRAPPER=> 'site-wrapper.tt',
    );

1;
