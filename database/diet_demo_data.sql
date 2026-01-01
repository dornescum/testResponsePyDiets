-- Demo Diet Data (NOT MEDICAL ADVICE - Demo templates for doctors to approve)
-- Run after diet_system.sql

USE medical_clinic;

-- ============================================
-- SAMPLE FOOD ITEMS
-- ============================================

-- Fruits (category_id = 1)
INSERT INTO food_items (category_id, name, description, default_portion_grams, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g, is_snack_suitable) VALUES
(1, 'Apple', 'Fresh apple, medium size', 150, 52, 0.3, 14, 0.2, 2.4, 1),
(1, 'Banana', 'Ripe banana', 120, 89, 1.1, 23, 0.3, 2.6, 1),
(1, 'Orange', 'Fresh orange', 130, 47, 0.9, 12, 0.1, 2.4, 1),
(1, 'Blueberries', 'Fresh blueberries', 100, 57, 0.7, 14, 0.3, 2.4, 1),
(1, 'Strawberries', 'Fresh strawberries', 150, 32, 0.7, 8, 0.3, 2.0, 1);

-- Vegetables (category_id = 2)
INSERT INTO food_items (category_id, name, description, default_portion_grams, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g, is_snack_suitable) VALUES
(2, 'Broccoli', 'Steamed broccoli', 150, 34, 2.8, 7, 0.4, 2.6, 0),
(2, 'Spinach', 'Fresh spinach leaves', 100, 23, 2.9, 3.6, 0.4, 2.2, 0),
(2, 'Carrots', 'Raw or cooked carrots', 100, 41, 0.9, 10, 0.2, 2.8, 1),
(2, 'Zucchini', 'Grilled zucchini', 150, 17, 1.2, 3.1, 0.3, 1.0, 0),
(2, 'Mixed Salad', 'Lettuce, tomato, cucumber', 200, 15, 1.0, 3.0, 0.2, 1.5, 0),
(2, 'Tomatoes', 'Fresh tomatoes', 100, 18, 0.9, 3.9, 0.2, 1.2, 1),
(2, 'Bell Peppers', 'Mixed bell peppers', 100, 31, 1.0, 6.0, 0.3, 2.1, 1);

-- Meat (category_id = 3)
INSERT INTO food_items (category_id, name, description, default_portion_grams, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g, is_snack_suitable) VALUES
(3, 'Chicken Breast', 'Grilled chicken breast, skinless', 150, 165, 31, 0, 3.6, 0, 0),
(3, 'Turkey Breast', 'Roasted turkey breast', 120, 135, 30, 0, 1.0, 0, 0),
(3, 'Lean Beef', 'Grilled lean beef', 120, 250, 26, 0, 15, 0, 0),
(3, 'Pork Tenderloin', 'Roasted pork tenderloin', 120, 143, 26, 0, 3.5, 0, 0);

-- Fish (category_id = 4)
INSERT INTO food_items (category_id, name, description, default_portion_grams, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g, is_snack_suitable) VALUES
(4, 'Salmon', 'Baked salmon fillet', 150, 208, 20, 0, 13, 0, 0),
(4, 'Cod', 'Baked cod fillet', 150, 82, 18, 0, 0.7, 0, 0),
(4, 'Tuna', 'Grilled tuna steak', 150, 132, 29, 0, 1.0, 0, 0),
(4, 'Shrimp', 'Grilled shrimp', 100, 99, 24, 0.2, 0.3, 0, 0),
(4, 'Sea Bass', 'Baked sea bass', 150, 97, 18, 0, 2.0, 0, 0);

-- Dairy (category_id = 5)
INSERT INTO food_items (category_id, name, description, default_portion_grams, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g, is_snack_suitable) VALUES
(5, 'Greek Yogurt', 'Plain Greek yogurt, low-fat', 150, 59, 10, 3.6, 0.7, 0, 1),
(5, 'Cottage Cheese', 'Low-fat cottage cheese', 100, 98, 11, 3.4, 4.3, 0, 1),
(5, 'Mozzarella', 'Fresh mozzarella', 50, 280, 28, 3.1, 17, 0, 0),
(5, 'Parmesan', 'Grated parmesan', 20, 431, 38, 4.1, 29, 0, 0),
(5, 'Milk', 'Low-fat milk', 200, 42, 3.4, 5.0, 1.0, 0, 0);

-- Grains (category_id = 6)
INSERT INTO food_items (category_id, name, description, default_portion_grams, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g, is_snack_suitable) VALUES
(6, 'Brown Rice', 'Cooked brown rice', 150, 111, 2.6, 23, 0.9, 1.8, 0),
(6, 'Quinoa', 'Cooked quinoa', 150, 120, 4.4, 21, 1.9, 2.8, 0),
(6, 'Oatmeal', 'Cooked oatmeal', 200, 68, 2.4, 12, 1.4, 1.7, 0),
(6, 'Whole Wheat Bread', 'Whole wheat bread slice', 30, 247, 13, 41, 3.4, 7.0, 0),
(6, 'Whole Wheat Pasta', 'Cooked whole wheat pasta', 150, 124, 5.3, 25, 0.5, 4.5, 0);

