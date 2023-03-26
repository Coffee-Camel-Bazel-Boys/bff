package Bff;

use Mojo::Base 'Mojolicious', -signatures;
use Mojo::Log;
use Mojolicious::Validator::Validation;
use experimental qw(say);
use Mojolicious::Plugin::OAuth2;

sub startup ($self) {
  $self->plugin(OAuth2 => {
                           providers => {
                                         google => {
                                                    key    => '953637215774-de5fr3c8dj9mbrvr4ccptlvd4ss3s6u9.apps.googleusercontent.com',
                                                    secret => $ENV{'GOOGLE_SECRET'},
                                                   },
                                        },
                          });

  my $log = Mojo::Log->new(level => 'trace');
  my $router = $self->routes->under('/api');

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

  my $geo_router = $router->under('/geo');
  $geo_router->get('/autocomplete')->to('geo#autocomplete')->name('geo_autocomplete');
  
  $self->log($log);
}

1;
