-- Insert sample data into customers table
INSERT INTO customers (first_name, last_name, email, phone_number, address, city, state, postal_code)
VALUES
('John', 'Doe', 'john.doe@example.com', '555-555-1234', '123 Main St', 'New York', 'NY', '10001'),
('Jane', 'Smith', 'jane.smith@example.com', '555-555-5678', '456 Elm St', 'Los Angeles', 'CA', '90001');

-- Insert sample data into restaurants table
INSERT INTO restaurants (name, address, city, state, postal_code, phone_number, email)
VALUES
('Pizza Place', '789 Oak St', 'New York', 'NY', '10001', '555-555-9876', 'contact@pizzaplace.com'),
('Sushi Spot', '321 Pine St', 'Los Angeles', 'CA', '90001', '555-555-5432', 'contact@sushispot.com');

-- Insert sample data into food_items table
INSERT INTO food_items (restaurant_id, name, description, price, available)
VALUES
(1, 'Pepperoni Pizza', 'A delicious pizza with pepperoni', 12.99, TRUE),
(1, 'Cheese Pizza', 'Classic cheese pizza', 10.99, TRUE),
(2, 'Sushi Roll', 'Fresh sushi roll with salmon and avocado', 8.99, TRUE),
(2, 'Sashimi Platter', 'Assorted sashimi with tuna and salmon', 14.99, TRUE);

-- Insert sample data into orders table
INSERT INTO orders (customer_id, restaurant_id, order_status, total_price)
VALUES
(1, 1, 'Completed', 23.98),
(2, 2, 'Pending', 14.99);

-- Insert sample data into order_items table
INSERT INTO order_items (order_id, food_item_id, quantity, price)
VALUES
(1, 1, 1, 12.99), -- John ordered 1 Pepperoni Pizza
(1, 2, 1, 10.99), -- John also ordered 1 Cheese Pizza
(2, 3, 2, 8.99);  -- Jane ordered 2 Sushi Rolls
