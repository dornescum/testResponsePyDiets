-- Product Links Database Schema
-- E-commerce product links for diet templates
-- Run this after diet_system.sql

USE medical_clinic;

-- ============================================
-- DROP EXISTING TABLES (for re-run)
-- ============================================
DROP TABLE IF EXISTS diet_day_products;
DROP TABLE IF EXISTS diet_template_products;
DROP TABLE IF EXISTS product_links;

-- ============================================
-- PRODUCT LINKS TABLE
-- ============================================

-- Product registry for diet placeholders and affiliate links
CREATE TABLE IF NOT EXISTS product_links (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(50) NOT NULL COMMENT 'Internal code: colondrain_new, proteinsnack_cioccolato',
    name_it VARCHAR(100) NOT NULL COMMENT 'Product name in Italian',
    name_en VARCHAR(100) NULL COMMENT 'Product name in English',
    name_ro VARCHAR(100) NULL COMMENT 'Product name in Romanian',
    name_es VARCHAR(100) NULL COMMENT 'Product name in Spanish',
    base_url VARCHAR(255) NOT NULL COMMENT 'URL template: https://kirosdiet.com/{lang}/products/{slug}',
    category VARCHAR(50) NULL COMMENT 'Product category: supplements, snacks, drinks',
    status TINYINT(1) DEFAULT 1 COMMENT '1 = active, 0 = discontinued',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT product_code UNIQUE (product_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Product registry for diet placeholders and affiliate links';

-- Indexes for performance
CREATE INDEX idx_category ON product_links (category);
CREATE INDEX idx_status ON product_links (status);

-- ============================================
-- SEED DATA - Sample Kiros Products
-- ============================================

INSERT INTO product_links (product_code, name_it, name_en, base_url, category) VALUES
('colondrain_new', 'ColonDrain New', 'ColonDrain New', 'https://kirosdiet.com/{lang}/products/colondrain-new', 'supplements'),
('proteinsnack_cioccolato', 'Protein Snack Cioccolato', 'Protein Snack Chocolate', 'https://kirosdiet.com/{lang}/products/protein-snack-chocolate', 'snacks'),
('proteinsnack_vaniglia', 'Protein Snack Vaniglia', 'Protein Snack Vanilla', 'https://kirosdiet.com/{lang}/products/protein-snack-vanilla', 'snacks'),
('kiros_shake', 'Kiros Shake', 'Kiros Shake', 'https://kirosdiet.com/{lang}/products/kiros-shake', 'drinks'),
('omega3_plus', 'Omega 3 Plus', 'Omega 3 Plus', 'https://kirosdiet.com/{lang}/products/omega3-plus', 'supplements')
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- DIET TEMPLATE PRODUCTS (linking table)
-- ============================================

-- Links products to diet templates (for overall recommended products list)
CREATE TABLE IF NOT EXISTS diet_template_products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    template_id INT NOT NULL,
    product_id INT NOT NULL,
    usage_notes VARCHAR(255) NULL COMMENT 'e.g., "Take before breakfast", "As afternoon snack"',
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (template_id) REFERENCES diet_templates(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product_links(id) ON DELETE CASCADE,
    UNIQUE KEY unique_template_product (template_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Links products to diet templates';

-- ============================================
-- DIET DAY PRODUCTS (day-level product recommendations)
-- ============================================

-- Links products to specific diet days with timing/usage instructions
CREATE TABLE IF NOT EXISTS diet_day_products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    day_id INT NOT NULL,
    product_id INT NOT NULL,
    time_of_day ENUM('morning', 'afternoon', 'evening', 'with_meal', 'anytime') DEFAULT 'anytime',
    usage_notes VARCHAR(255) NULL COMMENT 'e.g., "Before breakfast", "As snack replacement"',
    quantity VARCHAR(50) NULL COMMENT 'e.g., "1 sachet", "2 capsules"',
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (day_id) REFERENCES diet_days(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product_links(id) ON DELETE CASCADE,
    UNIQUE KEY unique_day_product (day_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Links products to specific diet days';
