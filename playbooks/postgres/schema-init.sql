-- PostgreSQL Schema-based Production/Testing Setup
-- This script initializes prod and test schemas with proper permissions

-- Create schemas
CREATE SCHEMA IF NOT EXISTS prod;
CREATE SCHEMA IF NOT EXISTS test;

-- Create dedicated users for each schema
CREATE USER prod_user WITH PASSWORD 'prod123';
CREATE USER test_user WITH PASSWORD 'test123';

-- Grant schema permissions
GRANT USAGE ON SCHEMA prod TO prod_user;
GRANT CREATE ON SCHEMA prod TO prod_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA prod TO prod_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA prod TO prod_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA prod GRANT ALL ON TABLES TO prod_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA prod GRANT ALL ON SEQUENCES TO prod_user;

GRANT USAGE ON SCHEMA test TO test_user;
GRANT CREATE ON SCHEMA test TO test_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA test TO test_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA test TO test_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA test GRANT ALL ON TABLES TO test_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA test GRANT ALL ON SEQUENCES TO test_user;

-- Allow cross-schema read access for data migration/testing
GRANT USAGE ON SCHEMA prod TO test_user;
GRANT SELECT ON ALL TABLES IN SCHEMA prod TO test_user;

-- Create sample tables to demonstrate schema separation
CREATE TABLE prod.users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    environment VARCHAR(10) DEFAULT 'production'
);

CREATE TABLE test.users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    environment VARCHAR(10) DEFAULT 'testing'
);

CREATE TABLE prod.orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES prod.users(id),
    amount DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE test.orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES test.users(id),
    amount DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample data
INSERT INTO prod.users (username, email) VALUES 
    ('john_prod', 'john@company.com'),
    ('jane_prod', 'jane@company.com');

INSERT INTO test.users (username, email) VALUES 
    ('john_test', 'john.test@company.com'),
    ('jane_test', 'jane.test@company.com'),
    ('test_user1', 'test1@example.com');

INSERT INTO prod.orders (user_id, amount, status) VALUES 
    (1, 99.99, 'completed'),
    (2, 149.50, 'pending');

INSERT INTO test.orders (user_id, amount, status) VALUES 
    (1, 10.00, 'test_order'),
    (2, 5.99, 'test_pending'),
    (3, 999.99, 'stress_test');

-- Create views for easy access
CREATE VIEW prod.user_orders AS 
SELECT u.username, u.email, o.amount, o.status, o.created_at
FROM prod.users u 
JOIN prod.orders o ON u.id = o.user_id;

CREATE VIEW test.user_orders AS 
SELECT u.username, u.email, o.amount, o.status, o.created_at
FROM test.users u 
JOIN test.orders o ON u.id = o.user_id;

-- Create function to copy data from prod to test (useful for testing)
CREATE OR REPLACE FUNCTION copy_prod_to_test() 
RETURNS TEXT AS $$
BEGIN
    -- Clear test data
    TRUNCATE test.orders CASCADE;
    TRUNCATE test.users CASCADE;
    
    -- Copy users (modify to test environment)
    INSERT INTO test.users (username, email, environment)
    SELECT 
        username || '_test',
        REPLACE(email, '@', '_test@'),
        'testing'
    FROM prod.users;
    
    -- Copy orders with updated user_ids
    INSERT INTO test.orders (user_id, amount, status)
    SELECT 
        tu.id,
        po.amount,
        'test_' || po.status
    FROM prod.orders po
    JOIN prod.users pu ON po.user_id = pu.id
    JOIN test.users tu ON tu.username = pu.username || '_test';
    
    RETURN 'Production data copied to test environment successfully';
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION copy_prod_to_test() TO test_user;

-- Set default search paths for users
ALTER USER prod_user SET search_path = prod, public;
ALTER USER test_user SET search_path = test, public;

-- Create information view
CREATE VIEW public.schema_info AS
SELECT 
    'prod' as schema_name,
    (SELECT COUNT(*) FROM prod.users) as user_count,
    (SELECT COUNT(*) FROM prod.orders) as order_count,
    'Production Environment' as description
UNION ALL
SELECT 
    'test' as schema_name,
    (SELECT COUNT(*) FROM test.users) as user_count,
    (SELECT COUNT(*) FROM test.orders) as order_count,
    'Testing Environment' as description;

COMMENT ON VIEW public.schema_info IS 'Quick overview of prod vs test data';

-- Display setup completion
SELECT 'Schema-based Production/Testing setup completed!' as status;
SELECT * FROM public.schema_info; 