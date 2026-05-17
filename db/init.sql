CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(150),
    city VARCHAR(100)
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    product_name VARCHAR(200),
    amount NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO customers (name, email, city)
VALUES
('David Cohen', 'david@test.com', 'Tel Aviv'),
('Sara Levi', 'sara@test.com', 'Jerusalem'),
('Moshe Azulay', 'moshe@test.com', 'Haifa');

INSERT INTO orders (customer_id, product_name, amount)
VALUES
(1, 'Laptop', 5200),
(1, 'Mouse', 120),
(2, 'Keyboard', 300),
(3, 'Monitor', 900);