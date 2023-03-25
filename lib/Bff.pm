package Bff;

use Mojo::Base 'Mojolicious', -signatures;
use Mojolicious::Validator::Validation;
use experimental qw(say);

sub startup ($self) {

  $self->hook(after_dispatch => sub {
                my $c = shift;
                
                });

  
  my $router = $self->routes->under('/api');

  # User routing
  my $user_router = $router->under('/users');
  $user_router->post('/')->to('user#create')->name('user_create');
  $user_router->post('/login')->to('user#login')->name('user_login');
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
}

1;
