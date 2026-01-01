-- Product Inventory System Migration
-- Adds inventory tracking for patient product consumption
-- Run this after product_links.sql
--
-- Features:
--   - Track product packaging (units per box)
--   - Daily dosage tracking per diet day
--   - Patient inventory with calculated consumption
--   - Low stock reminder support

USE medical_clinic;

-- ============================================
-- 1. ALTER PRODUCT_LINKS - Add packaging info
-- ============================================

ALTER TABLE product_links
    ADD COLUMN units_per_box INT NOT NULL DEFAULT 1
        COMMENT 'Number of units per box/package (e.g., 60 pills, 30 sachets)'
        AFTER category,
    ADD COLUMN unit_type VARCHAR(30) DEFAULT 'units'
        COMMENT 'Type of unit: pills, capsules, sachets, tablets, ml, grams'
        AFTER units_per_box;

-- Update existing products with realistic values
UPDATE product_links SET units_per_box = 60, unit_type = 'capsules'
    WHERE product_code = 'colondrain_new';
UPDATE product_links SET units_per_box = 10, unit_type = 'bars'
    WHERE product_code IN ('proteinsnack_cioccolato', 'proteinsnack_vaniglia');
UPDATE product_links SET units_per_box = 20, unit_type = 'sachets'
    WHERE product_code = 'kiros_shake';
UPDATE product_links SET units_per_box = 90, unit_type = 'softgels'
    WHERE product_code = 'omega3_plus';

-- ============================================
-- 2. ALTER DIET_DAY_PRODUCTS - Add daily dosage
-- ============================================

-- Change time_of_day from ENUM to VARCHAR to allow multiple times
-- e.g., "morning, before_sleep" instead of single value
ALTER TABLE diet_day_products
    MODIFY COLUMN time_of_day VARCHAR(100) DEFAULT 'anytime'
        COMMENT 'When to take: morning, afternoon, evening, before_sleep, with_meal, anytime (comma-separated for multiple)';

-- Add structured daily dosage for inventory calculation
ALTER TABLE diet_day_products
    ADD COLUMN units_per_day INT NOT NULL DEFAULT 1
        COMMENT 'Total units to consume per day (e.g., 2 pills = 1 morning + 1 evening)'
        AFTER quantity;

-- ============================================
-- 3. CREATE PATIENT_PRODUCT_INVENTORY TABLE
-- ============================================

-- Track product inventory per patient diet assignment
-- Consumption is calculated based on days elapsed (not manually tracked)
CREATE TABLE IF NOT EXISTS patient_product_inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Relationships
    patient_diet_id INT NOT NULL
        COMMENT 'Links to patient_diets - the assigned diet',
    product_id INT NOT NULL
        COMMENT 'Links to product_links - the product being tracked',

    -- Inventory data
    boxes_count INT NOT NULL DEFAULT 1
        COMMENT 'Number of boxes patient has/purchased',
    total_units INT NOT NULL
        COMMENT 'Total units available: boxes_count × units_per_box (set on insert)',
    units_per_day INT NOT NULL
        COMMENT 'Daily consumption rate (copied from diet_day_products)',

    -- Tracking dates
    started_at DATE NOT NULL
        COMMENT 'Date patient started using this product',

    -- Low stock reminder
    low_stock_threshold INT DEFAULT 10
        COMMENT 'Send reminder when units_remaining <= this value',
    low_stock_notified_at TIMESTAMP NULL
        COMMENT 'When low stock reminder was sent (NULL = not sent)',

    -- Audit
    notes VARCHAR(255) NULL
        COMMENT 'Optional notes about this inventory record',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Foreign keys
    FOREIGN KEY (patient_diet_id) REFERENCES patient_diets(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product_links(id) ON DELETE RESTRICT,

    -- One inventory record per product per patient diet
    UNIQUE KEY unique_patient_diet_product (patient_diet_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Tracks product inventory per patient diet for consumption calculation and low stock reminders';

-- Indexes for common queries
CREATE INDEX idx_patient_diet ON patient_product_inventory (patient_diet_id);
CREATE INDEX idx_product ON patient_product_inventory (product_id);
CREATE INDEX idx_low_stock_check ON patient_product_inventory (low_stock_notified_at, started_at);

-- ============================================
-- 4. VIEW FOR INVENTORY STATUS (optional helper)
-- ============================================

-- View to easily query current inventory status with calculated fields
CREATE OR REPLACE VIEW v_patient_product_status AS
SELECT
    ppi.id,
    ppi.patient_diet_id,
    ppi.product_id,
    pl.product_code,
    pl.name_it AS product_name,
    pl.unit_type,
    ppi.boxes_count,
    ppi.total_units,
    ppi.units_per_day,
    ppi.started_at,
    ppi.low_stock_threshold,
    ppi.low_stock_notified_at,

    -- Calculated fields
    DATEDIFF(CURRENT_DATE, ppi.started_at) AS days_elapsed,
    GREATEST(0, DATEDIFF(CURRENT_DATE, ppi.started_at) * ppi.units_per_day) AS units_consumed,
    GREATEST(0, ppi.total_units - (DATEDIFF(CURRENT_DATE, ppi.started_at) * ppi.units_per_day)) AS units_remaining,

    -- Status flags
    CASE
        WHEN (ppi.total_units - (DATEDIFF(CURRENT_DATE, ppi.started_at) * ppi.units_per_day)) <= 0
            THEN 'depleted'
        WHEN (ppi.total_units - (DATEDIFF(CURRENT_DATE, ppi.started_at) * ppi.units_per_day)) <= ppi.low_stock_threshold
            THEN 'low_stock'
        ELSE 'ok'
    END AS stock_status,

    -- Days until depleted
    CASE
        WHEN ppi.units_per_day > 0
            THEN FLOOR((ppi.total_units - (DATEDIFF(CURRENT_DATE, ppi.started_at) * ppi.units_per_day)) / ppi.units_per_day)
        ELSE NULL
    END AS days_remaining,

    -- Patient and diet info
    pd.patient_id,
    pd.start_date AS diet_start_date,
    pd.end_date AS diet_end_date,
    pd.status AS diet_status
FROM patient_product_inventory ppi
JOIN product_links pl ON pl.id = ppi.product_id
JOIN patient_diets pd ON pd.id = ppi.patient_diet_id;

-- ============================================
-- 5. EXAMPLE QUERIES
-- ============================================

-- Find all products needing low stock reminder:
-- SELECT * FROM v_patient_product_status
-- WHERE stock_status = 'low_stock'
--   AND low_stock_notified_at IS NULL
--   AND diet_status = 'active';

-- Get inventory for a specific patient diet:
-- SELECT * FROM v_patient_product_status WHERE patient_diet_id = 1;

-- Mark reminder as sent:
-- UPDATE patient_product_inventory
-- SET low_stock_notified_at = CURRENT_TIMESTAMP
-- WHERE id = ?;
