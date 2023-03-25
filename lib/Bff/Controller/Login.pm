package Bff::Controller::Login;

use strict;
use warnings;

use Mojo::File qw(curfile);

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::UserAgent;
use Mojo::JSON;

our $CLIENT_URI = 'http://garden-land:69420/';

my $client = Mojo::UserAgent->new;

sub post_user ($user) {
  return $client->post('http://backend:69420/api/v1/users' => json => $user);
}

sub post_login ($login) {
  return $client->post($CLIENT_URI);
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
