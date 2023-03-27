package Bff::Controller::Geo;

use strict;
use warnings;
use experimental qw(signatures);

use Mojo::File qw(curfile);
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::UserAgent;
use Data::Dumper;
use List::Compare::Functional;
use Carp;

my $client        = Mojo::UserAgent->new;
my $err_msg       = { error => 503, msg => 'Geo-service-search is unavailable' };
my @accepted_keys = qw(text);
my $api_key       = $ENV{'GEO_API_KEY'} || croak "Couldn't find GEO_API_KEY in ENV";

sub GEO_URI ( $api_key, $text ) {
    return 'https://api.geoapify.com/v1/geocode/autocomplete?text=' . $text . '&apiKey=' . $api_key;
}

sub get_auto_complete_results ( $api_key, $text ) {
    return $client->get( GEO_URI $api_key, $text )->result;
}

sub auto_complete {
    my $self = shift;

    my $body = $self->json;
    return $self->render( text => 'Invalid auto-complete format', status => 400 ) unless scalar get_intersection( \( keys %$body ), \@accepted_keys ) == 1;

    my $auto_complete_result = get_auto_complete_results( $api_key, $body->{'text'} );
    $self->render(
        json   => $auto_complete_result->json,
        status => $auto_complete_result->code
    );
}
