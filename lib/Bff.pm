package Bff;

use Mojo::Base 'Mojolicious', -signatures;
use Mojolicious::Validator::Validation;
use experimental qw(say);

sub startup ($self) {
  my $router = $self->routes->under('/api');

  my $user_router = $router->under('/users');

  $user_router->post('/')->to('user#create')->name('user_create');
  $user_router->post('/login')->to('user#login')->name('user_login');
  # NOTE: id here is actually user-number
  $user_router->get('/:id' => [id => [qr/\d{9}/]])->to('user#find')->name('user_find');
  $user_router->put('/:id' => [id => [qr/\d{9}/]])->to('user#update')->name('user_update');

  my $land_router = $user_router->under('/land');
}

1;
