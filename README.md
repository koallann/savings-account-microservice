# savings-account-microservice

A savings account microservice written in Perl to compose a banking system.

\* This application setup is Debian-based.

## Setup Perl dependencies

1. Install cpanminus (helper for CPAN):
    > sudo apt-get install cpanminus

2. Install DBI for database interface:
    > cpanm DBI

3. Install DBI extension for Postgres:
    > cpanm Class::DBI::Pg

## Setup Postgres database

1. See the `database.sql` file and create database and tables;

2. Create the user and set a password for it:
    > CREATE USER clp
    > ALTER USER clp WITH ENCRYPTED PASSWORD '123456';

3. Grant permissions on database, tables and sequences to the user:
    > GRANT ALL PRIVILEGES ON DATABASE savings_account TO clp;
    
    > GRANT ALL ON ALL TABLES TO clp;
    
    > GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO clp;

## Run app

> perl main.pl

This app exposes a HTTP API that runs on port 8000.

### Check balance of user account

GET /
```json
{
    "type": "savings_account",
    "action": "check",
    "content": {
        "user_uuid": "c5c73a11-d467-4b62-9ed5-2462a579f2b0"
    }
}
```

200 OK
```json
{
    "balance": 100
}
```

### Deposit to the user account

GET /
```json
{
    "type": "savings_account",
    "action": "deposit",
    "content": {
        "user_uuid": "c5c73a11-d467-4b62-9ed5-2462a579f2b0",
        "amount": 100
    }
}
```

200 OK
```json
{
    "result": "OK"
}
```

### Withdraw from the user account

GET /
```json
{
    "type": "savings_account",
    "action": "withdraw",
    "content": {
        "user_uuid": "c5c73a11-d467-4b62-9ed5-2462a579f2b0",
        "amount": 100
    }
}
```

200 OK
```json
{
    "result": "OK"
}
```
