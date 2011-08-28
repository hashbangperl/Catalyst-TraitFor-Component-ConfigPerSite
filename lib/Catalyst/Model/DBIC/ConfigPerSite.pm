package Catalyst::Model::DBIC::ConfigPerSite;
use strict;

use Moose;

extends 'Catalyst::Model::DBIC::Schema'; 
with qw(Catalyst::TraitFor::Model::DBIC::ConfigPerSite);

sub BUILD {
    warn "BUILD called\n";
}

1;
