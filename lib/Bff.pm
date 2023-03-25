package Bff;

use Mojo::Base 'Mojolicious', -signatures;
use Mojolicious::Validator::Validation;
use experimental qw(say);

sub startup ($self) {
  my $router = $self->routes->under('/api');

  my $user_router = $router->under('/users');

  $user_router->('/')->to('user#create')->name('user_create');
  $user_router->('/login')->to('user#login')->name('user_login');
}

1;
