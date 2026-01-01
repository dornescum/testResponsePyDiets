# Diet System - Implementation Guide

## Overview

A comprehensive diet management system for a medical weight-loss platform. Doctors create diet templates, staff manage food items, and patients receive personalized diet plans with product inventory tracking.

**Status: IMPLEMENTED**

---

## Quick Start

### 1. Run Database Migrations

```bash
# Create tables and seed lookup data
mysql -u clinic_user -p medical_clinic < database/diet_system.sql

# Load demo data (optional - includes sample foods and 6 diet templates)
mysql -u clinic_user -p medical_clinic < database/diet_demo_data.sql

# Load product links (e-commerce products for diet templates)
mysql -u clinic_user -p medical_clinic < database/product_links.sql

# Load product inventory system (tracking patient product consumption)
mysql -u clinic_user -p medical_clinic < database/product_inventory.sql
```

### 2. Access the System

- **Dashboard**: Diet Management section visible for Admin/Doctor roles
- **Food Items**: `/foods/items`
- **Food Categories**: `/foods/categories`
- **Diet Tags**: `/foods/tags`
- **Diet Templates**: `/diets/templates`
- **Patient Diets**: `/diets/assigned` (searchable by patient name or diet)
- **Product Links**: `/products` (e-commerce products for diet templates)
- **Patient View**: `/patients/:id` (includes product inventory section)

---

## File Structure

```
src/
├── controllers/
│   ├── FoodController.js      # Food items, categories, tags CRUD
│   ├── DietController.js      # Diet templates, days, meals, patient assignment
│   │                          # Auto-creates product inventory on diet assignment
│   ├── ProductController.js   # Product links CRUD
│   └── PatientController.js   # Patient view with inventory display
├── models/
│   └── database.js            # Added: DietTag, FoodCategory, FoodItem,
│                              #        DietTemplate, DietDay, DietMeal,
│                              #        DietMealItem, PatientDiet, PatientDietHistory,
│                              #        ProductLink, DietDayProduct,
│                              #        PatientProductInventory
├── routes/
│   ├── foods.js               # /foods/* routes
│   ├── diets.js               # /diets/* routes
│   └── products.js            # /products/* routes
└── views/
    ├── foods/
    │   ├── categories.ejs     # List categories
    │   ├── category-form.ejs  # Add/edit category
    │   ├── items.ejs          # List food items
    │   ├── item-form.ejs      # Add/edit food item
    │   ├── item-view.ejs      # View food item details
    │   ├── tags.ejs           # List diet tags
    │   └── tag-form.ejs       # Add/edit tag
    ├── diets/
    │   ├── templates.ejs      # List diet templates
    │   ├── template-form.ejs  # Create template
    │   ├── template-view.ejs  # View template details
    │   ├── template-edit.ejs  # Edit with day/meal builder
    │   ├── patient-diets.ejs  # List all patient diets (paginated, searchable)
    │   ├── assign.ejs         # Assign diet to patient
    │   ├── patient-diet.ejs   # View patient's diet
    │   └── patient-history.ejs # Patient diet history
    ├── products/
    │   ├── list.ejs           # List product links
    │   └── form.ejs           # Add/edit product link (with units_per_box, unit_type)
    └── patients/
        └── view.ejs           # Patient view with product inventory section

database/
├── diet_system.sql            # Schema + seed data for tags/categories
├── diet_demo_data.sql         # Demo food items + 6 sample templates
├── product_links.sql          # E-commerce product links schema + seed data
└── product_inventory.sql      # Product inventory tracking schema + view
```

---

## Database Schema

### 1. Lookup Tables

#### `diet_tags`
Categories for filtering diets (religion, dietary restrictions, health conditions).

