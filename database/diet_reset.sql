-- Diet System Reset Script
-- Clears all diet data and re-runs demo data
-- Run with: mysql -u clinic_user -p medical_clinic < database/diet_reset.sql

USE medical_clinic;

-- Disable foreign key checks for truncation
SET FOREIGN_KEY_CHECKS = 0;

-- Clear all diet-related tables
TRUNCATE TABLE diet_meal_items;
TRUNCATE TABLE diet_meals;
TRUNCATE TABLE diet_days;
TRUNCATE TABLE diet_template_tags;
TRUNCATE TABLE patient_diet_history;
TRUNCATE TABLE patient_diets;
TRUNCATE TABLE diet_templates;

-- Also clear food items to avoid duplicate subquery errors
TRUNCATE TABLE food_item_tags;
TRUNCATE TABLE food_items;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

SELECT 'Diet and food tables cleared successfully!' AS status;
