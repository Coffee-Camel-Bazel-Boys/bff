package Bff::Controller::Land;

use strict;
use warnings;
use experimental qw(signatures);

use Mojo::File qw(curfile);
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::UserAgent;
use Data::Dumper;

our $CLIENT_URI = 'http://garden-land:42069/api/v1/lands/';

my $client = Mojo::UserAgent->new;

my $err_msg = { err => 503, msg => "Land service is down" };

sub post_land ($land) {
    eval { return $client->post( $CLIENT_URI => json => $land )->result; } or do {
        return undef;
    }
}

sub put_land ( $land, $id ) {
    eval { return $client->put( $CLIENT_URI . $id => json => $land )->result; } or do {
        return undef;
    }
}

sub find_land ($id) {
    eval { return $client->get( $CLIENT_URI . $id )->result; } or do {
        return undef;
    }
}

sub find_all_land {
    eval { return $client->get($CLIENT_URI)->result; } or do {
        return undef;
    }
}

sub delete_land ($id) {
    eval { return $client->delete( $CLIENT_URI . $id )->result; } or do {
        return undef;
    }
}

sub find_all ($self) {
    my $land = find_all_land;
    $self->app->log->info( Dumper $land);
    if ($land) {
        $self->render(
            json   => $land->json,
            status => 200
        );
    }
    else {
        $self->res->code(503);
        $self->render( json => $err_msg );
    }
}

sub create ($self) {
    my $land_create_response = post_land( $self->req->json );
    return $self->render( status => 503, json => $err_msg ) unless $land_create_response;
    return $self->render(
        json   => $land_create_response->json,
        status => $land_create_response->code
    );
}

sub find ($self) {
    return $self->render( status => 400, json => undef ) unless my $id = $self->stash('id');
    my $land_find_response = find_land($id);

    if ($land_find_response) {
        $self->render( json => $land_find_response->json, status => 200 );
    }
    else {
        $self->res->code(503);
        $self->render( json => $err_msg );
    }
}

sub update ($self) {
    return $self->render( status => 400 ) unless my $id = $self->stash('id');
    my $land   = $self->req->json;
    my $result = put_land( $land, $id );
    return $self->render( status => 503, json => $err_msg ) unless $result;
    return $self->render(
        json   => $result->json,
        status => $result->code
    );
}

sub delete ($self) {
    return $self->render( status => 400 ) unless my $id = $self->stash('id');
    my $result = delete_land($id);
    return $self->render( status => 503,           json => $err_msg ) unless $result;
    return $self->render( status => $result->code, text => '' );
}

1;
