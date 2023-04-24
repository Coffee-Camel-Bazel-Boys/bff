package Bff::Controller::Land;

use strict;
use warnings;
use experimental qw(signatures);

use Mojo::File qw(curfile);
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::UserAgent;
use Data::Dumper;

use constant CLIENT_URI => 'http://garden-land:42069/api/v1/lands/';

my $client = Mojo::UserAgent->new;

my $err_msg = {err => 503, msg => "Land service is down"};

sub post_land ($land) {
  return $client->post((CLIENT_URI) => json => $land)->result;
}

sub put_land ($land, $id) {
  return $client->put(CLIENT_URI . $id => json => $land)->result;
}

sub find_land ($id) {
  return $client->get(CLIENT_URI . $id)->result;
}

sub find_all_land {
  return $client->get(CLIENT_URI)->result;
}

sub delete_land ($id) {
  return $client->delete(CLIENT_URI . $id)->result;
}

sub find_all ($self) {
  $self->render(json => find_all_land->json, status => 200);
}

sub create ($self) {
  my $land_create_response = post_land($self->req->json);
  $self->render(json => $land_create_response->json, status => $land_create_response->code);
}

sub find ($self) {
  return $self->render(status => 400, json => undef) unless my $id = $self->stash('id');
  my $find_land_response = find_land($id);
  $self->render(json => $find_land_response->json, status => $find_land_response->code);
}

sub update ($self) {
  return $self->render(status => 400) unless my $id = $self->stash('id');
  my $land   = $self->req->json;
  my $result = put_land($land, $id);
  return $self->render(status => 503,           json   => $err_msg) unless $result;
  return $self->render(json   => $result->json, status => $result->code);
}

sub delete ($self) {
  return $self->render(status => 400) unless my $id = $self->stash('id');
  my $result = delete_land($id);
  return $self->render(status => 503,           json => $err_msg) unless $result;
  return $self->render(status => $result->code, text => '');
}

1;
