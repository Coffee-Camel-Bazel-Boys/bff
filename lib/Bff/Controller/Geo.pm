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

my $client = Mojo::UserAgent->new;
my $err_msg = { error => 503, msg => 'Geo-service-search is unavailable'};
my @accepted_keys = qw(text);

sub GEO_URI ($api_key, $text) {
  return "https://api.geoapify.com/v1/geocode/autocomplete?text=$text&apiKey=$api_key"
}

sub get_auto_complete_results ($api_key, $text) {
  eval {
    $client->get(GEO_URI $api_key, $text)->result;
  } or do {
    return undef;
  }
}

sub auto_complete {
  my $self = shift;
  state $api_key = $ENV{'GEO_API_KEY'} || undef;
  return $self->render(json => $err_msg, status => 503) unless $api_key;
  my $json = $self->json;
  return $self->render(text => '', status => 400) unless scalar get_intersection(\(keys %$json), \@accepted_keys) == 1;
  return $self->render(json => $err_msg, status => 503) unless my $auto_complete_result = get_auto_complete_results($api_key, $json->{'text'});
  $self->render(json => $auto_complete_result->json, status => $auto_complete_result->code);
}
