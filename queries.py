from typing import Optional
from database import get_db_connection


# =============================================================================
# FOOD QUERIES
# =============================================================================

def get_all_foods(
    category_id: Optional[int] = None,
    snack_only: Optional[bool] = None,
    search: Optional[str] = None
) -> list[dict]:
    """Get all food items with optional filters."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            SELECT
                fi.id,
                fi.category_id,
                fc.name as category_name,
                fi.name,
                fi.description,
                fi.default_portion_grams,
                fi.calories_per_100g,
                fi.protein_per_100g,
                fi.carbs_per_100g,
                fi.fat_per_100g,
                fi.fiber_per_100g,
                fi.is_snack_suitable,
                fi.status
            FROM food_items fi
            LEFT JOIN food_categories fc ON fi.category_id = fc.id
            WHERE fi.status = 1
        """
        params = []

        if category_id is not None:
            query += " AND fi.category_id = %s"
            params.append(category_id)

        if snack_only is True:
            query += " AND fi.is_snack_suitable = 1"

        if search:
            query += " AND fi.name LIKE %s"
            params.append(f"%{search}%")

        query += " ORDER BY fc.sort_order, fi.name"

        cursor.execute(query, params)
        foods = cursor.fetchall()

        for food in foods:
            food["is_snack_suitable"] = bool(food["is_snack_suitable"])
            food["status"] = bool(food["status"])

        return foods

    finally:
        cursor.close()
        connection.close()


def get_food_by_id(food_id: int) -> dict | None:
    """Get a specific food item by ID."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            SELECT
                fi.id,
                fi.category_id,
                fc.name as category_name,
                fi.name,
                fi.description,
                fi.default_portion_grams,
                fi.calories_per_100g,
                fi.protein_per_100g,
                fi.carbs_per_100g,
                fi.fat_per_100g,
                fi.fiber_per_100g,
                fi.is_snack_suitable,
                fi.status
            FROM food_items fi
            LEFT JOIN food_categories fc ON fi.category_id = fc.id
            WHERE fi.id = %s
        """
        cursor.execute(query, (food_id,))
        food = cursor.fetchone()

        if food:
            food["is_snack_suitable"] = bool(food["is_snack_suitable"])
            food["status"] = bool(food["status"])

        return food

    finally:
        cursor.close()
        connection.close()


