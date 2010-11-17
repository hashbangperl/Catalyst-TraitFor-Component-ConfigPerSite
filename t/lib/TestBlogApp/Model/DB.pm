package TestBlogApp::Model::DB;

use base qw/ Catalyst::Model::DBIC::Schema /;


__PACKAGE__->config(
                 schema_class => 'TestBlogApp::Schema',
                 connect_info => {
                                   dsn => "dbi:SQLite:dbname=t/test.db",
                                   user => "username",
                                   password => "password",
                                 }
             );

1;
