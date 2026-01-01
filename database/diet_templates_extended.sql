-- ============================================
-- EXTENDED DIET TEMPLATES
-- 20 Additional Templates for Various Populations
-- ============================================

-- Segment Legend:
-- A = Under 55kg
-- B = 55-65kg
-- C = 65-85kg
-- D = Over 85kg

-- ============================================
-- ATHLETIC / SPORT PERFORMANCE TEMPLATES
-- ============================================

-- 1. Endurance Athlete - High Carb Performance
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('SPORT_C_ENDURANCE', 'Endurance Athlete Protocol - Segment C',
'High-carbohydrate performance diet for endurance athletes (runners, cyclists, swimmers). Optimized glycogen loading with adequate protein for recovery.',
'C', 'SPORT', 30, 2400,
'Ideal for athletes training 10+ hours/week. Carb ratio: 55-60%. Time carbs around training sessions. Include electrolyte supplementation.', 1);

-- 2. Strength Training - Muscle Building
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('SPORT_D_STRENGTH', 'Strength Training Protocol - Segment D',
'High-protein muscle-building diet for strength athletes and bodybuilders. Caloric surplus with emphasis on protein timing and quality.',
'D', 'SPORT', 30, 2800,
'Protein target: 2g/kg bodyweight. Distribute protein across 5-6 meals. Post-workout nutrition critical within 2 hours.', 1);

-- 3. Athletic Cutting - Lean Phase
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('SPORT_B_CUTTING', 'Athletic Cutting Protocol - Segment B',
'Controlled caloric deficit for athletes during cutting phase. Preserves muscle mass while promoting fat loss.',
'B', 'SPORT', 30, 1600,
'Maintain high protein (2.2g/kg) during deficit. Reduce carbs on rest days. Keep fats at minimum 20% for hormonal health.', 1);

-- 4. Pre-Competition Peak Week
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('SPORT_C_PRECOMP', 'Pre-Competition Protocol - Segment C',
'Strategic carb manipulation and water management for competition week. Used by physique and weight-class athletes.',
'C', 'SPORT', 7, 2000,
'Days 1-3: Low carb depletion. Days 4-6: Carb loading. Day 7: Competition day. Monitor sodium and water intake carefully.', 1);

-- 5. CrossFit / High Intensity
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('SPORT_C_HIIT', 'High Intensity Training Protocol - Segment C',
'Balanced macros for CrossFit and HIIT athletes. Supports both strength and conditioning demands.',
'C', 'SPORT', 30, 2200,
'Zone diet inspired: 40% carbs, 30% protein, 30% fat. Focus on nutrient timing around workouts.', 1);

-- 6. Marathon Training
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('SPORT_B_MARATHON', 'Marathon Training Protocol - Segment B',
'Periodized nutrition for marathon preparation. Progressive carb loading strategy.',
'B', 'SPORT', 30, 2100,
'Base phase: moderate carbs. Long run days: increase carbs by 100-150g. Practice race-day nutrition during long runs.', 1);

-- ============================================
-- LIFESTYLE / DIETARY PREFERENCE TEMPLATES
-- ============================================

-- 7. Vegetarian Balanced
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('VEG_C_BALANCED', 'Vegetarian Balanced Protocol - Segment C',
'Complete vegetarian diet with eggs and dairy. Ensures adequate protein through varied plant and dairy sources.',
'C', 'LGI', 30, 1800,
'Combine legumes with grains for complete proteins. Include B12-fortified foods. Consider iron absorption enhancers (vitamin C).', 1);

-- 8. Vegan Performance
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('VEG_C_VEGAN', 'Vegan Performance Protocol - Segment C',
'Plant-based diet optimized for active individuals. Strategic protein combining and micronutrient focus.',
'C', 'LGI', 30, 1900,
'Supplement B12, consider D3 and omega-3 (algae-based). Track iron and zinc intake. Include daily legumes and whole grains.', 1);

-- 9. Mediterranean Heart-Healthy
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('MED_B_STANDARD', 'Mediterranean Protocol - Segment B',
'Traditional Mediterranean diet pattern. Rich in olive oil, fish, vegetables, and whole grains for cardiovascular health.',
'B', 'MED', 30, 1700,
'Fish 3x/week minimum. Extra virgin olive oil as primary fat. Red wine optional (1 glass with dinner). Limit red meat to 2x/month.', 1);

-- 10. Mediterranean - Senior Friendly
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('MED_A_SENIOR', 'Mediterranean Senior Protocol - Segment A',
'Adapted Mediterranean diet for older adults. Higher protein for muscle preservation, softer textures available.',
'A', 'MED', 30, 1500,
'Protein: 1.2g/kg for sarcopenia prevention. Include calcium-rich foods. Consider vitamin D supplementation. Fiber for digestive health.', 1);

-- ============================================
-- MEDICAL CONDITION SPECIFIC TEMPLATES
-- ============================================

