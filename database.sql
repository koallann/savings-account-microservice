CREATE DATABASE savings_account;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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

CREATE TABLE yield_index (
	id serial,
	name VARCHAR (255) UNIQUE NOT NULL,
	income_rate decimal(3,2),
	PRIMARY KEY (id)
);
