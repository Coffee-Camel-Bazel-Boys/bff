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

sub post_user ($user) {
    return $client->post( $CLIENT_URI => json => $user )->result;
}

sub put_user ( $user, $id ) {
    return $client->put( $CLIENT_URI . $id => json => $user )->result;
}

sub post_login ($login) {
    return $client->post( $CLIENT_URI => json => $login )->result;
}

sub find_user ($id) {
    return $client->get( $CLIENT_URI . $id )->result;
}

sub create {
    my $self                 = shift;
    my $user_create_response = post_user( $self->req->json );
    $self->render(
        json   => $user_create_response->json,
        status => $user_create_response->code
    );
}

sub find {
    my $self = shift;

    my $id = $self->stash('id');
    return $self->render( status => 403, json => { err => 403, msg => 'Unauthorized' } ) unless $self->session('user_id') eq $id;

    my $user_response = find_user($id);
    $self->render( status => $user_response->code, json => user_response->json );
}

sub login {
    my $self = shift;

    return $self->render( status => 400, json => undef ) unless $self->req->method eq 'POST';
    my $jwt = $self->req->json->{'loginToken'};

    # TODO: decode JWT here for login
    # TODO: Maybe we want an auth service
    my $user_login_response = post_user( $self->req->json );
    $self->render(
        json   => $user_login_response->json,
        status => $user_login_response->code
    );
}

sub update {
    my $self = shift;

    return $self->render( status => 400, text => '' ) unless my $id = $self->stash('id');

    my $user   = $self->req->json;
    my $result = put_user( $user, $id )->result;
    return $self->render(
        json   => $result->json,
        status => $result->code
    );
}

1;
