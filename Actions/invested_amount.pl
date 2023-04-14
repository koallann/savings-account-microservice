use LWP::Simple;
use LWP::UserAgent;
use JSON;

sub InvestValue {
    my $ua = LWP::UserAgent->new;
    my $server_endpoint = "https://ef7f-2804-29b8-511b-aa0-545c-654-b549-84cc.ngrok-free.app/user/";

    # HTTP request header fields
    my $req = HTTP::Request->new(POST => $server_endpoint);
    $req->header('content-type' => 'application/json');
    $req->header( 'Accept'      => 'application/json');

    my $post_data = '{
        "name": "test",
        "email": "test@test.com",
        "password": "null"
    }';

    $req->content($post_data);
    
    my $resp = $ua->request($req);
    if ($resp->is_success) {
        my $message = $resp->decoded_content;

        print $message;
    }
    else {
        print "HTTP error code: ", $resp->code, "n";
        print "HTTP error message: ", $resp->message, "n";

        return 0
    }
}

InvestValue()