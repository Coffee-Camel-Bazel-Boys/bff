package Bff;

use Mojo::Base 'Mojolicious', -signatures;
use Mojo::Log;
use Mojolicious::Validator::Validation;
use experimental qw(say);
use Data::Dumper;

sub _is_service_exn {
  return shift =~ /Can\'t connect:\s.*\.pm/;
}

sub startup ($self) {
  my $log    = Mojo::Log->new(level => 'trace');
  my $router = $self->routes->under('/api');

  $self->hook(
    around_dispatch => sub {
      my ($next, $c) = @_;
      eval { $next->(); 1 } or do {
        chomp(my $msg = $@->message);

        # A service outtage detected will be caught here
        if (_is_service_exn($@->message)) {
          $c->log->error("Possible service outage -> $msg");
          $c->render(status => 503, json => {err => 503, msg => 'Service Unavailable'});
        }
        else {
          # This should never happen unless something goes really wrong.
          $c->log->error('EXCEPTION OF UNKNOWN ORIGIN CAUGHT');
          $c->log->error($msg);
          $c->render(status => 500, text => 'Something went wrong');
        }
      };
    }
  );

  # User routing
  my $user_router = $router->under('/users');
  $user_router->post('/')->to('user#create')->name('user_create');
  $user_router->any('/login')->to('user#login')->name('user_login');
  $user_router->get('/:id')->to('user#find')->name('user_find');
  $user_router->put('/:id')->to('user#update')->name('user_update');
  $user_router->delete('/:id')->to('user#delete')->name('user_delete');

  # Land routing
  my $land_router = $router->under('/lands');
  $land_router->get('/')->to('land#find_all')->name('land_find_all');
  $land_router->get('/:id')->to('land#find')->name('land_find');
  $land_router->post('/')->to('land#create')->name('land_create');
  $land_router->put('/:id')->to('land#update')->name('land_update');
  $land_router->delete('/:id')->to('land#delete')->name('land_delete');

  # Plot routing
  my $plot_router = $router->under('/plots');
  $plot_router->get('/')->to('plot#find_all')->name('plot_find_all');
  $plot_router->get('/:id')->to('plot#find')->name('plot_find');
  $plot_router->post('/')->to('plot#create')->name('plot_create');
  $plot_router->put('/:id')->to('plot#update')->name('plot_update');
  $plot_router->delete('/:id')->to('plot#delete')->name('plot_delete');

  # Geo routing
  my $geo_router = $router->under('/geo');
  $geo_router->post('/autocomplete')->to('geo#autocomplete')->name('geo_autocomplete');

  $self->log($log);
}

1;
