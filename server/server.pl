#!/usr/bin/perl

## sudo apt-get install -y libtest-http-server-simple-perl
## sudo cpan i HTTP::Server::Simple::Dispatched

use HTTP::Server::Simple::Dispatched qw(static);
 
my $server = HTTP::Server::Simple::Dispatched->new(
  hostname => 'http://localhost:8080/',
  port     => 8080,
  debug    => 1,
  dispatch => [
    qr{^/user/} => sub {
      my ($response) = @_;
      $response->content_type('text/plain');
      $response->content("Hello, world!");
      return 1;
    },
    qr{^/static/(.*\.(?:png|gif|jpg))} => static("t/"),
    qr{^/error/} => sub {
      die "This will cause a 500!";
    },
  ],
);

$server->run();