-- Legumes (category_id = 7)
INSERT INTO food_items (category_id, name, description, default_portion_grams, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g, is_snack_suitable) VALUES
(7, 'Lentils', 'Cooked lentils', 150, 116, 9.0, 20, 0.4, 7.9, 0),
(7, 'Chickpeas', 'Cooked chickpeas', 150, 164, 8.9, 27, 2.6, 7.6, 0),
(7, 'Black Beans', 'Cooked black beans', 150, 132, 8.9, 24, 0.5, 8.7, 0),
(7, 'Edamame', 'Steamed edamame', 100, 121, 11, 8.9, 5.2, 5.2, 1);

-- Beverages (category_id = 8)
INSERT INTO food_items (category_id, name, description, default_portion_grams, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g, is_snack_suitable) VALUES
(8, 'Green Tea', 'Unsweetened green tea', 250, 1, 0, 0, 0, 0, 0),
(8, 'Black Coffee', 'Black coffee, no sugar', 250, 2, 0.3, 0, 0, 0, 0),
(8, 'Water', 'Plain water', 250, 0, 0, 0, 0, 0, 0),
(8, 'Herbal Tea', 'Chamomile or mint tea', 250, 1, 0, 0, 0, 0, 0);

-- Nuts and Seeds (category_id = 9)
INSERT INTO food_items (category_id, name, description, default_portion_grams, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g, is_snack_suitable) VALUES
(9, 'Almonds', 'Raw almonds', 30, 579, 21, 22, 50, 12.5, 1),
(9, 'Walnuts', 'Raw walnuts', 30, 654, 15, 14, 65, 6.7, 1),
(9, 'Chia Seeds', 'Dried chia seeds', 15, 486, 17, 42, 31, 34, 0),
(9, 'Flax Seeds', 'Ground flax seeds', 15, 534, 18, 29, 42, 27, 0),
(9, 'Pumpkin Seeds', 'Raw pumpkin seeds', 30, 559, 30, 11, 49, 6.0, 1);

-- Oils and Fats (category_id = 10)
INSERT INTO food_items (category_id, name, description, default_portion_grams, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g, is_snack_suitable) VALUES
(10, 'Olive Oil', 'Extra virgin olive oil', 15, 884, 0, 0, 100, 0, 0),
(10, 'Avocado', 'Fresh avocado', 100, 160, 2.0, 9.0, 15, 7.0, 1),
(10, 'Coconut Oil', 'Virgin coconut oil', 15, 862, 0, 0, 100, 0, 0);

-- Eggs
INSERT INTO food_items (category_id, name, description, default_portion_grams, calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g, fiber_per_100g, is_snack_suitable) VALUES
(3, 'Eggs', 'Whole eggs, boiled or scrambled', 100, 155, 13, 1.1, 11, 0, 0),
(3, 'Egg Whites', 'Egg whites only', 100, 52, 11, 0.7, 0.2, 0, 0);

-- ============================================
-- STANDARD CALORIC RESTRICTION (SCR) TEMPLATES
-- ============================================

-- SCR Template 1: Segment A
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('SCR_A_STANDARD', 'Standard Caloric Restriction - Segment A', 'Balanced caloric restriction protocol for patients under 55kg. Focuses on nutrient-dense foods with moderate energy deficit.', 'A', 'SCR', 30, 1300, 'Suitable for sedentary to lightly active patients. Adjust portions based on activity level.', 1);

SET @scr_a_id = LAST_INSERT_ID();

INSERT INTO diet_days (template_id, day_number, day_name) VALUES
(@scr_a_id, 1, 'Monday'),
(@scr_a_id, 2, 'Tuesday'),
(@scr_a_id, 3, 'Wednesday'),
(@scr_a_id, 4, 'Thursday'),
(@scr_a_id, 5, 'Friday'),
(@scr_a_id, 6, 'Saturday'),
(@scr_a_id, 7, 'Sunday');

SET @scr_a_d1 = (SELECT id FROM diet_days WHERE template_id = @scr_a_id AND day_number = 1);
SET @scr_a_d2 = (SELECT id FROM diet_days WHERE template_id = @scr_a_id AND day_number = 2);

INSERT INTO diet_meals (day_id, meal_type, meal_order, time_suggestion) VALUES
(@scr_a_d1, 'breakfast', 1, '08:00'),
(@scr_a_d1, 'snack', 2, '10:30'),
(@scr_a_d1, 'lunch', 3, '13:00'),
(@scr_a_d1, 'snack', 4, '16:00'),
(@scr_a_d1, 'dinner', 5, '19:30');

