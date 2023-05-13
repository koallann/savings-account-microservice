use DBI;
 
my $dbname = 'postgres';  
my $host = 'localhost';  
my $port = 5432;  
my $username = 'postgres';  
my $password = '123456'; 


# Create DB handle object by connecting
my $dbh = DBI -> connect("dbi:Pg:dbname=$dbname;host=$host;port=$port",  
                            $username,
                            $password,
                            {AutoCommit => 0, RaiseError => 1}
                         ) or die $DBI::errstr;


# Trace to a file
$dbh -> trace(1, 'tracelog.txt');

# Drop table if it already exists
#my $SQL = "DROP TABLE IF EXISTS";  
#my $sth = $dbh->do($SQL);  
#$dbh->commit or die $DBI::errstr;


# Create a table
my $SQL = "CREATE TABLE account (
	id serial,
	user_id uuid UNIQUE NOT NULL,
	balance money NOT NULL,
	PRIMARY KEY (id));

        CREATE TABLE transaction (
                id bigserial,
                account_id serial NOT NULL,
                type CHAR NOT NULL,
                amount money NOT NULL,
                extra json,
                PRIMARY KEY (id),
                FOREIGN KEY (account_id) REFERENCES account (id)
        );

        CREATE TABLE yield_index (
                id serial,
                name VARCHAR (255) UNIQUE NOT NULL,
                income_rate decimal(3,2),
                PRIMARY KEY (id)
        );
";
my $sth = $dbh->do($SQL);  
$dbh->commit or die $DBI::errstr;

