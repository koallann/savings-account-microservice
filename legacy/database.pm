use DBI;
use Data::UUID;
$ug = Data::UUID->new;

my $dbname = 'postgres';  
my $host = 'localhost';  
my $port = 5432;  
my $username = 'postgres';  
my $password = '123456'; 

our @ISA= qw( Exporter );
our @EXPORT = qw( updateTables );

# Create DB handle object by connecting
my $dbh = DBI -> connect("dbi:Pg:dbname=$dbname;host=$host;port=$port",  
                            $username,
                            $password,
                            {AutoCommit => 0, RaiseError => 1}
                         ) or die $DBI::errstr;


# Trace to a file
$dbh -> trace(1, 'tracelog.txt');


my $CHECK = "
	SELECT * 
	FROM INFORMATION_SCHEMA.TABLES
	WHERE table_name like 'transaction' or table_name like 'account'
";


my $sth = $dbh->do($CHECK);  
if ($sth != 2)
{
	my $SQL = "
		CREATE TABLE account (
			id serial,
			user_id uuid UNIQUE NOT NULL,
			balance money NOT NULL,
			PRIMARY KEY (id)
		);

		CREATE TABLE transaction (
			id bigserial,
			account_id serial NOT NULL,
			type CHAR NOT NULL,
			amount money NOT NULL,
			extra json,
			PRIMARY KEY (id),
			FOREIGN KEY (account_id) REFERENCES account (id)
		);
	";

	my $sth = $dbh->do($SQL);  
}

sub updateTables {
	my ($id, $value, $type) = @_;
	$uuid  = $ug->from_string( $id );

	my $SQL = "
		INSERT INTO account (user_id, balance)
		VALUES ('$uuid1', '$value');

		INSERT INTO transaction (account_id, type, amount)
		VALUES ('$id', '$type', '$value');
	";

	my $sth = $dbh->do($SQL);  
	$dbh->commit or die $DBI::errstr;
}

$dbh->commit or die $DBI::errstr;
