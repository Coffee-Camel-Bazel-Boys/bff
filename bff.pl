#!/usr/bin/env perl

use strict;
use warnings;

use Mojo::File qw(curfile);
use lib curfile->sibling('lib')->to_string;
use Mojolicious::Commands;

Mojolicious::Commands->start_app('Bff');