SET @scr_a_d1_breakfast = (SELECT id FROM diet_meals WHERE day_id = @scr_a_d1 AND meal_type = 'breakfast');
SET @scr_a_d1_snack1 = (SELECT id FROM diet_meals WHERE day_id = @scr_a_d1 AND meal_type = 'snack' AND meal_order = 2);
SET @scr_a_d1_lunch = (SELECT id FROM diet_meals WHERE day_id = @scr_a_d1 AND meal_type = 'lunch');
SET @scr_a_d1_snack2 = (SELECT id FROM diet_meals WHERE day_id = @scr_a_d1 AND meal_type = 'snack' AND meal_order = 4);
SET @scr_a_d1_dinner = (SELECT id FROM diet_meals WHERE day_id = @scr_a_d1 AND meal_type = 'dinner');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@scr_a_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Greek Yogurt'), 120, 150, '1 small cup', 'Plain, no added sugar'),
(@scr_a_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Blueberries'), 50, 80, 'handful', 'Fresh or frozen'),
(@scr_a_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Oatmeal'), 150, 200, '1 bowl', 'Cooked with water');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, is_optional) VALUES
(@scr_a_d1_snack1, (SELECT id FROM food_items WHERE name = 'Apple'), 100, 150, '1 medium apple', 0);

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@scr_a_d1_lunch, (SELECT id FROM food_items WHERE name = 'Chicken Breast'), 100, 130, '1 small breast', 'Grilled with herbs'),
(@scr_a_d1_lunch, (SELECT id FROM food_items WHERE name = 'Brown Rice'), 100, 130, '1/2 cup cooked', NULL),
(@scr_a_d1_lunch, (SELECT id FROM food_items WHERE name = 'Mixed Salad'), 150, 200, '1 large bowl', 'With lemon dressing');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, is_optional) VALUES
(@scr_a_d1_snack2, (SELECT id FROM food_items WHERE name = 'Almonds'), 20, 30, '10-15 almonds', 0);

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@scr_a_d1_dinner, (SELECT id FROM food_items WHERE name = 'Cod'), 120, 150, '1 fillet', 'Baked with lemon'),
(@scr_a_d1_dinner, (SELECT id FROM food_items WHERE name = 'Broccoli'), 150, 200, '1 cup', 'Steamed'),
(@scr_a_d1_dinner, (SELECT id FROM food_items WHERE name = 'Olive Oil'), 10, 15, '1 tbsp', 'For dressing');

INSERT INTO diet_meals (day_id, meal_type, meal_order, time_suggestion) VALUES
(@scr_a_d2, 'breakfast', 1, '08:00'),
(@scr_a_d2, 'snack', 2, '10:30'),
(@scr_a_d2, 'lunch', 3, '13:00'),
(@scr_a_d2, 'snack', 4, '16:00'),
(@scr_a_d2, 'dinner', 5, '19:30');

SET @scr_a_d2_breakfast = (SELECT id FROM diet_meals WHERE day_id = @scr_a_d2 AND meal_type = 'breakfast');
SET @scr_a_d2_lunch = (SELECT id FROM diet_meals WHERE day_id = @scr_a_d2 AND meal_type = 'lunch');
SET @scr_a_d2_dinner = (SELECT id FROM diet_meals WHERE day_id = @scr_a_d2 AND meal_type = 'dinner');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@scr_a_d2_breakfast, (SELECT id FROM food_items WHERE name = 'Eggs'), 100, 100, '2 eggs', 'Scrambled or boiled'),
(@scr_a_d2_breakfast, (SELECT id FROM food_items WHERE name = 'Whole Wheat Bread'), 30, 60, '1-2 slices', 'Toasted'),
(@scr_a_d2_breakfast, (SELECT id FROM food_items WHERE name = 'Tomatoes'), 50, 80, '1 small tomato', 'Sliced');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@scr_a_d2_lunch, (SELECT id FROM food_items WHERE name = 'Salmon'), 120, 150, '1 fillet', 'Baked'),
(@scr_a_d2_lunch, (SELECT id FROM food_items WHERE name = 'Quinoa'), 120, 150, '1/2 cup cooked', NULL),
(@scr_a_d2_lunch, (SELECT id FROM food_items WHERE name = 'Spinach'), 100, 150, '2 cups raw', 'Fresh salad');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@scr_a_d2_dinner, (SELECT id FROM food_items WHERE name = 'Turkey Breast'), 100, 120, '3-4 slices', 'Roasted'),
(@scr_a_d2_dinner, (SELECT id FROM food_items WHERE name = 'Zucchini'), 150, 200, '1 medium', 'Grilled'),
(@scr_a_d2_dinner, (SELECT id FROM food_items WHERE name = 'Lentils'), 100, 130, '1/2 cup', 'As side dish');

