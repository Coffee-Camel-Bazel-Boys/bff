package Bff::Controller::User;

use strict;
use warnings;
use experimental qw(signatures);

use Mojo::File qw(curfile);
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::UserAgent;
use Mojo::JSON;
use Mojo::Exception qw(check);

our $CLIENT_URI = 'http://garden-land:42069/api/v1/users/';

my $client = Mojo::UserAgent->new;
my $err_msg = { error => 503, msg => 'User service is down' };

sub post_user ($user) {
  eval {
    return $client->post($CLIENT_URI => json => $user)->result;
  } or do {
    return undef;
  }
}

sub put_user ($user, $id) {
  eval {
    return $client->put($CLIENT_URI . $id => json => $user)->result;
  } or do {
    return undef;
  }
}

sub post_login ($login) {
  eval {
    return $client->post($CLIENT_URI => json => $login)->result;
  } or do {
    return undef;
  }
}

sub find_user ($id) {
  eval {
    return $client->get($CLIENT_URI . $id)->result;
  } or do {
    return undef;
  }
}

sub create {
  my $self = shift;
  return $self->render(status => 503, json => $err_msg) unless my $user_create_response = post_user($self->req->json);
  return $self->render(json => $user_create_response->json,
                       status => $user_create_response->code);
}

sub find {
  my $self = shift;
  return $self->render(status => 400, json => { id => 'Invalid id' }) unless my $id = $self->stash('id');
  return $self->render(status => 404, json => undef) unless my $user_transaction = find_user($id);
  my $user = $user_transaction;
  $self->res->code(200);
  $self->render(json => $user->json);
}

sub login {
  my $self = shift;
  return $self->render(status => 400, json => undef) unless $self->req->method eq 'POST';
  my $jwt = $self->req->json->{'loginToken'}; # TODO: decode JWT here for login
  # TODO: Maybe we want an auth service
  return $self->render(status => 503, json => $err_msg ) unless my $user_login_response = post_user($self->req->json);
  $self->render(json => $user_login_response->json,
                status => $user_login_response->code);
}

sub update {
  my $self = shift;
  return $self->render(status => 400, text => '') unless my $id = $self->stash('id');
  my $user = $self->req->json;
  return $self->render(status => 503, json => $err_msg) unless my $result = put_user($user, $id)->result;
  return $self->render(json => $result->json,
                       status => $result->code);
}

1;
