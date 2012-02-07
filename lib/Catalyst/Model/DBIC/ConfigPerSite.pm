package Catalyst::Model::DBIC::ConfigPerSite;
use strict;

use Moose;

use Catalyst::Model::DBIC::Schema::Types
    qw/ConnectInfo LoadedClass SchemaClass Schema/;

use MooseX::Types::Moose qw/ArrayRef Str ClassName Undef/;


extends 'Catalyst::Model::DBIC::Schema'; 
with qw(Catalyst::TraitFor::Model::DBIC::ConfigPerSite);

has '+schema_class' => (
    required => 0
);


after BUILD => sub {
    warn "BUILD called\n";
};

1;
