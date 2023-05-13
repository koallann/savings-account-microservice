#!/usr/bin/perl
use warnings;
use strict;

$| = 1;

use DBI;
use HTTP::Daemon;
use HTTP::Response;
use HTTP::Status;
use JSON;
use threads;
use Try::Tiny;

use constant {
    TYPE_SERVER => "savings_account",

    ACTION_CHECK => "check",
    ACTION_DEPOSIT => "deposit",
    ACTION_WITHDRAW => "withdraw",
};

# creating database

my $dbname = 'savings_account';
my $host = 'localhost';
my $port = 5432;
my $username = 'clp';
my $password = '123456';

# creating server

my $server = HTTP::Daemon->new(
    LocalAddr => "127.0.0.1",
    LocalPort => 8000,
    ReuseAddr => 1,
) or die "Error creating server!";

# TODO: disconnect from database when server stops

# running server

print "Running server on ", $server->url, "\n";

while (my $conn = $server->accept()) {
    threads->create(\&handle_connection, $conn);
}

sub handle_connection {
    my ($conn) = @_;
    try {
        my $res = handle_request($conn->get_request());
        $conn->send_response($res);
        $conn->close();
    } catch {
        my $res = create_bad_response("Unexpected error: $_");
        $conn->send_response($res);
        $conn->close();
    }
}

sub handle_request {
    my ($req) = @_;

    # allow GET only
    my $method = $req->method;
    if ($method ne "GET") {
        return create_bad_response("Method not allowed.");
    }

    # allow path / only
    my $path = $req->uri->path;
    if ($path ne "/") {
        return create_bad_response("Path not allowed.");
    }

    # unmarshal request body
    my $body = decode_json($req->content);

    # check type field
    my $type = $body->{"type"};
    if ($type ne TYPE_SERVER) {
        return create_bad_response("The 'type' field doesn't match this service.");
    }

    # handle action
    my $action = $body->{"action"};
    my $content = $body->{"content"};

    return handle_action($action, $content);
}

sub handle_action {
    my ($action, $content) = @_;
    my $res;

    if ($action eq ACTION_CHECK) {
        $res = on_action_check($content);
    } elsif ($action eq ACTION_DEPOSIT) {
        $res = on_action_deposit($content);
    } elsif ($action eq ACTION_WITHDRAW) {
        $res = on_action_withdraw($content);
    } else {
        $res = create_bad_response("Invalid action.");
    }
    return $res;
}

sub create_bad_response {
    my ($message) = @_;

    return create_response(
        RC_BAD_REQUEST,
        {"message" => $message},
    );
}

sub create_response {
    my ($code, $body) = @_;

    return HTTP::Response->new(
        $code,
        status_message($code),
        ["Content-Type" => "application/json"],
        encode_json($body),
    );
}

sub on_action_check {
    my ($content) = @_;
    my $user_uuid = $content->{"user_uuid"};

    my $query = "SELECT balance::numeric FROM account WHERE user_id::text = '$user_uuid'";
    my @result = execute_query($query);

    if (scalar @result > 0) {
        my $balance = $result[0] + 0; # casting to number
        return create_response(RC_OK, {"balance" => $balance});
    } else {
        return create_response(RC_NOT_FOUND, {"message" => "This user doesn't exists."});
    }
}

sub on_action_deposit {
    my ($content) = @_;
    return create_bad_response("not implemented");
}

sub on_action_withdraw {
    my ($content) = @_;
    return create_bad_response("not implemented");
}

sub execute_query {
    my ($query) = @_;

    my $db = DBI->connect(
        "dbi:Pg:dbname=$dbname;host=$host;port=$port",
        $username,
        $password,
        {AutoCommit => 0, RaiseError => 1},
    ) or die $DBI::errstr;

    my $stmt = $db->prepare($query);
    $stmt->execute();

    my @result;
    while (my @row = $stmt->fetchrow_array()) {
        push @result, @row;
    }

    $stmt->finish();
    $db->disconnect();

    return @result;
}
