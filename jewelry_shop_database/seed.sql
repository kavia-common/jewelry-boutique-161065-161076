-- Jewelry Shop Database Seed Data
-- Note: Default test user password is "Password123!" (stored as SHA2 hash for demo).
USE myapp;

SET FOREIGN_KEY_CHECKS = 0;

-- Test user
INSERT INTO users (id, email, password_hash, first_name, last_name, phone, is_active)
VALUES
  (1, 'test.user@example.com', SHA2('Password123!', 256), 'Test', 'User', '+1-555-0100', 1)
ON DUPLICATE KEY UPDATE id = id;

-- Addresses (stores and user shipping)
INSERT INTO addresses (id, user_id, full_name, line1, line2, city, state, postal_code, country, phone)
VALUES
  (1001, NULL, 'Downtown Boutique', '123 Market St', NULL, 'San Francisco', 'CA', '94103', 'USA', '+1-415-555-0001'),
  (1002, NULL, 'Uptown Boutique', '456 Madison Ave', NULL, 'New York', 'NY', '10022', 'USA', '+1-212-555-0002'),
  (1003, NULL, 'Lakeside Boutique', '789 Lake Shore Dr', 'Suite 200', 'Chicago', 'IL', '60611', 'USA', '+1-312-555-0003'),
  (2001, 1, 'Test User', '100 Main St', 'Apt 5', 'Austin', 'TX', '78701', 'USA', '+1-512-555-0101')
ON DUPLICATE KEY UPDATE id = id;

-- Stores
INSERT INTO stores (id, name, description, phone, email, address_id, latitude, longitude, is_active)
VALUES
  (1, 'Downtown Boutique', 'Flagship store with premium collection', '+1-415-555-0001', 'sf@boutique.example.com', 1001, 37.7749295, -122.4194155, 1),
  (2, 'Uptown Boutique', 'Luxury selection in uptown Manhattan', '+1-212-555-0002', 'nyc@boutique.example.com', 1002, 40.7588960, -73.9851300, 1),
  (3, 'Lakeside Boutique', 'Modern styles by the lake', '+1-312-555-0003', 'chi@boutique.example.com', 1003, 41.8781136, -87.6297982, 1)
ON DUPLICATE KEY UPDATE id = id;

-- Categories
INSERT INTO categories (id, name, slug, description, parent_id)
VALUES
  (1, 'Rings', 'rings', 'Fine rings for every occasion', NULL),
  (2, 'Necklaces', 'necklaces', 'Elegant necklaces in various styles', NULL),
  (3, 'Bracelets', 'bracelets', 'Bracelets from classic to trendy', NULL),
  (4, 'Earrings', 'earrings', 'Studs, hoops, and drops', NULL)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), parent_id = VALUES(parent_id);

-- Products
INSERT INTO products (id, name, slug, description, category_id, store_id, base_price, currency, is_active)
VALUES
  (1, 'Diamond Solitaire Ring', 'diamond-solitaire-ring', 'A timeless diamond solitaire ring set in 14K gold.', 1, 1, 899.99, 'USD', 1),
  (2, 'Classic Gold Necklace', 'classic-gold-necklace', '18-inch classic gold chain necklace.', 2, 2, 499.00, 'USD', 1),
  (3, 'Pearl Drop Earrings', 'pearl-drop-earrings', 'Elegant freshwater pearl drop earrings.', 4, 1, 199.50, 'USD', 1),
  (4, 'Sterling Silver Bracelet', 'sterling-silver-bracelet', 'Polished sterling silver bracelet with secure clasp.', 3, 3, 129.00, 'USD', 1)
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), category_id = VALUES(category_id), store_id = VALUES(store_id), base_price = VALUES(base_price), currency = VALUES(currency), is_active = VALUES(is_active);

