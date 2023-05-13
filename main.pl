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

    DB_NAME => "savings_account",
    DB_HOST => "localhost",
    DB_PORT => 5432,
    DB_USER => "clp",
    DB_PASS => "123456",
};

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
        my $res = create_response(
            RC_INTERNAL_SERVER_ERROR,
            {"message" => "Unexpected error: $_"},
        );
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

# response helpers

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

# actions handling

sub on_action_check {
    my ($content) = @_;
    my $user_uuid = $content->{"user_uuid"};

    my $query = "SELECT balance::numeric FROM account WHERE user_uuid::text = '$user_uuid'";
    my @result = query_select($query);

    if (scalar @result > 0) {
        my $balance = $result[0] + 0; # casting to number
        return create_response(RC_OK, {"balance" => $balance});
    } else {
        return create_response(RC_NOT_FOUND, {"message" => "This user doesn't exists."});
    }
}

sub on_action_deposit {
    my ($content) = @_;
    my $user_uuid = $content->{"user_uuid"};

    my $value = $content->{"value"};
    if ($value <= 0) {
        return create_bad_response("Value must be greater than 0.");
    }

    create_account_if_not_exists($user_uuid);

    my $balance_query = "UPDATE account SET balance = balance::numeric + $value WHERE user_uuid::text = '$user_uuid'";
    if (query_do($balance_query) != 1) {
        return create_response(
            RC_INTERNAL_SERVER_ERROR,
            {"message" => "Cannot update account balance."},
        );
    }

    my $transaction_query = "INSERT INTO transaction (user_uuid, type, amount) VALUES ('$user_uuid', 'd', $value)";
    if (query_do($transaction_query) != 1) {
        return create_response(
            RC_INTERNAL_SERVER_ERROR,
            {"message" => "Cannot create account transaction."},
        );
    }

    # TODO: rollback if some operation fails
    return create_response(RC_OK, {"result" => "OK"});
}

sub on_action_withdraw {
    my ($content) = @_;
    return create_bad_response("not implemented");
}

sub create_account_if_not_exists {
    my ($user_uuid) = @_;

    my $exists_query = "SELECT EXISTS(SELECT 1 FROM account WHERE user_uuid::text = '$user_uuid')";
    my @exists_result = query_select($exists_query);
    if ($exists_result[0] eq 1) {
        return;
    }

    my $create_query = "INSERT INTO account (user_uuid, balance) VALUES ('$user_uuid', 0)";
    if (query_do($create_query) != 1) {
        die "Cannot create user account.";
    }
}

# database helpers

sub create_db_connection {
    my $db = DBI->connect(
        "dbi:Pg:dbname=@{[DB_NAME]};host=@{[DB_HOST]};port=@{[DB_PORT]}",
        DB_USER,
        DB_PASS,
        {AutoCommit => 1, RaiseError => 1},
    ) or die $DBI::errstr;

    return $db;
}

sub query_select {
    my ($query) = @_;

    my $db = create_db_connection();
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

sub query_do {
    my ($query) = @_;

    my $db = create_db_connection();
    my $rows_affected = $db->do($query);

    $db->disconnect();

    return $rows_affected;
}