```sql
CREATE TABLE diet_tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    category ENUM('religion', 'dietary', 'intolerance', 'health') NOT NULL,
    icon VARCHAR(50) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Seed Data:**
| Category | Tags |
|----------|------|
| religion | halal, kosher, hindu, no_restriction |
| dietary | vegan, vegetarian, pescatarian, flexitarian |
| intolerance | lactose_free, gluten_free, nut_free, egg_free |
| health | diabetic, heart_friendly, low_sodium, renal, hypertension |

---

#### `food_categories`
Icons and grouping for food items.

```sql
CREATE TABLE food_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    icon VARCHAR(50) NULL,              -- Nullable for categories without icons
    color VARCHAR(20) NULL,
    sort_order INT DEFAULT 0
);
```

**Seed Data:**
| Name | Icon | Color |
|------|------|-------|
| Fruits | fa-apple-alt | #28a745 |
| Vegetables | fa-carrot | #fd7e14 |
| Meat | fa-drumstick-bite | #dc3545 |
| Fish | fa-fish | #17a2b8 |
| Dairy | fa-cheese | #ffc107 |
| Grains | fa-bread-slice | #6f4e37 |
| Legumes | fa-seedling | #20c997 |
| Beverages | fa-glass-water | #0dcaf0 |
| Nuts & Seeds | fa-seedling | #8B4513 |
| Oils & Fats | fa-oil-can | #f4a460 |

---

#### `food_items`
Master list of foods with nutritional data.

```sql
CREATE TABLE food_items (
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
```

---

#### `food_item_tags`
Link foods to dietary restrictions.

```sql
CREATE TABLE food_item_tags (
    food_item_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (food_item_id, tag_id),
    FOREIGN KEY (food_item_id) REFERENCES food_items(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES diet_tags(id) ON DELETE CASCADE
);
```

---

### 2. Diet Templates

#### `diet_templates`
Base diet structure created by doctors.

```sql
CREATE TABLE diet_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    segment CHAR(1) NOT NULL COMMENT 'Weight segment: A, B, C, or D',
    type VARCHAR(50) NOT NULL COMMENT 'Diet type: SCR (Standard Caloric Restriction), LGI (Low Glycemic Index), KTP (Ketogenic Therapy Protocol)',
    duration_days INT NOT NULL DEFAULT 30,
    calories_target INT NULL,
    notes TEXT NULL,
    status TINYINT(1) DEFAULT 1,
    created_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);
```

#### `diet_template_tags`
```sql
CREATE TABLE diet_template_tags (
    template_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (template_id, tag_id),
    FOREIGN KEY (template_id) REFERENCES diet_templates(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES diet_tags(id) ON DELETE CASCADE
);
```

#### `diet_days`
```sql
CREATE TABLE diet_days (
    id INT AUTO_INCREMENT PRIMARY KEY,
    template_id INT NOT NULL,
    day_number INT NOT NULL,
    day_name VARCHAR(20) NULL,
    notes TEXT NULL,
    FOREIGN KEY (template_id) REFERENCES diet_templates(id) ON DELETE CASCADE,
    UNIQUE KEY unique_day (template_id, day_number)
);
```

#### `diet_meals`
```sql
CREATE TABLE diet_meals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    day_id INT NOT NULL,
    meal_type ENUM('breakfast', 'lunch', 'dinner', 'snack') NOT NULL,
    meal_order INT DEFAULT 0,
    time_suggestion VARCHAR(10) NULL,
    notes TEXT NULL,
    FOREIGN KEY (day_id) REFERENCES diet_days(id) ON DELETE CASCADE
);
```

#### `diet_meal_items`
```sql
CREATE TABLE diet_meal_items (
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
```

---

### 3. Patient Diet Assignment

#### `patient_diets`
```sql
CREATE TABLE patient_diets (
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
```

#### `patient_diet_history`
Audit log for legal/medical tracking.

```sql
CREATE TABLE patient_diet_history (
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
```

---

### 4. Product Links (E-commerce)

#### `product_links`
Product registry for diet placeholders and affiliate links (e.g., Kiros products).

```sql
CREATE TABLE product_links (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(50) NOT NULL UNIQUE COMMENT 'Internal code: colondrain_new, proteinsnack_cioccolato',
    name_it VARCHAR(100) NOT NULL COMMENT 'Product name in Italian',
    name_en VARCHAR(100) NULL COMMENT 'Product name in English',
    name_ro VARCHAR(100) NULL COMMENT 'Product name in Romanian',
    name_es VARCHAR(100) NULL COMMENT 'Product name in Spanish',
    base_url VARCHAR(255) NOT NULL COMMENT 'URL template: https://kirosdiet.com/{lang}/products/{slug}',
    category VARCHAR(50) NULL COMMENT 'Product category: supplements, snacks, drinks, meals, other',
    units_per_box INT NOT NULL DEFAULT 1 COMMENT 'Number of units per box/package (e.g., 60 pills, 30 sachets)',
    unit_type VARCHAR(30) DEFAULT 'units' COMMENT 'Type of unit: pills, capsules, sachets, tablets, ml, grams',
    status TINYINT(1) DEFAULT 1 COMMENT '1 = active, 0 = discontinued',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**URL Template Example:**
```
https://kirosdiet.com/{lang}/products/colondrain-new
```
The `{lang}` placeholder is replaced with `it`, `en`, `ro`, or `es` when generating links.

**Unit Types:**
- `pills`, `capsules`, `tablets`, `softgels` - for supplements
- `sachets`, `bars` - for meal replacements/snacks
- `bottles`, `ml`, `grams` - for liquids/powders
- `units` - generic default

#### `diet_day_products`
Products recommended for specific days within a diet template. Allows different product recommendations per day.

```sql
CREATE TABLE diet_day_products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    day_id INT NOT NULL COMMENT 'Links to diet_days',
    product_id INT NOT NULL COMMENT 'Links to product_links',
    time_of_day VARCHAR(100) DEFAULT 'anytime' COMMENT 'When to take: morning, afternoon, evening, before_sleep, with_meal, anytime (comma-separated for multiple)',
    usage_notes VARCHAR(255) NULL COMMENT 'e.g., "Take before breakfast"',
    quantity VARCHAR(50) NULL COMMENT 'e.g., "2 capsules", "1 sachet"',
    units_per_day INT NOT NULL DEFAULT 1 COMMENT 'Total units to consume per day (e.g., 2 pills = 1 morning + 1 evening)',
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (day_id) REFERENCES diet_days(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product_links(id) ON DELETE CASCADE,
    UNIQUE KEY unique_day_product (day_id, product_id)
);
```

**Usage:**
- Products are added at the **day level** (not template level) for more granular control
- Each day can have different products with different time-of-day recommendations
- `units_per_day` is used for inventory consumption calculation
- The template view and patient diet view show:
  - Products per day (within each day card)
  - Summary of all unique products (for patient's shopping list / email with discount code)

**Unique Products Aggregation:**
The `DietDayProduct.getUniqueProductsByTemplateId()` query aggregates products across all days:
- `total_units_needed` - Sum of all quantities across days
- `days_prescribed` - Number of days the product is assigned
- `combined_usage_notes` - All unique usage notes merged with `;` separator
- `remaining_in_box` - `units_per_box - total_units_needed` (calculated field)

---

### 5. Patient Product Inventory

#### `patient_product_inventory`
Tracks product consumption per patient diet. Consumption is calculated based on days elapsed (not manually tracked).

```sql
CREATE TABLE patient_product_inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_diet_id INT NOT NULL COMMENT 'Links to patient_diets - the assigned diet',
    product_id INT NOT NULL COMMENT 'Links to product_links - the product being tracked',
    boxes_count INT NOT NULL DEFAULT 1 COMMENT 'Number of boxes patient has/purchased',
    total_units INT NOT NULL COMMENT 'Total units available: boxes_count × units_per_box (set on insert)',
    units_per_day INT NOT NULL COMMENT 'Daily consumption rate (from diet_day_products)',
    started_at DATE NOT NULL COMMENT 'Date patient started using this product',
    low_stock_threshold INT DEFAULT 10 COMMENT 'Send reminder when units_remaining <= this value',
    low_stock_notified_at TIMESTAMP NULL COMMENT 'When low stock reminder was sent (NULL = not sent)',
    notes VARCHAR(255) NULL COMMENT 'Optional notes about this inventory record',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_diet_id) REFERENCES patient_diets(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product_links(id) ON DELETE RESTRICT,
    UNIQUE KEY unique_patient_diet_product (patient_diet_id, product_id)
);
```

#### `v_patient_product_status` (View)
Helper view for querying inventory status with calculated fields.

```sql
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
        WHEN (ppi.total_units - (DATEDIFF(CURRENT_DATE, ppi.started_at) * ppi.units_per_day)) <= 0 THEN 'depleted'
        WHEN (ppi.total_units - (DATEDIFF(CURRENT_DATE, ppi.started_at) * ppi.units_per_day)) <= ppi.low_stock_threshold THEN 'low_stock'
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
```

**Inventory Flow:**
1. Doctor assigns diet to patient → `patient_diets` record created
2. System auto-creates `patient_product_inventory` records for all products in the template
3. Consumption is calculated based on `days_elapsed × units_per_day`
4. When `units_remaining <= low_stock_threshold`, system can send reminder email
5. Patient view (`/patients/:id`) displays inventory status with progress bars

**Calculated Fields:**
- `days_elapsed` - Days since patient started using the product
- `units_consumed` - `days_elapsed × units_per_day`
- `units_remaining` - `total_units - units_consumed`
- `stock_status` - `ok`, `low_stock`, or `depleted`
- `days_remaining` - How many days of supply left

---

## Routes

### Food Management (`/foods`)

| Method | Route | Description | Access |
|--------|-------|-------------|--------|
| GET | `/foods/categories` | List all categories | Staff, Admin |
| GET | `/foods/categories/add` | Add category form | Admin |
| POST | `/foods/categories` | Create category | Admin |
| GET | `/foods/categories/:id/edit` | Edit category form | Admin |
| POST | `/foods/categories/:id` | Update category | Admin |
| POST | `/foods/categories/:id/delete` | Delete category | Admin |
| GET | `/foods/items` | List all food items | Staff, Admin |
| GET | `/foods/items/search` | Search foods (API) | Staff, Admin |
| GET | `/foods/items/add` | Add food item form | Staff, Admin |
| POST | `/foods/items` | Create food item | Staff, Admin |
| GET | `/foods/items/:id` | View food item | Staff, Admin |
| GET | `/foods/items/:id/edit` | Edit food item form | Staff, Admin |
| POST | `/foods/items/:id` | Update food item | Staff, Admin |
| POST | `/foods/items/:id/archive` | Archive food item | Admin |
| GET | `/foods/tags` | List all diet tags | Staff, Admin |
| GET | `/foods/tags/add` | Add tag form | Admin |
| POST | `/foods/tags` | Create tag | Admin |
| GET | `/foods/tags/:id/edit` | Edit tag form | Admin |
| POST | `/foods/tags/:id` | Update tag | Admin |
| POST | `/foods/tags/:id/delete` | Delete tag | Admin |

### Diet Templates (`/diets`)

| Method | Route | Description | Access |
|--------|-------|-------------|--------|
| GET | `/diets/assigned` | List all patient diets (paginated, searchable) | Staff, Admin |
| GET | `/diets/templates` | List all templates | Staff, Admin |
| GET | `/diets/templates/add` | Create template form | Admin |
| POST | `/diets/templates` | Create template | Admin |
| GET | `/diets/templates/:id` | View template | Staff, Admin |
| GET | `/diets/templates/:id/edit` | Edit template (builder) | Admin |
| POST | `/diets/templates/:id` | Update template info | Admin |
| POST | `/diets/templates/:id/archive` | Archive template | Admin |
| POST | `/diets/templates/:id/clone` | Clone template | Admin |
| POST | `/diets/templates/:templateId/days` | Add day | Admin |
| POST | `/diets/templates/:templateId/days/:dayId` | Update day | Admin |
| POST | `/diets/templates/:templateId/days/:dayId/delete` | Delete day | Admin |
| POST | `/diets/templates/:templateId/days/:dayId/meals` | Add meal | Admin |
| POST | `/diets/templates/:templateId/meals/:mealId` | Update meal | Admin |
| POST | `/diets/templates/:templateId/meals/:mealId/delete` | Delete meal | Admin |
| POST | `/diets/templates/:templateId/meals/:mealId/items` | Add food to meal | Admin |
| POST | `/diets/templates/:templateId/items/:itemId` | Update meal item | Admin |
| POST | `/diets/templates/:templateId/items/:itemId/delete` | Remove from meal | Admin |
| POST | `/diets/templates/:templateId/days/:dayId/products` | Add product to day | Admin |
| POST | `/diets/templates/:templateId/day-products/:productId/delete` | Remove product from day | Admin |

### Patient Diets (`/diets/patients`)

| Method | Route | Description | Access |
|--------|-------|-------------|--------|
| GET | `/diets/patients/:patientId/assign` | Assign diet form | Admin |
| POST | `/diets/patients/:patientId/assign` | Assign diet (auto-creates inventory) | Admin |
| GET | `/diets/patients/:patientId/diets/:dietId` | View patient diet | Staff, Admin |
| POST | `/diets/patients/:patientId/diets/:dietId/cancel` | Cancel diet | Admin |
| POST | `/diets/patients/:patientId/diets/:dietId/pause` | Pause diet | Admin |
| POST | `/diets/patients/:patientId/diets/:dietId/resume` | Resume diet | Admin |
| GET | `/diets/patients/:patientId/history` | Diet history | Staff, Admin |

### Product Links (`/products`)

| Method | Route | Description | Access |
|--------|-------|-------------|--------|
| GET | `/products` | List all products (paginated, searchable) | Admin |
| GET | `/products/add` | Add product form | Admin |
| POST | `/products` | Create product | Admin |
| GET | `/products/:id/edit` | Edit product form (with units_per_box, unit_type) | Admin |
| POST | `/products/:id` | Update product | Admin |
| POST | `/products/:id/toggle` | Toggle product status | Admin |
| POST | `/products/:id/delete` | Delete product | Admin |

---

## Weight Segments

| Segment | Weight Range | Calorie Target (approx) |
|---------|--------------|-------------------------|
| A | < 55 kg | 1200-1400 kcal |
| B | 55-65 kg | 1400-1600 kcal |
| C | 65-85 kg | 1600-1800 kcal |
| D | > 85 kg | 1800-2000 kcal |

---

## Demo Data

The `diet_demo_data.sql` file includes:

### Sample Food Items (~50 items)
- Fruits, Vegetables, Meat, Fish, Dairy
- Grains, Legumes, Nuts & Seeds
- Oils & Fats, Beverages

### 6 Demo Diet Templates

| Code | Type | Segment | Calories | Description |
|------|------|---------|----------|-------------|
| SCR_A_STANDARD | SCR | A | 1300 | Standard Caloric Restriction for <55kg |
| SCR_C_STANDARD | SCR | C | 1700 | Standard Caloric Restriction for 65-85kg |
| LGI_B_STANDARD | LGI | B | 1500 | Low Glycemic Index Protocol for 55-65kg |
| LGI_D_STANDARD | LGI | D | 1900 | Low Glycemic Index Protocol for >85kg |
| KTP_A_STANDARD | KTP | A | 1200 | Ketogenic Therapy Protocol for <55kg |
| KTP_B_STANDARD | KTP | B | 1400 | Ketogenic Therapy Protocol for 55-65kg |

**Note:** These are demo templates only. Not medical advice. Doctors should review and approve before use.

---

## User Roles & Permissions

| Action | Admin (1) | Doctor (2) | Assistant (3) |
|--------|-----------|------------|---------------|
| View diet templates | Yes | Yes | Yes |
| Create/edit diet templates | Yes | Yes | No |
| Manage food items | Yes | Yes | Yes |
| Manage categories/tags | Yes | No | No |
| Assign diet to patient | Yes | Yes | No |
| View patient diet history | Yes | Yes | Yes |
| Cancel/pause patient diet | Yes | Yes | No |
| Manage product links | Yes | No | No |
| View patient inventory | Yes | Yes | Yes |

---

## Implementation Status

### Completed
- [x] Database schema (all tables)
- [x] Seed data for tags and categories
- [x] Database models in `database.js`
- [x] Food management (CRUD for items, categories, tags)
- [x] Diet template management (CRUD)
- [x] Day/Meal/Item builder UI
- [x] Template cloning
- [x] Patient diet assignment
- [x] Diet history tracking with audit log
- [x] Dashboard integration for Admin/Doctor
- [x] Demo data with 6 sample templates
- [x] Patient diets list with pagination and search (by patient name or diet)
- [x] Product links for e-commerce integration (Kiros, etc.) with multi-language support
- [x] Day-level product recommendations (products per day, not just per template)
- [x] Unique products summary for patient shopping list / email with discount code
- [x] Product packaging info (units_per_box, unit_type) in product form
- [x] Patient product inventory tracking with calculated consumption
- [x] Auto-create inventory records when diet is assigned
- [x] Inventory display on patient view page with status badges and progress bars
- [x] Low stock alert query (`PatientProductInventory.getLowStockAlerts()`)

### Future Enhancements
- [ ] Low stock email notifications (scheduled job)
- [ ] Inventory management UI (add boxes, adjust quantities)
- [ ] Translations (multi-language support)
- [ ] PDF export of diet plan
- [ ] Patient mobile view
- [ ] Progress tracking
- [ ] Nutritionist role (role=5)
- [ ] Weight segments table (instead of hardcoded A/B/C/D)
- [ ] Integration with medical visits (auto-suggest diet based on weight)