-- 11. PCOS Management
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('PCOS_B_STANDARD', 'PCOS Management Protocol - Segment B',
'Low glycemic, anti-inflammatory diet for polycystic ovary syndrome management. Supports hormonal balance and insulin sensitivity.',
'B', 'LGI', 30, 1600,
'Emphasize fiber and protein at each meal. Avoid refined carbs completely. Include anti-inflammatory foods (turmeric, omega-3). Consider inositol supplementation.', 1);

-- 12. Anti-Inflammatory
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('ANTI_C_STANDARD', 'Anti-Inflammatory Protocol - Segment C',
'Diet designed to reduce systemic inflammation. Beneficial for autoimmune conditions, joint pain, and chronic inflammation.',
'C', 'LGI', 30, 1800,
'Eliminate processed foods, refined sugars, and seed oils. Focus on omega-3 rich fish, colorful vegetables, and spices like turmeric and ginger.', 1);

-- 13. Diabetes Type 2 Management
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('DM2_C_STANDARD', 'Diabetes Type 2 Protocol - Segment C',
'Structured low glycemic diet for Type 2 diabetes management. Focuses on blood sugar stability and weight management.',
'C', 'LGI', 30, 1700,
'Strict portion control. No more than 45g carbs per meal. Always pair carbs with protein or fat. Regular meal timing essential.', 1);

-- 14. Cardiac Rehabilitation
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('CARDIAC_B_REHAB', 'Cardiac Rehabilitation Protocol - Segment B',
'Heart-healthy diet for post-cardiac event recovery. Low sodium, emphasis on heart-protective nutrients.',
'B', 'MED', 30, 1600,
'Sodium limit: 1500mg/day. No processed meats. Omega-3 fish 4x/week. Increase potassium through fruits and vegetables. Limit saturated fat to <7%.', 1);

-- ============================================
-- SPECIALIZED / LIFESTYLE TEMPLATES
-- ============================================

-- 15. Intermittent Fasting 16:8
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('IF_C_168', 'Intermittent Fasting 16:8 Protocol - Segment C',
'Time-restricted eating with 16-hour fasting window. Two main meals plus one snack during 8-hour eating window.',
'C', 'SCR', 30, 1800,
'Eating window: 12:00-20:00. First meal breaks fast with protein focus. Stay hydrated during fast with water, black coffee, or tea.', 1);

-- 16. Post-Pregnancy Recovery
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('POST_B_PREGNANCY', 'Post-Pregnancy Recovery Protocol - Segment B',
'Nutrient-dense diet for postpartum recovery and breastfeeding support. Focus on energy, iron, and omega-3.',
'B', 'SCR', 30, 2000,
'Add 300-500 kcal if breastfeeding. Emphasize iron-rich foods for blood loss recovery. Include galactagogues (oats, fennel) if needed. Adequate hydration critical.', 1);

-- 17. Menopause Support
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('MENO_B_STANDARD', 'Menopause Support Protocol - Segment B',
'Hormone-balancing diet for perimenopause and menopause. Addresses bone health, weight management, and symptom reduction.',
'B', 'LGI', 30, 1500,
'Include phytoestrogen foods (soy, flaxseed). Calcium 1200mg/day with vitamin D. Limit caffeine and alcohol. Cool, light meals for hot flash management.', 1);

-- 18. Detox / Reset
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('DETOX_A_RESET', 'Metabolic Reset Protocol - Segment A',
'Short-term whole foods reset to eliminate processed foods and support liver function. Clean eating foundation.',
'A', 'SCR', 14, 1400,
'No alcohol, caffeine, sugar, or processed foods. Emphasis on cruciferous vegetables, lemon water, and green tea. Gentle exercise only.', 1);

-- 19. Teen Athlete Growth
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('TEEN_C_ATHLETE', 'Teen Athlete Growth Protocol - Segment C',
'Nutrient-dense diet for adolescent athletes. Supports growth, development, and athletic performance.',
'C', 'SPORT', 30, 2500,
'No caloric restriction - focus on quality. Calcium and vitamin D for bone growth. Iron especially for female athletes. Regular eating schedule essential.', 1);

-- 20. Executive Stress Management
INSERT INTO diet_templates (code, name, description, segment, type, duration_days, calories_target, notes, status) VALUES
('EXEC_B_STRESS', 'Executive Stress Management Protocol - Segment B',
'Anti-stress nutrition protocol for high-pressure professionals. Supports adrenal health, mental clarity, and energy.',
'B', 'LGI', 30, 1800,
'Include adaptogens (ashwagandha tea). Magnesium-rich foods for relaxation. Limit caffeine to morning only. Regular meal timing despite busy schedule.', 1);

-- ============================================
-- VERIFICATION QUERY
-- ============================================
-- Run this to verify the new templates were inserted:
-- SELECT code, name, segment, type, calories_target FROM diet_templates ORDER BY created_at DESC LIMIT 20;
