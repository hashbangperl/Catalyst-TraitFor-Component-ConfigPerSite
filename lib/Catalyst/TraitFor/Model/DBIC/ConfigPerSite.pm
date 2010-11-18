package Catalyst::TraitFor::Model::DBIC::ConfigPerSite;
use strict;
use warnings;

=head1 NAME

Catalyst::TraitFor::Model::DBIC::ConfigPerSite - Extend Catalyst DBIC Model to work with multiple DB connections

=head1 SYNOPSIS

package MyApp::Model::DBIC;

use Moose;

extends 'Catalyst::Model::DBIC::Schema'; 

with qw(Catalyst::TraitFor::Model::DBIC::ConfigPerSite);

=head1 DESCRIPTION

This Role or Trait allows you to share an application between sites, clients, etc with different configuration for  databases. It extends Catalyst DBIC Model to work with multiple DB connections, one per site or configuration.

=cut

use Moose::Role;
with qw( Catalyst::Component::InstancePerContext Catalyst::TraitFor::Component::ConfigPerSite);

=head1 METHODS

=head2 build_per_context_instance

=cut

our $instances = {};

sub build_per_context_instance {
    my ($self, $c) = @_;
    my $site_config = $self->get_site_config($c);

    if ( $instances->{$site_config->{name}} ) {
	return $instances->{$site_config->{name}};
    }

    my @connect_info = ( @{$site_config->{DBIC}{connect_info}}{qw/dsn user password/});
    my $new = bless({ %$self }, ref($self));
    $new->schema($self->schema->connect(@connect_info));
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