def create_food(
    category_id: int,
    name: str,
    description: Optional[str],
    default_portion_grams: int,
    calories_per_100g: Optional[float],
    protein_per_100g: Optional[float],
    carbs_per_100g: Optional[float],
    fat_per_100g: Optional[float],
    fiber_per_100g: Optional[float],
    is_snack_suitable: bool
) -> int:
    """Create a new food item. Returns the new ID."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            INSERT INTO food_items (
                category_id, name, description, default_portion_grams,
                calories_per_100g, protein_per_100g, carbs_per_100g,
                fat_per_100g, fiber_per_100g, is_snack_suitable
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query, (
            category_id, name, description, default_portion_grams,
            calories_per_100g, protein_per_100g, carbs_per_100g,
            fat_per_100g, fiber_per_100g, is_snack_suitable
        ))
        connection.commit()
        return cursor.lastrowid

    except Exception:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()


# =============================================================================
# CATEGORY QUERIES
# =============================================================================

def get_all_categories() -> list[dict]:
    """Get all food categories."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            SELECT id, name, icon, color, sort_order
            FROM food_categories
            ORDER BY sort_order
        """
        cursor.execute(query)
        return cursor.fetchall()

    finally:
        cursor.close()
        connection.close()


def get_category_by_id(category_id: int) -> dict | None:
    """Get a specific category by ID."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            SELECT id, name, icon, color, sort_order
            FROM food_categories
            WHERE id = %s
        """
        cursor.execute(query, (category_id,))
        return cursor.fetchone()

    finally:
        cursor.close()
        connection.close()


def create_category(
    name: str,
    icon: Optional[str],
    color: Optional[str],
    sort_order: int
) -> int:
    """Create a new food category. Returns the new ID."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            INSERT INTO food_categories (name, icon, color, sort_order)
            VALUES (%s, %s, %s, %s)
        """
        cursor.execute(query, (name, icon, color, sort_order))
        connection.commit()
        return cursor.lastrowid

    except Exception:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()


# =============================================================================
# TEMPLATE QUERIES
# =============================================================================

def get_all_templates(
    segment: Optional[str] = None,
    type: Optional[str] = None
) -> list[dict]:
    """Get all diet templates with optional filters."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            SELECT id, code, name, description, segment, type,
                   duration_days, calories_target, notes, status
            FROM diet_templates
            WHERE status = 1
        """
        params = []

        if segment:
            query += " AND segment = %s"
            params.append(segment)

        if type:
            query += " AND type = %s"
            params.append(type)

        query += " ORDER BY id"

        cursor.execute(query, params)
        templates = cursor.fetchall()

        for t in templates:
            t["status"] = bool(t["status"])

        return templates

    finally:
        cursor.close()
        connection.close()


def get_template_by_id(template_id: int) -> dict | None:
    """Get a specific diet template by ID."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            SELECT id, code, name, description, segment, type,
                   duration_days, calories_target, notes, status
            FROM diet_templates
            WHERE id = %s
        """
        cursor.execute(query, (template_id,))
        template = cursor.fetchone()

        if template:
            template["status"] = bool(template["status"])

        return template

    finally:
        cursor.close()
        connection.close()


def get_template_full(template_id: int) -> dict | None:
    """Get full diet template with days, meals, and food items."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT id, code, name, description, segment, type,
                   duration_days, calories_target, notes, status
            FROM diet_templates WHERE id = %s
        """, (template_id,))
        template = cursor.fetchone()

        if not template:
            return None

        template["status"] = bool(template["status"])

        cursor.execute("""
            SELECT id, day_number, day_name, notes
            FROM diet_days WHERE template_id = %s ORDER BY day_number
        """, (template_id,))
        days = cursor.fetchall()

        for day in days:
            cursor.execute("""
                SELECT id, meal_type, meal_order, time_suggestion, notes
                FROM diet_meals WHERE day_id = %s ORDER BY meal_order
            """, (day["id"],))
            meals = cursor.fetchall()

            for meal in meals:
                cursor.execute("""
                    SELECT dmi.id, dmi.food_item_id, fi.name as food_name,
                           dmi.portion_grams_min, dmi.portion_grams_max,
                           dmi.portion_description, dmi.preparation_notes,
                           dmi.is_optional, dmi.sort_order
                    FROM diet_meal_items dmi
                    JOIN food_items fi ON dmi.food_item_id = fi.id
                    WHERE dmi.meal_id = %s ORDER BY dmi.sort_order
                """, (meal["id"],))
                meal["items"] = cursor.fetchall()
                for item in meal["items"]:
                    item["is_optional"] = bool(item["is_optional"])

            day["meals"] = meals

        template["days"] = days
        return template

    finally:
        cursor.close()
        connection.close()


def create_template(
    code: str,
    name: str,
    description: Optional[str],
    segment: str,
    type: str,
    duration_days: int,
    calories_target: Optional[int],
    notes: Optional[str]
) -> int:
    """Create a new diet template. Returns the new ID."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            INSERT INTO diet_templates (code, name, description, segment, type,
                                        duration_days, calories_target, notes)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query, (
            code, name, description, segment,
            type, duration_days, calories_target, notes
        ))
        connection.commit()
        return cursor.lastrowid

    except Exception:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()


# =============================================================================
# BENCHMARK QUERIES
# =============================================================================

def get_nutritional_stats_by_category() -> list[dict]:
    """Complex query - aggregates nutritional data by category."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            SELECT
                fc.name as category,
                COUNT(fi.id) as food_count,
                AVG(fi.calories_per_100g) as avg_calories,
                AVG(fi.protein_per_100g) as avg_protein,
                AVG(fi.carbs_per_100g) as avg_carbs,
                AVG(fi.fat_per_100g) as avg_fat
            FROM food_categories fc
            LEFT JOIN food_items fi ON fc.id = fi.category_id
            GROUP BY fc.id, fc.name
            ORDER BY fc.sort_order
        """
        cursor.execute(query)
        return cursor.fetchall()

    finally:
        cursor.close()
        connection.close()


def bulk_insert_meal_items(meal_id: int, items: list[dict]) -> int:
    """Bulk insert meal items. Returns count of inserted items."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            INSERT INTO diet_meal_items
            (meal_id, food_item_id, portion_grams_min, portion_grams_max,
             portion_description, is_optional, sort_order)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """

        inserted = 0
        for item in items:
            try:
                cursor.execute(query, (
                    meal_id, item["food_item_id"], item["portion_grams_min"],
                    item["portion_grams_max"], item.get("portion_description"),
                    item.get("is_optional", False), item.get("sort_order", 0)
                ))
                inserted += 1
            except Exception:
                continue

        connection.commit()
        return inserted

    except Exception:
        connection.rollback()
        raise

    finally:
        cursor.close()
        connection.close()


# =============================================================================
# HEALTH CHECK
# =============================================================================

def check_db_connection() -> bool:
    """Check if database connection is working."""
    try:
        connection = get_db_connection()
        connection.close()
        return True
    except Exception:
        return False
