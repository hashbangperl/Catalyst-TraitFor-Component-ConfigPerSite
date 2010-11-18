package TestBlogApp::Model::DB;
use strict;

use Moose;

extends 'Catalyst::Model::DBIC::Schema'; 
with qw(Catalyst::TraitFor::Model::DBIC::ConfigPerSite);


1;
