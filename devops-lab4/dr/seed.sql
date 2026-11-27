CREATE TABLE orders (id SERIAL PRIMARY KEY, item TEXT, created_at TIMESTAMP DEFAULT now());
INSERT INTO orders (item) SELECT 'item-' || g FROM generate_series(1,1000) g;
