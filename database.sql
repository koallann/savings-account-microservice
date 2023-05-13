CREATE DATABASE savings_account;

\c savings_account;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE account (
	user_uuid uuid,
	balance money NOT NULL,
	PRIMARY KEY (user_uuid)
);

CREATE TABLE transaction (
	id bigserial,
	user_uuid uuid NOT NULL,
	type CHAR NOT NULL,
	amount money NOT NULL,
	timestamp TIMESTAMP DEFAULT current_timestamp,
	PRIMARY KEY (id),
	FOREIGN KEY (user_uuid) REFERENCES account (user_uuid)
);
