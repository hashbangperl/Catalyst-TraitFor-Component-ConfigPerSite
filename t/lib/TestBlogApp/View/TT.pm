package TestBlogApp::View::TT;

extends qw/Catalyst::View::TT/;

__PACKAGE__->config(
    INCLUDE_PATH=>[ 't/templates' ],
    );

1;
