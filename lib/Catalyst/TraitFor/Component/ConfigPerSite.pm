package Catalyst::TraitFor::Component::ConfigPerSite;
use strict;
use warnings;
use Carp qw(carp);

=head1 NAME

Catalyst::TraitFor::Component::ConfigPerSite - Extend Catalyst Components to share application accross sites

=head1 DESCRIPTIONS

This Role or Trait allows you to share an application between sites, clients, etc
with different configuration for templates and databases (and possibly other parts).

Compose this role into your trait to extend a catalyst component such as a model or view

=head1 SYNOPSIS

in testblogapp.conf:

name   TestBlogApp
site_name    TestBlog
default_view TT

<Model::DB>
        schema_class TestBlogApp::Schema
        <connect_info>
                      dsn dbi:SQLite:dbname=t/test.db
                      user username
                      password password
        </connect_info>
</Model::DB>

<View::TT>
        TEMPLATE_EXTENSION .tt
        WRAPPER            site-wrapper.tt
        INCLUDE_PATH       t/templates
</View::TT>

<TraitFor::Component::ConfigPerSite>
 <foo.bar>
   <Model::DB>
        schema_class TestBlogApp::Schema
        <connect_info>
                      dsn dbi:SQLite:dbname=t/test2.db
                      user username
                      password password
        </connect_info>
   </Model::DB>

   <View::TT>
        TEMPLATE_EXTENSION .tt
        WRAPPER            site-wrapper.tt
        INCLUDE_PATH       t/more_templates
   </View::TT>

 </foo.bar>
</TraitFor::Component::ConfigPerSite>

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

my $site_config = $self->get_site_config($c);

=cut

sub get_site_config {
    my ($self, $c) = @_;

    $shared_config ||= $c->config->{'TraitFor::Component::ConfigPerSite'};

    # get configuration from host and/or path
    my $req = $c->request;
    my $host = $req->uri->host;
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
		$site_config ||= $host_config->{ALL} || $host_config;
	    } else {
		($site_config) = values %$host_config;
	    }
	    $site_config->{site_name} = "host:$host";
       
	} else {
	    # if none found fall back to top level config for DBIC, and warn
	    $site_config = { site_name => 'top_level_fallback', %{$c->config} };
	    carp "falling back to top level config" if ($c->debug);
	}
	$cache->set( $cache_key, $site_config, "10 minutes" );
    }


    return $site_config;
}

=head1 get_component_config

return appropriate configuration for this component for this site

my $config = $self->get_component_config;

=cut

sub get_component_config {
    my ($self, $c) = @_;
    my $component_name = $self->catalyst_component_name;

    my $site_config = $self->get_site_config($c);
    my $component_config = $site_config->{$component_name};
    $component_config->{site_name} = $site_config->{site_name};

    return $component_config;
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