-- Product Images
INSERT INTO product_images (id, product_id, url, alt_text, is_primary, sort_order)
VALUES
  (1, 1, 'https://example.com/images/ring1_main.jpg', 'Diamond Solitaire Ring - Main', 1, 1),
  (2, 1, 'https://example.com/images/ring1_alt1.jpg', 'Diamond Solitaire Ring - Side View', 0, 2),
  (3, 2, 'https://example.com/images/necklace1_main.jpg', 'Classic Gold Necklace - Main', 1, 1),
  (4, 3, 'https://example.com/images/earrings1_main.jpg', 'Pearl Drop Earrings - Main', 1, 1),
  (5, 4, 'https://example.com/images/bracelet1_main.jpg', 'Sterling Silver Bracelet - Main', 1, 1)
ON DUPLICATE KEY UPDATE product_id = VALUES(product_id), url = VALUES(url), alt_text = VALUES(alt_text), is_primary = VALUES(is_primary), sort_order = VALUES(sort_order);

-- Product Variants
INSERT INTO product_variants (id, product_id, sku, size, metal, color, price, stock, is_active)
VALUES
  -- Diamond Solitaire Ring variants
  (1, 1, 'RING-DSR-6-14K', '6', '14K Gold', 'Gold', 899.99, 10, 1),
  (2, 1, 'RING-DSR-7-14K', '7', '14K Gold', 'Gold', 899.99, 8, 1),
  -- Classic Gold Necklace variants
  (3, 2, 'NECK-GLD-18IN', '18 in', '14K Gold', 'Gold', 499.00, 15, 1),
  (4, 2, 'NECK-GLD-20IN', '20 in', '14K Gold', 'Gold', 529.00, 12, 1),
  -- Pearl Drop Earrings variants
  (5, 3, 'EAR-PEARL-STD', NULL, 'Sterling Silver', 'White', 199.50, 20, 1),
  -- Sterling Silver Bracelet variants
  (6, 4, 'BRC-SS-7IN', '7 in', 'Sterling Silver', 'Silver', 129.00, 25, 1),
  (7, 4, 'BRC-SS-8IN', '8 in', 'Sterling Silver', 'Silver', 139.00, 18, 1)
ON DUPLICATE KEY UPDATE product_id = VALUES(product_id), size = VALUES(size), metal = VALUES(metal), color = VALUES(color), price = VALUES(price), stock = VALUES(stock), is_active = VALUES(is_active);

-- Create a sample active cart for the test user
INSERT INTO carts (id, user_id, status)
VALUES (1, 1, 'active')
ON DUPLICATE KEY UPDATE user_id = VALUES(user_id), status = VALUES(status);

-- Add item to cart
INSERT INTO cart_items (id, cart_id, product_variant_id, quantity, unit_price)
VALUES (1, 1, 1, 1, 899.99)
ON DUPLICATE KEY UPDATE quantity = VALUES(quantity), unit_price = VALUES(unit_price);

-- Create a sample order for the test user using the address and cart
INSERT INTO orders (id, user_id, cart_id, address_id, status, subtotal, tax, shipping, total, currency, payment_method, payment_ref, placed_at)
VALUES (1, 1, 1, 2001, 'paid', 899.99, 81.00, 10.00, 990.99, 'USD', 'card', 'TEST-REF-0001', NOW())
ON DUPLICATE KEY UPDATE status = VALUES(status), subtotal = VALUES(subtotal), tax = VALUES(tax), shipping = VALUES(shipping), total = VALUES(total), payment_method = VALUES(payment_method), payment_ref = VALUES(payment_ref), placed_at = VALUES(placed_at);

-- Order item snapshot
INSERT INTO order_items (id, order_id, product_id, product_variant_id, product_name, sku, quantity, unit_price, total_price)
VALUES (1, 1, 1, 1, 'Diamond Solitaire Ring', 'RING-DSR-6-14K', 1, 899.99, 899.99)
ON DUPLICATE KEY UPDATE product_name = VALUES(product_name), sku = VALUES(sku), quantity = VALUES(quantity), unit_price = VALUES(unit_price), total_price = VALUES(total_price);

SET FOREIGN_KEY_CHECKS = 1;

-- End of seed
