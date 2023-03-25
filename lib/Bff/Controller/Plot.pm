package Bff::Controller::Plot;

use strict;
use warnings;
use experimental qw(signatures);

use Mojo::File qw(curfile);
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::UserAgent;
use Data::Dumper;

sub PLOT_URI { return 'http://garden-land:42069/api/v1/plots/' }
sub PLOT_PICTURE_URI { return 'http://garden-land:42069/api/v1/plots/' . shift . '/pictures' }

my $client = Mojo::UserAgent->new;

my $plot_err_msg = {err => 503, msg => "Plot service is down"};
my $plot_pic_err_msg = {err => 503, msg => 'Plot-picture service is down'};

sub get_pictures_by_id {
  eval {
    return $client->get(PLOT_PICTURE_URI(shift))->result;
  } or do {
    return undef;
  }
}

sub post_plot {
  eval {
    my $plot = shift;
    return $client->post(PLOT_URI() => json => $plot)->result;
  } or do {
    return undef;
  }
}

sub put_plot ($plot, $id) {
  eval {
    return $client->put((PLOT_URI() . $id) => json => $plot)->result;
  } or do {
    return undef;
  }
}

sub find_plot {
  my $id = shift;
  eval {
    return $client->get(PLOT_URI() . $id)->result;
  } or do {
    return undef;
  }
}

sub find_all_plots {
  eval {
    return $client->get(PLOT_URI())->result;
  } or do {
    return undef;
  }
}

sub delete_plot ($id) {
  eval {
    return $client->delete(PLOT_URI() . $id)->result;
  } or do {
    return undef;
  }
}

sub find_all ($self) {
  my $plots = find_all_plots;
  $self->app->log->info(Dumper $plots);
  if ($plots) {
    $self->render(json => $plots->json,
                  status => 200);
  } else {
    $self->res->code(503);
    $self->render(json => $plot_err_msg);
  }
}

sub create ($self) {
  my $plot_create_response = post_plot($self->req->json);
  return $self->render(status => 503, json => $plot_err_msg) unless $plot_create_response;
  return $self->render(json => $plot_create_response->json,
                       status => $plot_create_response->code);
}

sub find ($self) {
  return $self->render(status => 400, json => undef) unless my $id = $self->stash('id');
  my $plot_find_response = find_plot($id);

  if ($plot_find_response) {
    $self->render(json => $plot_find_response->json, status => 200);
  } else {
    $self->res->code(503);
    $self->render(json => $plot_err_msg);
  }
}

sub update ($self) {
  return $self->render(status => 400) unless my $id = $self->stash('id');
  my $plot = $self->req->json;
  my $result = put_plot($plot, $id);
  return $self->render(status => 503, json => $plot_err_msg) unless $result;
  return $self->render(json   => $result->json,
                       status => $result->code);
}

sub delete ($self) {
  return $self->render(status => 400) unless my $id = $self->stash('id');
  my $result = delete_plot($id);
  return $self->render(status => 503, json => $plot_err_msg) unless $result;
  return $self->render(status => $result->code, json => undef);
}

1;
