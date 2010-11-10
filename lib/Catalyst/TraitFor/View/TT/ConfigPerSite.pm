package Catalyst::TraitFor::View::TT::SharedApplication;
use strict;
use warnings;

=head1 NAME

Catalyst::TraitFor::View::TT::ShareApplication - Extend Catalyst TT View to work with multiple sites at once

=head1 SYNOPSIS

package MyApp::View::TT;

use Moose;

extends 'Catalyst::View::TT::Schema'; 

with qw(Catalyst::TraitFor::View::TT::ShareApplication)

=head1 DESCRIPTION

This Role or Trait allows you to share an application between sites, clients, etc with different configuration for  databases. It extends Catalyst TT View to work with multiple template paths, per site or configuration.

=cut

use Moose::Role;
with qw( Catalyst::Component::InstancePerContext Catalyst::TraitFor::Component::ConfigPerSite);

use MRO::Compat;

=head1 METHODS

=head2 build_per_context_instance

=cut

our $instances = {};

sub build_per_context_instance {
    my ($self,$c,%args) = @_;
    my $site_config = $c->shared_application;

    if ( $instances->{$site_config->{name}} ) {
	return $instances->{$site_config->{name}};
    }

    # Slightly evil - we use hash/array flattening side-effect in TT View constructor to inject/overwrite with site specific config 
    foreach my $key ( keys %{$site_config->{TT}} ) {
	next if ($key eq 'name');
	$args{$key} = $site_config->{$key};
    }

    my $new = $self->new($c, %args);
    $instances->{$site_config->{name}} = $new;

    return $new;
}

=head1 SEE ALSO

Catalyst::Component::InstancePerContext

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
