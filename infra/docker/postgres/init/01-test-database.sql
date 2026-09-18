-- Runs once when the Postgres volume is first created.
-- The API's integration tests use a separate database so they can truncate
-- tables freely without touching development data.
CREATE DATABASE bebu_test OWNER bebu;
