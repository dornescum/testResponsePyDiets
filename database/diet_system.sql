-- Diet System Database Schema
-- Run this after init.sql

USE medical_clinic;

-- ============================================
-- LOOKUP TABLES
-- ============================================

-- Diet Tags (religion, dietary, intolerance, health conditions)
CREATE TABLE IF NOT EXISTS diet_tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    category ENUM('religion', 'dietary', 'intolerance', 'health') NOT NULL,
    icon VARCHAR(50) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Food Categories (for grouping food items)
CREATE TABLE IF NOT EXISTS food_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    icon VARCHAR(50) NULL,
    color VARCHAR(20) NULL,
    sort_order INT DEFAULT 0
);

-- Food Items (master list with nutritional data)
CREATE TABLE IF NOT EXISTS food_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    default_portion_grams INT NOT NULL DEFAULT 100,
    calories_per_100g DECIMAL(6,2) NULL,
    protein_per_100g DECIMAL(5,2) NULL,
    carbs_per_100g DECIMAL(5,2) NULL,
    fat_per_100g DECIMAL(5,2) NULL,
    fiber_per_100g DECIMAL(5,2) NULL,
    is_snack_suitable TINYINT(1) DEFAULT 0,
    status TINYINT(1) DEFAULT 1,
    created_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES food_categories(id),
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Food Item Tags (link foods to restrictions)
CREATE TABLE IF NOT EXISTS food_item_tags (
    food_item_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (food_item_id, tag_id),
    FOREIGN KEY (food_item_id) REFERENCES food_items(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES diet_tags(id) ON DELETE CASCADE
);

-- ============================================
-- DIET TEMPLATES
-- ============================================

-- Diet Templates (base diet structure created by doctors)
CREATE TABLE IF NOT EXISTS diet_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    segment CHAR(1) NOT NULL,
    type VARCHAR(50) NOT NULL,
    duration_days INT NOT NULL DEFAULT 30,
    calories_target INT NULL,
    notes TEXT NULL,
    status TINYINT(1) DEFAULT 1,
    created_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Diet Template Tags (link templates to tags)
CREATE TABLE IF NOT EXISTS diet_template_tags (
    template_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (template_id, tag_id),
    FOREIGN KEY (template_id) REFERENCES diet_templates(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES diet_tags(id) ON DELETE CASCADE
);

-- Diet Days (days within a template, weekly cycle)
CREATE TABLE IF NOT EXISTS diet_days (
    id INT AUTO_INCREMENT PRIMARY KEY,
    template_id INT NOT NULL,
    day_number INT NOT NULL,
    day_name VARCHAR(20) NULL,
    notes TEXT NULL,
    FOREIGN KEY (template_id) REFERENCES diet_templates(id) ON DELETE CASCADE,
    UNIQUE KEY unique_day (template_id, day_number)
);

-- Diet Meals (meals for each day)
CREATE TABLE IF NOT EXISTS diet_meals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    day_id INT NOT NULL,
    meal_type ENUM('breakfast', 'lunch', 'dinner', 'snack') NOT NULL,
    meal_order INT DEFAULT 0,
    time_suggestion VARCHAR(10) NULL,
    notes TEXT NULL,
    FOREIGN KEY (day_id) REFERENCES diet_days(id) ON DELETE CASCADE
);

-- Diet Meal Items (food items within a meal)
CREATE TABLE IF NOT EXISTS diet_meal_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    meal_id INT NOT NULL,
    food_item_id INT NOT NULL,
    portion_grams_min INT NOT NULL,
    portion_grams_max INT NOT NULL,
    portion_description VARCHAR(100) NULL,
    preparation_notes VARCHAR(255) NULL,
    is_optional TINYINT(1) DEFAULT 0,
    sort_order INT DEFAULT 0,
    FOREIGN KEY (meal_id) REFERENCES diet_meals(id) ON DELETE CASCADE,
    FOREIGN KEY (food_item_id) REFERENCES food_items(id) ON DELETE RESTRICT
);

-- ============================================
-- PATIENT DIET ASSIGNMENT
-- ============================================

-- Patient Diets (assign diet to patient)
CREATE TABLE IF NOT EXISTS patient_diets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    template_id INT NOT NULL,
    assigned_by INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('active', 'completed', 'cancelled', 'paused') DEFAULT 'active',
    doctor_notes TEXT NULL,
    cancellation_reason TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (template_id) REFERENCES diet_templates(id) ON DELETE RESTRICT,
    FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE RESTRICT
);

-- Patient Diet History (audit log)
CREATE TABLE IF NOT EXISTS patient_diet_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_diet_id INT NOT NULL,
    action ENUM('assigned', 'started', 'paused', 'resumed', 'completed', 'cancelled', 'modified') NOT NULL,
    action_by INT NOT NULL,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    previous_status VARCHAR(20) NULL,
    new_status VARCHAR(20) NULL,
    notes TEXT NULL,
    ip_address VARCHAR(45) NULL,
    FOREIGN KEY (patient_diet_id) REFERENCES patient_diets(id) ON DELETE CASCADE,
    FOREIGN KEY (action_by) REFERENCES users(id) ON DELETE RESTRICT
);

-- ============================================
-- SEED DATA
-- ============================================

-- Diet Tags
INSERT INTO diet_tags (name, category, icon) VALUES
-- Religion
('halal', 'religion', 'fa-mosque'),
('kosher', 'religion', 'fa-star-of-david'),
('hindu', 'religion', 'fa-om'),
('no_restriction', 'religion', NULL),
-- Dietary
('vegan', 'dietary', 'fa-leaf'),
('vegetarian', 'dietary', 'fa-seedling'),
('pescatarian', 'dietary', 'fa-fish'),
('flexitarian', 'dietary', 'fa-utensils'),
-- Intolerance
('lactose_free', 'intolerance', 'fa-cheese'),
('gluten_free', 'intolerance', 'fa-bread-slice'),
('nut_free', 'intolerance', 'fa-ban'),
('egg_free', 'intolerance', 'fa-egg'),
-- Health
('diabetic', 'health', 'fa-syringe'),
('heart_friendly', 'health', 'fa-heart'),
('low_sodium', 'health', 'fa-tint'),
('renal', 'health', 'fa-kidneys'),
('hypertension', 'health', 'fa-heartbeat');

-- Food Categories
INSERT INTO food_categories (name, icon, color, sort_order) VALUES
('Fruits', 'fa-apple-alt', '#28a745', 1),
('Vegetables', 'fa-carrot', '#fd7e14', 2),
('Meat', 'fa-drumstick-bite', '#dc3545', 3),
('Fish', 'fa-fish', '#17a2b8', 4),
('Dairy', 'fa-cheese', '#ffc107', 5),
('Grains', 'fa-bread-slice', '#6f4e37', 6),
('Legumes', 'fa-seedling', '#20c997', 7),
('Beverages', 'fa-glass-water', '#0dcaf0', 8),
('Nuts & Seeds', 'fa-seedling', '#8B4513', 9),
('Oils & Fats', 'fa-oil-can', '#f4a460', 10);
