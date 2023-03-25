package Bff::Controller::Land;

use strict;
use warnings;
use experimental qw(signatures);

use Mojo::File qw(curfile);
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::UserAgent;
use Mojo::JSON;

our $CLIENT_URI = 'http://garden-land:42069/api/v1/lands/';

my $client = Mojo::UserAgent->new;

sub post_land ($land) {
  return $client->post($CLIENT_URI => json => $land);
}

sub put_land ($land, $id) {
  return $client->put($CLIENT_URI . $id => json => $land);
}

sub find_land ($id) {
  return $client->get($CLIENT_URI . $id);
}

sub delete_land ($id) {
  return $client->delete($CLIENT_URI . $id);
}

sub create ($self) {
  my $land_create_response = post_land($self->req->json)->result;
  return $self->render(json => $land_create_response->json,
                       status => $land_create_response->code);
}

sub find ($self) {
  return $self->render(status => 400) unless my $id = $self->stash('id');
  my $land = find_land($id)->result->json;
  return $self->render(json => $land,
                       status => 200);
}

sub update ($self) {
  return $self->render(status => 400) unless my $id = $self->stash('id');
  my $land = $self->req->json;
  my $result = put_land($land, $id)->result;
  return $self->render(json => $result->json,
                       status => $result->code);
}

sub delete ($self) {
  return $self->render(status => 400) unless my $id = $self->stash('id');
  my $result = delete_land($id)->result;
  return $self->render(status => 204);
}

1;