-- SCR Template 2: Segment C
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('SCR_C_STANDARD', 'Standard Caloric Restriction - Segment C', 'Balanced caloric restriction protocol for patients 65-85kg. Higher energy allowance with emphasis on protein preservation.', 'C', 'SCR', 30, 1700, 'For moderately active patients. Include light exercise 3x per week.', 1);

SET @scr_c_id = LAST_INSERT_ID();

INSERT INTO diet_days (template_id, day_number, day_name) VALUES
(@scr_c_id, 1, 'Monday'),
(@scr_c_id, 2, 'Tuesday'),
(@scr_c_id, 3, 'Wednesday'),
(@scr_c_id, 4, 'Thursday'),
(@scr_c_id, 5, 'Friday'),
(@scr_c_id, 6, 'Saturday'),
(@scr_c_id, 7, 'Sunday');

SET @scr_c_d1 = (SELECT id FROM diet_days WHERE template_id = @scr_c_id AND day_number = 1);

INSERT INTO diet_meals (day_id, meal_type, meal_order, time_suggestion) VALUES
(@scr_c_d1, 'breakfast', 1, '07:30'),
(@scr_c_d1, 'snack', 2, '10:00'),
(@scr_c_d1, 'lunch', 3, '12:30'),
(@scr_c_d1, 'snack', 4, '15:30'),
(@scr_c_d1, 'dinner', 5, '19:00');

