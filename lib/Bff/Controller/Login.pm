package Bff::Controller::Login;

use strict;
use warnings;

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

sub create ($self) {
  my $user_create_response = post_user(decode_json $self->req->body)->result;
  return $self->render(json => $user_create_response->body,
                       status => $user_create_response->code);
}

sub login ($self) {
  my $user_login_response = post_user(decode_json $self->req->body)->result;
  return $self->render(json => $user_login_response->body,
                       status => $user_login_response->code);
}

1;
