-- Create the read-only replication user
CREATE USER replication_user WITH REPLICATION PASSWORD 'repl_password';

-- Grant access to the database
GRANT CONNECT ON DATABASE airbyte_db TO replication_user;

-- Grant usage on public schema
-- Note: If you create additional schemas, you will need to grant USAGE on them as well.
GRANT USAGE ON SCHEMA public TO replication_user;

-- Grant select on all existing tables in public schema
GRANT SELECT ON ALL TABLES IN SCHEMA public TO replication_user;

-- Grant select on future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO replication_user;

-- Create the logical replication slot for Airbyte
SELECT pg_create_logical_replication_slot('airbyte_slot', 'pgoutput');

-- Create a sample users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Set replica identity to FULL (required for CDC to track deletions and updates correctly)
ALTER TABLE users REPLICA IDENTITY FULL;

-- Create a publication for Airbyte
-- This allows Airbyte to subscribe to changes on these tables
CREATE PUBLICATION airbyte_publication FOR TABLE users;

-- If you want to automatically include all future tables in the publication, 
-- you can use 'FOR ALL TABLES' (requires superuser, which 'admin' is):
-- ALTER PUBLICATION airbyte_publication ADD TABLE some_other_table;
