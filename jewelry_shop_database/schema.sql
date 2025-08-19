-- Jewelry Shop Database Schema (MySQL)
-- This schema defines tables for users, addresses, categories, products, product_images,
-- product_variants, carts, cart_items, orders, order_items, and stores.
-- Engine: InnoDB
-- Charset: utf8mb4

-- Ensure database exists and is selected
CREATE DATABASE IF NOT EXISTS myapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE myapp;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  email VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone VARCHAR(30),
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  KEY idx_users_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Addresses table
CREATE TABLE IF NOT EXISTS addresses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NULL,
  full_name VARCHAR(150),
  line1 VARCHAR(255) NOT NULL,
  line2 VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  postal_code VARCHAR(20),
  country VARCHAR(100) NOT NULL DEFAULT 'USA',
  phone VARCHAR(30),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_addresses_user_id (user_id),
  CONSTRAINT fk_addresses_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Stores table
CREATE TABLE IF NOT EXISTS stores (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  phone VARCHAR(30),
  email VARCHAR(255),
  address_id BIGINT UNSIGNED NULL,
  latitude DECIMAL(10,7),
  longitude DECIMAL(10,7),
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_stores_name (name),
  KEY idx_stores_address_id (address_id),
  KEY idx_stores_active (is_active),
  CONSTRAINT fk_stores_address
    FOREIGN KEY (address_id) REFERENCES addresses(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  slug VARCHAR(160) NOT NULL,
  description TEXT,
  parent_id BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_categories_slug (slug),
  KEY idx_categories_name (name),
  KEY idx_categories_parent_id (parent_id),
  CONSTRAINT fk_categories_parent
    FOREIGN KEY (parent_id) REFERENCES categories(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Products table
CREATE TABLE IF NOT EXISTS products (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  description TEXT,
  category_id BIGINT UNSIGNED NOT NULL,
  store_id BIGINT UNSIGNED NULL,
  base_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_products_slug (slug),
  KEY idx_products_category (category_id),
  KEY idx_products_store (store_id),
  KEY idx_products_active (is_active),
  CONSTRAINT fk_products_category
    FOREIGN KEY (category_id) REFERENCES categories(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_products_store
    FOREIGN KEY (store_id) REFERENCES stores(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Product Images table
CREATE TABLE IF NOT EXISTS product_images (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id BIGINT UNSIGNED NOT NULL,
  url VARCHAR(1024) NOT NULL,
  alt_text VARCHAR(255),
  is_primary TINYINT(1) NOT NULL DEFAULT 0,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_product_images_product (product_id),
  KEY idx_product_images_primary (is_primary),
  CONSTRAINT fk_product_images_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Product Variants table
CREATE TABLE IF NOT EXISTS product_variants (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id BIGINT UNSIGNED NOT NULL,
  sku VARCHAR(100) NOT NULL,
  size VARCHAR(50),
  metal VARCHAR(50),
  color VARCHAR(50),
  price DECIMAL(10,2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_variants_sku (sku),
  KEY idx_variants_product (product_id),
  KEY idx_variants_active (is_active),
  CONSTRAINT fk_variants_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Carts table
CREATE TABLE IF NOT EXISTS carts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NULL,
  status ENUM('active', 'converted', 'abandoned') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_carts_user (user_id),
  KEY idx_carts_status (status),
  CONSTRAINT fk_carts_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Cart Items table
CREATE TABLE IF NOT EXISTS cart_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cart_id BIGINT UNSIGNED NOT NULL,
  product_variant_id BIGINT UNSIGNED NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_cart_item_variant (cart_id, product_variant_id),
  KEY idx_cart_items_cart (cart_id),
  KEY idx_cart_items_variant (product_variant_id),
  CONSTRAINT fk_cart_items_cart
    FOREIGN KEY (cart_id) REFERENCES carts(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_cart_items_variant
    FOREIGN KEY (product_variant_id) REFERENCES product_variants(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NULL,
  cart_id BIGINT UNSIGNED NULL,
  address_id BIGINT UNSIGNED NULL,
  status ENUM('pending','paid','shipped','delivered','cancelled','refunded') NOT NULL DEFAULT 'pending',
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  tax DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  shipping DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  payment_method VARCHAR(50),
  payment_ref VARCHAR(100),
  placed_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_orders_user (user_id),
  KEY idx_orders_status (status),
  KEY idx_orders_placed (placed_at),
  CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_orders_cart
    FOREIGN KEY (cart_id) REFERENCES carts(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_orders_address
    FOREIGN KEY (address_id) REFERENCES addresses(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Order Items table
CREATE TABLE IF NOT EXISTS order_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NULL,
  product_variant_id BIGINT UNSIGNED NULL,
  product_name VARCHAR(255) NOT NULL,
  sku VARCHAR(100),
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_order_items_order (order_id),
  KEY idx_order_items_variant (product_variant_id),
  KEY idx_order_items_product (product_id),
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_order_items_variant
    FOREIGN KEY (product_variant_id) REFERENCES product_variants(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- End of schema
