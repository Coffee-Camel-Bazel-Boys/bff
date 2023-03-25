package Bff::Controller::Login;

use strict;
use warnings;
use experimental qw(signatures);

use Mojo::File qw(curfile);

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::UserAgent;
use Mojo::JSON;

our $CLIENT_URI = 'http://garden-land:42069/';

my $client = Mojo::UserAgent->new;

sub post_user ($user) {
  return $client->post($CLIENT_URI . '/api/v1/users' => json => $user);
}

sub post_login ($login) {
  return $client->post($CLIENT_URI . '/api/v1/users' => json => $login);
}

sub find_user ($id) {
  return $client->get($CLIENT_URI . '/api/v1/users/' . $id);
}

sub create ($self) {
  my $user_create_response = post_user($self->req->json)->result;
  return $self->render(json => $user_create_response->json,
                       status => $user_create_response->code);
}

sub find ($self) {
  return $self->render(status => 400) unless my $id = $self->stash('id');
  my $user = find_user($id)->result->json;
  return $self->render(json => $user,
                       status => 200);
}

sub login ($self) {
  my $user_login_response = post_user($self->req->json)->result;
  return $self->render(json => $user_login_response->json,
                       status => $user_login_response->code);
}

1;
