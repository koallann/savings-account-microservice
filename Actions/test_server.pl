use LWP::Simple;
use LWP::UserAgent;
use JSON;

sub InvestValue {
    my $ua = LWP::UserAgent->new;
    my $server_endpoint = "https://ab99-2804-29b8-511b-215-da6e-fdd9-e75-8389.ngrok-free.app/investir";

    # HTTP request header fields
    my $req = HTTP::Request->new(GET => $server_endpoint);
    $req->header('content-type' => 'application/json');
    $req->header( 'Accept'      => 'application/json');

    my $post_data = '{
        "type": "publicações",
        "action": "posts",
        "content": {
            "id": "f6a16gf1-4a32-11eb-be7b-8348edc8f46c",
            "value": "500" 
        }
    }';
    

    $req->content($post_data);
    
    my $resp = $ua->request($req);
    if ($resp->is_success) {
        my $message = $resp->decoded_content;
        print $message;
    }
    else {
        print "HTTP error code: ", $resp->code, "\n";
        print "HTTP error message: ", $resp->message, "\n";

        return 0
    }
}

InvestValue()