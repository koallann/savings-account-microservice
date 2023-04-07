use LWP::Simple;
use LWP::UserAgent;

sub InvestValue {
    my $ua = LWP::UserAgent->new;
    my $server_endpoint = "http://localhost:8080/user";

    # HTTP request header fields
    my $req = HTTP::Request->new(GET => $server_endpoint);
    $req->header('content-type' => 'application/json');
    $req->header('x-auth-token' => 'token');

    my $post_data = '{ 
        "type": "poupança",
        "action": "investir_valor",
        "content": {
            "user": 001,
            "value": 200.0
        } 
    }';
    $req->content($post_data);
    
    my $resp = $ua->request($req);
    if ($resp->is_success) {
        my $message = $resp->decoded_content;
        print "Received reply: $messagen";

        return $resp
    }
    else {
        print "HTTP error code: ", $resp->code, "n";
        print "HTTP error message: ", $resp->message, "n";

        return 0
    }
}

InvestValue()