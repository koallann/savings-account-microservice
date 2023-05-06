package CheckWallet;
use strict;
use warnings;
use Exporter;
use LWP::Simple;
use LWP::UserAgent;
use JSON;

our @ISA= qw( Exporter );

# these are exported by default.
our @EXPORT = qw( check_wallet );


sub check_wallet {
    my ($id, $value) = @_;
    my $ua = LWP::UserAgent->new;
    my $server_endpoint = "https://48af-2804-29b8-511b-aa0-b506-a186-6445-b26c.ngrok-free.app/";

    # HTTP request header fields
    my $req = HTTP::Request->new(GET => $server_endpoint);
    $req->header('content-type' => 'application/json');
    $req->header( 'Accept'      => 'application/json');

    $req->content($value);

    my $post_data = "{
        'type': 'publicações',
        'action': 'posts',
        'content': {
            'id': ${id},
            'value': ${value} 
        }
    }";
    
    print($post_data);

    my $resp = $ua->request($req);
    if ($resp->is_success) {
        my $message = $resp->decoded_content;

        print $message;
        return (122)
    }
    else {
        print "HTTP error code: ", $resp->code, "\n";
        print "HTTP error message: ", $resp->message, "\n";

        return 0
    }
}


1;