SET @scr_c_d1_breakfast = (SELECT id FROM diet_meals WHERE day_id = @scr_c_d1 AND meal_type = 'breakfast');
SET @scr_c_d1_lunch = (SELECT id FROM diet_meals WHERE day_id = @scr_c_d1 AND meal_type = 'lunch');
SET @scr_c_d1_dinner = (SELECT id FROM diet_meals WHERE day_id = @scr_c_d1 AND meal_type = 'dinner');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@scr_c_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Oatmeal'), 200, 250, '1 large bowl', 'With cinnamon'),
(@scr_c_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Banana'), 100, 120, '1 medium', 'Sliced on top'),
(@scr_c_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Walnuts'), 20, 30, '5-6 halves', 'Chopped'),
(@scr_c_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Milk'), 150, 200, '1 glass', 'Low-fat');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@scr_c_d1_lunch, (SELECT id FROM food_items WHERE name = 'Lean Beef'), 130, 150, '1 portion', 'Grilled, no sauce'),
(@scr_c_d1_lunch, (SELECT id FROM food_items WHERE name = 'Brown Rice'), 150, 180, '3/4 cup cooked', NULL),
(@scr_c_d1_lunch, (SELECT id FROM food_items WHERE name = 'Mixed Salad'), 200, 250, '1 large bowl', 'Olive oil dressing'),
(@scr_c_d1_lunch, (SELECT id FROM food_items WHERE name = 'Bell Peppers'), 80, 100, '1/2 pepper', 'Raw or grilled');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@scr_c_d1_dinner, (SELECT id FROM food_items WHERE name = 'Tuna'), 150, 180, '1 steak', 'Grilled'),
(@scr_c_d1_dinner, (SELECT id FROM food_items WHERE name = 'Whole Wheat Pasta'), 120, 150, '1 cup cooked', NULL),
(@scr_c_d1_dinner, (SELECT id FROM food_items WHERE name = 'Broccoli'), 150, 200, '1 cup', 'Steamed'),
(@scr_c_d1_dinner, (SELECT id FROM food_items WHERE name = 'Olive Oil'), 15, 20, '1.5 tbsp', NULL);

-- ============================================
-- LOW GLYCEMIC INDEX PROTOCOL (LGI) TEMPLATES
-- ============================================

-- LGI Template 1: Segment B
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('LGI_B_STANDARD', 'Low Glycemic Index Protocol - Segment B', 'Glycemic control protocol for 55-65kg patients. Emphasizes low-GI carbohydrates and lean proteins for stable blood glucose.', 'B', 'LGI', 30, 1500, 'Ideal for pre-diabetic patients or those with insulin resistance.', 1);

SET @lgi_b_id = LAST_INSERT_ID();

INSERT INTO diet_days (template_id, day_number, day_name) VALUES
(@lgi_b_id, 1, 'Monday'),
(@lgi_b_id, 2, 'Tuesday'),
(@lgi_b_id, 3, 'Wednesday'),
(@lgi_b_id, 4, 'Thursday'),
(@lgi_b_id, 5, 'Friday'),
(@lgi_b_id, 6, 'Saturday'),
(@lgi_b_id, 7, 'Sunday');

SET @lgi_b_d1 = (SELECT id FROM diet_days WHERE template_id = @lgi_b_id AND day_number = 1);

INSERT INTO diet_meals (day_id, meal_type, meal_order, time_suggestion) VALUES
(@lgi_b_d1, 'breakfast', 1, '08:00'),
(@lgi_b_d1, 'snack', 2, '10:30'),
(@lgi_b_d1, 'lunch', 3, '13:00'),
(@lgi_b_d1, 'snack', 4, '16:00'),
(@lgi_b_d1, 'dinner', 5, '19:00');

SET @lgi_b_d1_breakfast = (SELECT id FROM diet_meals WHERE day_id = @lgi_b_d1 AND meal_type = 'breakfast');
SET @lgi_b_d1_lunch = (SELECT id FROM diet_meals WHERE day_id = @lgi_b_d1 AND meal_type = 'lunch');
SET @lgi_b_d1_dinner = (SELECT id FROM diet_meals WHERE day_id = @lgi_b_d1 AND meal_type = 'dinner');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@lgi_b_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Eggs'), 100, 100, '2 eggs', 'Poached or boiled'),
(@lgi_b_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Avocado'), 50, 80, '1/2 avocado', 'Sliced'),
(@lgi_b_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Whole Wheat Bread'), 30, 30, '1 slice', 'Toasted'),
(@lgi_b_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Green Tea'), 250, 250, '1 cup', 'No sugar');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@lgi_b_d1_lunch, (SELECT id FROM food_items WHERE name = 'Chicken Breast'), 130, 150, '1 breast', 'Grilled'),
(@lgi_b_d1_lunch, (SELECT id FROM food_items WHERE name = 'Lentils'), 130, 150, '1/2 cup', 'As base'),
(@lgi_b_d1_lunch, (SELECT id FROM food_items WHERE name = 'Spinach'), 100, 150, '2 cups', 'Sauteed with garlic'),
(@lgi_b_d1_lunch, (SELECT id FROM food_items WHERE name = 'Olive Oil'), 10, 15, '1 tbsp', NULL);

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@lgi_b_d1_dinner, (SELECT id FROM food_items WHERE name = 'Sea Bass'), 130, 160, '1 fillet', 'Baked with herbs'),
(@lgi_b_d1_dinner, (SELECT id FROM food_items WHERE name = 'Chickpeas'), 100, 130, '1/2 cup', 'Roasted'),
(@lgi_b_d1_dinner, (SELECT id FROM food_items WHERE name = 'Zucchini'), 150, 200, '1 medium', 'Grilled'),
(@lgi_b_d1_dinner, (SELECT id FROM food_items WHERE name = 'Carrots'), 80, 100, '1 medium', 'Roasted');

-- LGI Template 2: Segment D
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('LGI_D_STANDARD', 'Low Glycemic Index Protocol - Segment D', 'Glycemic control protocol for patients over 85kg. Balanced macronutrient approach with emphasis on satiety and metabolic health.', 'D', 'LGI', 30, 1900, 'Higher protein intake for muscle preservation during weight loss.', 1);

SET @lgi_d_id = LAST_INSERT_ID();

INSERT INTO diet_days (template_id, day_number, day_name) VALUES
(@lgi_d_id, 1, 'Monday'),
(@lgi_d_id, 2, 'Tuesday'),
(@lgi_d_id, 3, 'Wednesday'),
(@lgi_d_id, 4, 'Thursday'),
(@lgi_d_id, 5, 'Friday'),
(@lgi_d_id, 6, 'Saturday'),
(@lgi_d_id, 7, 'Sunday');

SET @lgi_d_d1 = (SELECT id FROM diet_days WHERE template_id = @lgi_d_id AND day_number = 1);

INSERT INTO diet_meals (day_id, meal_type, meal_order, time_suggestion) VALUES
(@lgi_d_d1, 'breakfast', 1, '07:30'),
(@lgi_d_d1, 'snack', 2, '10:00'),
(@lgi_d_d1, 'lunch', 3, '12:30'),
(@lgi_d_d1, 'snack', 4, '15:30'),
(@lgi_d_d1, 'dinner', 5, '18:30');

SET @lgi_d_d1_breakfast = (SELECT id FROM diet_meals WHERE day_id = @lgi_d_d1 AND meal_type = 'breakfast');
SET @lgi_d_d1_snack1 = (SELECT id FROM diet_meals WHERE day_id = @lgi_d_d1 AND meal_type = 'snack' AND meal_order = 2);
SET @lgi_d_d1_lunch = (SELECT id FROM diet_meals WHERE day_id = @lgi_d_d1 AND meal_type = 'lunch');
SET @lgi_d_d1_dinner = (SELECT id FROM diet_meals WHERE day_id = @lgi_d_d1 AND meal_type = 'dinner');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@lgi_d_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Greek Yogurt'), 180, 200, '1 large cup', 'Full-fat for satiety'),
(@lgi_d_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Chia Seeds'), 15, 20, '1 tbsp', 'Mixed in'),
(@lgi_d_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Strawberries'), 100, 150, '1 cup', 'Fresh'),
(@lgi_d_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Almonds'), 25, 30, '15 almonds', 'Chopped');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description) VALUES
(@lgi_d_d1_snack1, (SELECT id FROM food_items WHERE name = 'Cottage Cheese'), 100, 120, '1/2 cup'),
(@lgi_d_d1_snack1, (SELECT id FROM food_items WHERE name = 'Carrots'), 80, 100, '1 medium carrot');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@lgi_d_d1_lunch, (SELECT id FROM food_items WHERE name = 'Lean Beef'), 150, 180, '1 large portion', 'Grilled'),
(@lgi_d_d1_lunch, (SELECT id FROM food_items WHERE name = 'Black Beans'), 130, 150, '1/2 cup', NULL),
(@lgi_d_d1_lunch, (SELECT id FROM food_items WHERE name = 'Mixed Salad'), 200, 250, '1 large bowl', NULL),
(@lgi_d_d1_lunch, (SELECT id FROM food_items WHERE name = 'Avocado'), 80, 100, '1/2 avocado', NULL);

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@lgi_d_d1_dinner, (SELECT id FROM food_items WHERE name = 'Salmon'), 160, 200, '1 large fillet', 'Baked'),
(@lgi_d_d1_dinner, (SELECT id FROM food_items WHERE name = 'Broccoli'), 200, 250, '1.5 cups', 'Steamed'),
(@lgi_d_d1_dinner, (SELECT id FROM food_items WHERE name = 'Quinoa'), 100, 130, '1/2 cup cooked', NULL),
(@lgi_d_d1_dinner, (SELECT id FROM food_items WHERE name = 'Olive Oil'), 15, 20, '1.5 tbsp', 'For cooking');

-- ============================================
-- KETOGENIC THERAPY PROTOCOL (KTP) TEMPLATES
-- ============================================

-- KTP Template 1: Segment A
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('KTP_A_STANDARD', 'Ketogenic Therapy Protocol - Segment A', 'Therapeutic ketogenic protocol for patients under 55kg. Induces nutritional ketosis through very low carbohydrate intake.', 'A', 'KTP', 30, 1200, 'Strict carb limit of 20-30g per day. Monitor ketone levels. Not suitable for diabetics without supervision.', 1);

SET @ktp_a_id = LAST_INSERT_ID();

INSERT INTO diet_days (template_id, day_number, day_name) VALUES
(@ktp_a_id, 1, 'Monday'),
(@ktp_a_id, 2, 'Tuesday'),
(@ktp_a_id, 3, 'Wednesday'),
(@ktp_a_id, 4, 'Thursday'),
(@ktp_a_id, 5, 'Friday'),
(@ktp_a_id, 6, 'Saturday'),
(@ktp_a_id, 7, 'Sunday');

SET @ktp_a_d1 = (SELECT id FROM diet_days WHERE template_id = @ktp_a_id AND day_number = 1);

INSERT INTO diet_meals (day_id, meal_type, meal_order, time_suggestion) VALUES
(@ktp_a_d1, 'breakfast', 1, '08:00'),
(@ktp_a_d1, 'lunch', 2, '13:00'),
(@ktp_a_d1, 'snack', 3, '16:00'),
(@ktp_a_d1, 'dinner', 4, '19:00');

SET @ktp_a_d1_breakfast = (SELECT id FROM diet_meals WHERE day_id = @ktp_a_d1 AND meal_type = 'breakfast');
SET @ktp_a_d1_lunch = (SELECT id FROM diet_meals WHERE day_id = @ktp_a_d1 AND meal_type = 'lunch');
SET @ktp_a_d1_snack = (SELECT id FROM diet_meals WHERE day_id = @ktp_a_d1 AND meal_type = 'snack');
SET @ktp_a_d1_dinner = (SELECT id FROM diet_meals WHERE day_id = @ktp_a_d1 AND meal_type = 'dinner');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@ktp_a_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Eggs'), 100, 150, '2-3 eggs', 'Scrambled in butter'),
(@ktp_a_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Avocado'), 80, 100, '1/2 avocado', NULL),
(@ktp_a_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Spinach'), 50, 80, '1 cup', 'Sauteed'),
(@ktp_a_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Black Coffee'), 250, 250, '1 cup', 'Or with MCT oil');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@ktp_a_d1_lunch, (SELECT id FROM food_items WHERE name = 'Salmon'), 130, 150, '1 fillet', 'Baked with butter'),
(@ktp_a_d1_lunch, (SELECT id FROM food_items WHERE name = 'Mixed Salad'), 150, 200, '1 large bowl', 'With olive oil dressing'),
(@ktp_a_d1_lunch, (SELECT id FROM food_items WHERE name = 'Mozzarella'), 40, 50, '2-3 slices', 'Fresh'),
(@ktp_a_d1_lunch, (SELECT id FROM food_items WHERE name = 'Olive Oil'), 20, 25, '2 tbsp', 'For dressing');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, is_optional) VALUES
(@ktp_a_d1_snack, (SELECT id FROM food_items WHERE name = 'Almonds'), 25, 30, '15-20 almonds', 0),
(@ktp_a_d1_snack, (SELECT id FROM food_items WHERE name = 'Cottage Cheese'), 80, 100, '1/2 cup', 1);

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@ktp_a_d1_dinner, (SELECT id FROM food_items WHERE name = 'Chicken Breast'), 120, 150, '1 breast', 'Grilled with herbs'),
(@ktp_a_d1_dinner, (SELECT id FROM food_items WHERE name = 'Broccoli'), 150, 180, '1 cup', 'With butter'),
(@ktp_a_d1_dinner, (SELECT id FROM food_items WHERE name = 'Parmesan'), 15, 20, '1 tbsp grated', 'On top'),
(@ktp_a_d1_dinner, (SELECT id FROM food_items WHERE name = 'Coconut Oil'), 15, 20, '1 tbsp', 'For cooking');

-- KTP Template 2: Segment B
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('KTP_B_STANDARD', 'Ketogenic Therapy Protocol - Segment B', 'Therapeutic ketogenic protocol for 55-65kg patients. Emphasizes healthy fats with adequate protein for metabolic adaptation.', 'B', 'KTP', 30, 1400, 'Target: 70% fat, 25% protein, 5% carbs. Include electrolyte supplementation.', 1);

SET @ktp_b_id = LAST_INSERT_ID();

INSERT INTO diet_days (template_id, day_number, day_name) VALUES
(@ktp_b_id, 1, 'Monday'),
(@ktp_b_id, 2, 'Tuesday'),
(@ktp_b_id, 3, 'Wednesday'),
(@ktp_b_id, 4, 'Thursday'),
(@ktp_b_id, 5, 'Friday'),
(@ktp_b_id, 6, 'Saturday'),
(@ktp_b_id, 7, 'Sunday');

SET @ktp_b_d1 = (SELECT id FROM diet_days WHERE template_id = @ktp_b_id AND day_number = 1);
SET @ktp_b_d2 = (SELECT id FROM diet_days WHERE template_id = @ktp_b_id AND day_number = 2);

INSERT INTO diet_meals (day_id, meal_type, meal_order, time_suggestion) VALUES
(@ktp_b_d1, 'breakfast', 1, '08:00'),
(@ktp_b_d1, 'lunch', 2, '12:30'),
(@ktp_b_d1, 'snack', 3, '15:30'),
(@ktp_b_d1, 'dinner', 4, '19:00');

SET @ktp_b_d1_breakfast = (SELECT id FROM diet_meals WHERE day_id = @ktp_b_d1 AND meal_type = 'breakfast');
SET @ktp_b_d1_lunch = (SELECT id FROM diet_meals WHERE day_id = @ktp_b_d1 AND meal_type = 'lunch');
SET @ktp_b_d1_dinner = (SELECT id FROM diet_meals WHERE day_id = @ktp_b_d1 AND meal_type = 'dinner');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@ktp_b_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Eggs'), 100, 150, '2-3 eggs', 'Omelette style'),
(@ktp_b_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Mozzarella'), 50, 60, '2-3 slices', 'In omelette'),
(@ktp_b_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Bell Peppers'), 50, 80, '1/2 pepper', 'Diced in omelette'),
(@ktp_b_d1_breakfast, (SELECT id FROM food_items WHERE name = 'Olive Oil'), 15, 20, '1 tbsp', 'For cooking');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@ktp_b_d1_lunch, (SELECT id FROM food_items WHERE name = 'Tuna'), 140, 160, '1 steak', 'Seared'),
(@ktp_b_d1_lunch, (SELECT id FROM food_items WHERE name = 'Avocado'), 100, 120, '1 whole', 'Sliced'),
(@ktp_b_d1_lunch, (SELECT id FROM food_items WHERE name = 'Mixed Salad'), 150, 200, '1 large bowl', NULL),
(@ktp_b_d1_lunch, (SELECT id FROM food_items WHERE name = 'Pumpkin Seeds'), 20, 30, '2 tbsp', 'On salad');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@ktp_b_d1_dinner, (SELECT id FROM food_items WHERE name = 'Pork Tenderloin'), 130, 150, '1 portion', 'Roasted'),
(@ktp_b_d1_dinner, (SELECT id FROM food_items WHERE name = 'Zucchini'), 150, 200, '1 medium', 'Grilled with cheese'),
(@ktp_b_d1_dinner, (SELECT id FROM food_items WHERE name = 'Parmesan'), 20, 25, '2 tbsp grated', NULL),
(@ktp_b_d1_dinner, (SELECT id FROM food_items WHERE name = 'Olive Oil'), 15, 20, '1 tbsp', NULL);

INSERT INTO diet_meals (day_id, meal_type, meal_order, time_suggestion) VALUES
(@ktp_b_d2, 'breakfast', 1, '08:00'),
(@ktp_b_d2, 'lunch', 2, '12:30'),
(@ktp_b_d2, 'dinner', 3, '19:00');

SET @ktp_b_d2_breakfast = (SELECT id FROM diet_meals WHERE day_id = @ktp_b_d2 AND meal_type = 'breakfast');
SET @ktp_b_d2_lunch = (SELECT id FROM diet_meals WHERE day_id = @ktp_b_d2 AND meal_type = 'lunch');
SET @ktp_b_d2_dinner = (SELECT id FROM diet_meals WHERE day_id = @ktp_b_d2 AND meal_type = 'dinner');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@ktp_b_d2_breakfast, (SELECT id FROM food_items WHERE name = 'Greek Yogurt'), 150, 180, '1 cup', 'Full-fat'),
(@ktp_b_d2_breakfast, (SELECT id FROM food_items WHERE name = 'Walnuts'), 30, 40, '8-10 halves', 'Chopped'),
(@ktp_b_d2_breakfast, (SELECT id FROM food_items WHERE name = 'Flax Seeds'), 10, 15, '1 tbsp', 'Ground');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@ktp_b_d2_lunch, (SELECT id FROM food_items WHERE name = 'Shrimp'), 120, 150, '10-12 shrimp', 'Grilled'),
(@ktp_b_d2_lunch, (SELECT id FROM food_items WHERE name = 'Avocado'), 80, 100, '1/2 avocado', NULL),
(@ktp_b_d2_lunch, (SELECT id FROM food_items WHERE name = 'Spinach'), 100, 150, '2 cups', 'Fresh salad'),
(@ktp_b_d2_lunch, (SELECT id FROM food_items WHERE name = 'Olive Oil'), 20, 25, '2 tbsp', 'Dressing');

INSERT INTO diet_meal_items (meal_id, food_item_id, portion_grams_min, portion_grams_max, portion_description, preparation_notes) VALUES
(@ktp_b_d2_dinner, (SELECT id FROM food_items WHERE name = 'Cod'), 150, 180, '1 large fillet', 'Baked'),
(@ktp_b_d2_dinner, (SELECT id FROM food_items WHERE name = 'Broccoli'), 180, 220, '1.5 cups', 'Roasted with garlic'),
(@ktp_b_d2_dinner, (SELECT id FROM food_items WHERE name = 'Cottage Cheese'), 80, 100, '1/2 cup', 'Side dish'),
(@ktp_b_d2_dinner, (SELECT id FROM food_items WHERE name = 'Coconut Oil'), 15, 20, '1 tbsp', 'For roasting');

-- ============================================
-- ADD DIET TAGS TO TEMPLATES
-- ============================================

INSERT INTO diet_template_tags (template_id, tag_id)
SELECT @scr_a_id, id FROM diet_tags WHERE name IN ('no_restriction', 'heart_friendly');

INSERT INTO diet_template_tags (template_id, tag_id)
SELECT @scr_c_id, id FROM diet_tags WHERE name IN ('no_restriction');

INSERT INTO diet_template_tags (template_id, tag_id)
SELECT @lgi_b_id, id FROM diet_tags WHERE name IN ('diabetic', 'heart_friendly', 'no_restriction');

INSERT INTO diet_template_tags (template_id, tag_id)
SELECT @lgi_d_id, id FROM diet_tags WHERE name IN ('diabetic', 'no_restriction');

INSERT INTO diet_template_tags (template_id, tag_id)
SELECT @ktp_a_id, id FROM diet_tags WHERE name IN ('no_restriction', 'gluten_free');

INSERT INTO diet_template_tags (template_id, tag_id)
SELECT @ktp_b_id, id FROM diet_tags WHERE name IN ('no_restriction', 'gluten_free');

SELECT 'Demo diet data inserted successfully!' AS status;
SELECT COUNT(*) AS total_food_items FROM food_items;
SELECT COUNT(*) AS total_templates FROM diet_templates;
SELECT COUNT(*) AS total_days FROM diet_days;
SELECT COUNT(*) AS total_meals FROM diet_meals;
SELECT COUNT(*) AS total_meal_items FROM diet_meal_items;
