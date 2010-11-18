package Catalyst::TraitFor::Component::ConfigPerSite;
use strict;
use warnings;

=head1 NAME

Catalyst::TraitFor::Component::ConfigPerSite - Extend Catalyst Components to share application accross sites

=head1 DESCRIPTIONS

This Role or Trait allows you to share an application between sites, clients, etc
with different configuration for templates and databases (and possibly other parts).

Compose this role into your trait to extend a catalyst component such as a model or view

=head1 SYNOPSIS

use Moose::Role;

with qw( Catalyst::Component::InstancePerContext Catalyst::TraitFor::Component::ConfigPerSite);

=head1 VERSION

0.01

=cut

our $VERSION = '0.01';

use Moose::Role;
use MRO::Compat;
use Data::Dumper;

use Cache::SizeAwareMemoryCache;

my $cache = new Cache::SizeAwareMemoryCache( { 'namespace' => 'ConfigPerSite',
					       'default_expires_in' => 600,
					       'max_size' => 2000 } );

use Data::Dumper;

my $shared_config;

has '_site_config' => ( is  => 'ro' );

=head1 METHODS

=head2 get_site_config

return (possibly cached) site-specific configuration based on host and path for this request

=cut

sub get_site_config {
    my ($self, $c) = @_;

    $shared_config ||= $c->config->{'TraitFor::Component::ConfigPerSite'};

    # get configuration from host and/or path
    my $req = $c->request;
    my $host = $req->uri->host;
    my $path = $req->uri->path;

#    warn "host : $host, path $path\n";

    my $cache_key = $host.$path;
    my $site_config = $cache->get( $cache_key );
    my ($TT_view_name) = grep (m/View::(HTML|TT)/, keys %{$c->config}, 'View::HTML');

    if ( not defined $site_config ) {
	if (my $host_config = $shared_config->{$host} || $shared_config->{ALL}) {
# 	    warn "host config : $host_config\n", Dumper(host_config=>$host_config);
	    if (scalar keys %$host_config > 1) {
		my @path_parts = split(/\/+/, $path);
		while (my $last_path_part = pop(@path_parts)) {
		    my $match_path = join ('/',@path_parts,$last_path_part);
		    if ( $site_config = $host_config->{"/$match_path"} || $host_config->{"$match_path"}) {
			last;
		    }
		}
		$site_config ||= $host_config->{ALL} || $host_config;
	    } else {
		($site_config) = values %$host_config;
	    }
	    $site_config->{name} = "host:$host";
	    $site_config->{TT} = $site_config->{$TT_view_name};
	    $site_config->{DBIC} = $site_config->{'Model::DB'};
	} else {
	    # if none found fall back to top level config for DBIC, and warn
	    $site_config = { name => 'top_level_fallback', TT => $c->config->{$TT_view_name}, DBIC => $c->config->{'Model::DB'} }
	}
	$cache->set( $cache_key, $site_config, "10 minutes" );
    }

#    warn Dumper (site_config =>$site_config);
#    warn Dumper (db => $c->config->{'Model::DB'});

    return $site_config;
}


=head1 SEE ALSO

Catalyst::Component::InstancePerContext

Catalyst::TraitFor::View::TT::ConfigPerSite

Moose::Role

=head1 AUTHOR

Aaron Trevena, E<lt>aaron@aarontrevena.co.ukE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Aaron Trevena

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut

1;
