from fastapi import FastAPI, HTTPException, Query
from mysql.connector import Error
from typing import Optional

from database import get_db_connection
from models import (
    FoodCategory, FoodItem, FoodListResponse, CategoryListResponse,
    CategoryCreate, FoodCreate, TemplateCreate, BulkInsertRequest
)

app = FastAPI(
    title="Diet Simulator API",
    description="API for managing diet plans and food items",
    version="1.0.0"
)


# API Endpoints
@app.get("/")
def root():
    """Root endpoint - API info."""
    return {
        "message": "Diet Simulator API",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "foods": "/api/foods",
            "categories": "/api/categories",
            "templates": "/api/templates",
            "docs": "/docs"
        }
    }


@app.get("/health")
def health_check():
    """Health check endpoint."""
    try:
        connection = get_db_connection()
        connection.close()
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "database": str(e)}


@app.get("/api/foods", response_model=FoodListResponse)
def get_all_foods(
    category_id: Optional[int] = Query(None, description="Filter by category ID"),
    snack_only: Optional[bool] = Query(None, description="Filter only snack-suitable foods"),
    search: Optional[str] = Query(None, description="Search by food name")
):
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

        # Convert boolean fields
        for food in foods:
            food["is_snack_suitable"] = bool(food["is_snack_suitable"])
            food["status"] = bool(food["status"])

        return FoodListResponse(
            success=True,
            count=len(foods),
            foods=foods
        )

    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()
        connection.close()


@app.get("/api/foods/{food_id}", response_model=FoodItem)
def get_food_by_id(food_id: int):
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

        if not food:
            raise HTTPException(status_code=404, detail="Food item not found")

        food["is_snack_suitable"] = bool(food["is_snack_suitable"])
        food["status"] = bool(food["status"])

        return {"success": True, "data": food}

    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()
        connection.close()


@app.get("/api/categories", response_model=CategoryListResponse)
def get_all_categories():
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
        categories = cursor.fetchall()

        return CategoryListResponse(
            success=True,
            count=len(categories),
            categories=categories
        )

    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()
        connection.close()


@app.get("/api/categories/{category_id}")
def get_category_by_id(category_id: int):
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
        category = cursor.fetchone()

        if not category:
            raise HTTPException(status_code=404, detail="Category not found")

        return {"success": True, "data": category}

    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()
        connection.close()


@app.post("/api/categories", status_code=201)
def create_category(category: CategoryCreate):
    """Create a new food category."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            INSERT INTO food_categories (name, icon, color, sort_order)
            VALUES (%s, %s, %s, %s)
        """
        cursor.execute(query, (category.name, category.icon, category.color, category.sort_order))
        connection.commit()

        return {
            "success": True,
            "data": {"id": cursor.lastrowid, **category.model_dump()}
        }

    except Error as e:
        connection.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()
        connection.close()


@app.post("/api/foods", status_code=201)
def create_food(food: FoodCreate):
    """Create a new food item."""
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
            food.category_id, food.name, food.description, food.default_portion_grams,
            food.calories_per_100g, food.protein_per_100g, food.carbs_per_100g,
            food.fat_per_100g, food.fiber_per_100g, food.is_snack_suitable
        ))
        connection.commit()

        return {
            "success": True,
            "data": {"id": cursor.lastrowid, **food.model_dump()}
        }

    except Error as e:
        connection.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()
        connection.close()


# ============================================
# TEMPLATES ENDPOINTS
# ============================================

@app.get("/api/templates")
def get_all_templates(
    segment: Optional[str] = Query(None, description="Filter by segment (A, B, C, D)"),
    type: Optional[str] = Query(None, description="Filter by type (SCR, LGI, KTP)")
):
    """Get all diet templates."""
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

        return {"success": True, "count": len(templates), "templates": templates}

    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()
        connection.close()


@app.get("/api/templates/{template_id}")
def get_template_by_id(template_id: int):
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

        if not template:
            raise HTTPException(status_code=404, detail="Template not found")

        template["status"] = bool(template["status"])

        return {"success": True, "template": template}

    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()
        connection.close()


@app.get("/api/templates/{template_id}/full")
def get_template_full(template_id: int):
    """Get full diet template with days, meals, and food items."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        # Get template
        cursor.execute("""
            SELECT id, code, name, description, segment, type,
                   duration_days, calories_target, notes, status
            FROM diet_templates WHERE id = %s
        """, (template_id,))
        template = cursor.fetchone()

        if not template:
            raise HTTPException(status_code=404, detail="Template not found")

        template["status"] = bool(template["status"])

        # Get days
        cursor.execute("""
            SELECT id, day_number, day_name, notes
            FROM diet_days WHERE template_id = %s ORDER BY day_number
        """, (template_id,))
        days = cursor.fetchall()

        # Get meals and items for each day
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

        return {"success": True, "template": template}

    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()
        connection.close()


@app.post("/api/templates", status_code=201)
def create_template(template: TemplateCreate):
    """Create a new diet template."""
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        query = """
            INSERT INTO diet_templates (code, name, description, segment, type,
                                        duration_days, calories_target, notes)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query, (
            template.code, template.name, template.description, template.segment,
            template.type, template.duration_days, template.calories_target, template.notes
        ))
        connection.commit()

        return {
            "success": True,
            "data": {"id": cursor.lastrowid, **template.model_dump()}
        }

    except Error as e:
        connection.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()
        connection.close()


# ============================================
# BENCHMARK ENDPOINTS
# ============================================

@app.get("/api/benchmark/complex-query")
def benchmark_complex_query():
    """Complex query for benchmarking - aggregates nutritional data by category."""
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
        results = cursor.fetchall()

        return {"success": True, "data": results}

    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()
        connection.close()


@app.post("/api/benchmark/bulk-insert", status_code=201)
def benchmark_bulk_insert(request: BulkInsertRequest):
    """Bulk insert meal items for benchmarking."""
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
        for item in request.items:
            try:
                cursor.execute(query, (
                    request.meal_id, item.food_item_id, item.portion_grams_min,
                    item.portion_grams_max, item.portion_description,
                    item.is_optional, item.sort_order
                ))
                inserted += 1
            except Error:
                continue

        connection.commit()

        return {
            "success": True,
            "inserted_count": inserted,
            "message": f"Inserted {inserted} items"
        }

    except Error as e:
        connection.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()
        connection.close()


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
