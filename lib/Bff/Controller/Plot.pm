package Bff::Controller::Plot;

use strict;
use warnings;
use experimental qw(signatures);

use Mojo::File qw(curfile);
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::UserAgent;
use Data::Dumper;

sub PLOT_URI         { return 'http://garden-land:42069/api/v1/plots/' }
sub PLOT_PICTURE_URI { return 'http://garden-land:42069/api/v1/plots/' . shift . '/pictures' }

my $client = Mojo::UserAgent->new;

my $plot_err_msg     = {err => 503, msg => "Plot service is down"};
my $plot_pic_err_msg = {err => 503, msg => 'Plot-picture service is down'};

sub get_pictures_by_id {
  return $client->get(PLOT_PICTURE_URI(shift))->result;
}

sub post_plot {
  my $plot = shift;
  return $client->post(PLOT_URI() => json => $plot)->result;
}

sub put_plot {
  my ($plot, $id) = @_;
  return $client->put((PLOT_URI() . $id) => json => $plot)->result;
}

sub find_plot {
  my $id = shift;
  return $client->get(PLOT_URI() . $id)->result;
}

sub find_all_plots {
  return $client->get(PLOT_URI())->result;
}

sub delete_plot {
  my $id = shift;
  return $client->delete(PLOT_URI() . $id)->result;
}

sub find_all {
  my $self = shift;

  my $plots = find_all_plots;
  $self->render(json => $plots->json, status => 200);
}

sub create {
  my $self                 = shift;
  my $plot_create_response = post_plot($self->req->json);
  $self->render(json => $plot_create_response->json, status => $plot_create_response->code);
}

sub find {
  my $self = shift;
  my $id   = $self->stash('id');

  my $plot_find_response = find_plot($id);

  $self->render(json => $plot_find_response->json, status => $plot_find_response->code);
}

sub update {
  my $self = shift;
  my $id   = $self->stash('id');

  my $plot   = $self->req->json;
  my $result = put_plot($plot, $id);

  $self->render(json => $result->json, status => $result->code);
}

sub delete ($self) {
  return $self->render(status => 400) unless my $id = $self->stash('id');
  my $result = delete_plot($id);
  return $self->render(status => 503,           json => $plot_err_msg) unless $result;
  return $self->render(status => $result->code, json => undef);
}

1;
