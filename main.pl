#!/usr/bin/perl
use warnings;
use strict;

$| = 1;

use HTTP::Daemon;
use HTTP::Response;
use HTTP::Status;

use JSON;

use constant {
    TYPE_SERVER => "savings_account",

    ACTION_CHECK => "check",
    ACTION_DEPOSIT => "deposit",
    ACTION_WITHDRAW => "withdraw",
};

# creating server

my $server = HTTP::Daemon->new(
    LocalAddr => "127.0.0.1",
    LocalPort => 8000,
    ReuseAddr => 1,
) or die;

# running server

print "Running server on ", $server->url, "\n";

while (my $conn = $server->accept()) {
    while (my $req = $conn->get_request()) {
        # allow GET only
        my $method = $req->method;
        if ($method ne "GET") {
            my $res = create_bad_response("Method not allowed.");
            $conn->send_response($res);
            next;
        }

        # allow path / only
        my $path = $req->uri->path;
        if ($path ne "/") {
            my $res = create_bad_response("Path not allowed.");
            $conn->send_response($res);
            next;
        }

        # unmarshal request body
        my $body = decode_json($req->content);

        # check type field
        my $type = $body->{"type"};
        if ($type ne TYPE_SERVER) {
            my $res = create_bad_response("The 'type' field doesn't match this service.");
            $conn->send_response($res);
            next;
        }

        # handle action and respond
        my $action = $body->{"action"};
        my $content = $body->{"content"};

        my $res = handle_action($action, $content);
        $conn->send_response($res);
    }
    $conn->close();
}

sub handle_action {
    my ($action, $content) = @_;
    my $res;

    if ($action eq ACTION_CHECK) {

    } elsif ($action eq ACTION_DEPOSIT) {

    } elsif ($action eq ACTION_WITHDRAW) {

    } else {
        $res = create_bad_response("Invalid action.");
    }
    return $res;
}

sub create_bad_response {
    my ($body) = @_;

    return HTTP::Response->new(
        RC_BAD_REQUEST,
        status_message(RC_BAD_REQUEST),
        ["Content-Type" => "application/json"],
        encode_json({"message" => $body}),
    );
}
