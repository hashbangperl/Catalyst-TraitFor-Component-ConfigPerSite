package Catalyst::TraitFor::Component::ConfigPerSite;
use strict;
use warnings;

=head1 NAME

Catalyst::TraitFor::Component::ConfigPerSite - Extend Catalyst Components to share application accross sites

=head1 DESCRIPTIONS

=head1 SYNOPSIS

=head1 VERSION

0.01

=cut

our $VERSION = '0.01';

use Moose::Role;
use MRO::Compat;

use Cache::SizeAwareMemoryCache;

my $cache = new Cache::SizeAwareMemoryCache( { 'namespace' => 'ConfigPerSite',
					       'default_expires_in' => 600,
					       'max_size' => 2000 } );

use Data::Dumper;

my $shared_application_configuration;

has '_site_config' => ( is  => 'ro' );


sub get_site_config {
    my ($self, $c) = @_;

    $shared_config ||= $c->config->{'Model::SharedApplication'};

    # get configuration from host and/or path
    my $req = $c->request;
    my $host = $req->header('host');
    my $path = $req->uri->path;

    my $cache_key = $host.$path;
    my $site_config = $cache->get( $cache_key );

    if ( not defined $site_config ) {
	if (my $host_config = $shared_config->{$host} || $shared_config->{ALL}) {
	    if (scalar keys %$host_config > 1) {
		my @path_parts = split(/\/+/, $path);
		while (my $last_path_part = pop(@path_parts)) {
		    my $match_path = join ('/',@path_parts,$last_path_part);
		    if ( $site_config = $host_config->{"/$match_path"} || $host_config->{"$match_path"}) {
			last;
		    }
		}	    
	    } else {
		($site_config) = values %$host_config
	    }
	} else {
	    # if none found fall back to top level config for DBIC, and warn
	    $site_config = { name => 'top_level_fallback', TT => {}, DBIC => { $c->config->{'Model::DB'} } }
	}
	$cache->set( $cache_key, $site_config, "10 minutes" );
    }
    
    return $site_config;
}

1;
