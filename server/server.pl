#!/usr/bin/perl
use warnings;
use strict;

use JSON;
use lib '..';
use lib '../Actions';
use CheckWallet qw( check_wallet );
use database qw( updateTables );


use HTTP::Daemon;
use HTTP::Status;

my $daemon = HTTP::Daemon->new(
        LocalPort => 5000,
     ) or die;

while (my $client_connection = $daemon->accept) {
    new_connection($client_connection);
}

sub new_connection {
    my $client_connection = shift;
    printf "new connection\n";
    while (my $request = $client_connection->get_request) {

        if ($request->method eq 'GET' and $request->uri->path eq "/investir") {

            #print $request->decoded_content;
            my $json = decode_json($request->decoded_content)->{'content'};
            my $id = $json->{'id'};
            my $value = $json->{'value'};

            # Envia uma requisição pra API Gateway
            #my $can_invest = check_wallet($id, $value);
            my $can_invest = 1;

            my $response = HTTP::Response->new(200);
            if ($can_invest != 0) {
                #Salva no banco
                updateTables($id, $value, 'Investir_na_poupança');
                
                $response->content("Valor investido com sucesso.\n");
                $client_connection->send_response($response);
            } 
            else {
                $response->content("Saldo Insuficiente.\n");
                $client_connection->send_response($response);
            }

        }
        else {
            $client_connection->send_error(RC_FORBIDDEN)
        }
    }
    $client_connection->close;
}