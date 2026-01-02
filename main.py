from fastapi import FastAPI, HTTPException, Query
from mysql.connector import Error
from typing import Optional

import queries
from models import (
    FoodListResponse, FoodItemResponse,
    CategoryListResponse, CategoryResponse,
    TemplateListResponse, TemplateResponse, TemplateFullResponse,
    CategoryCreate, FoodCreate, TemplateCreate, BulkInsertRequest
)

app = FastAPI(
    title="Diet Simulator API",
    description="API for managing diet plans and food items",
    version="1.0.0"
)


# =============================================================================
# ROOT & HEALTH
# =============================================================================

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
    if queries.check_db_connection():
        return {"status": "healthy", "database": "connected"}
    return {"status": "unhealthy", "database": "disconnected"}


# =============================================================================
# FOODS
# =============================================================================

@app.get("/api/foods", response_model=FoodListResponse)
def list_foods(
    category_id: Optional[int] = Query(None, description="Filter by category ID"),
    snack_only: Optional[bool] = Query(None, description="Filter only snack-suitable foods"),
    search: Optional[str] = Query(None, description="Search by food name")
):
    """Get all food items with optional filters."""
    try:
        foods = queries.get_all_foods(category_id, snack_only, search)
        return FoodListResponse(success=True, count=len(foods), foods=foods)
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/foods/{food_id}", response_model=FoodItemResponse)
def get_food(food_id: int):
    """Get a specific food item by ID."""
    try:
        food = queries.get_food_by_id(food_id)
        if not food:
            raise HTTPException(status_code=404, detail="Food item not found")
        return FoodItemResponse(success=True, data=food)
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/foods", status_code=201)
def create_food(food: FoodCreate):
    """Create a new food item."""
    try:
        new_id = queries.create_food(
            category_id=food.category_id,
            name=food.name,
            description=food.description,
            default_portion_grams=food.default_portion_grams,
            calories_per_100g=food.calories_per_100g,
            protein_per_100g=food.protein_per_100g,
            carbs_per_100g=food.carbs_per_100g,
            fat_per_100g=food.fat_per_100g,
            fiber_per_100g=food.fiber_per_100g,
            is_snack_suitable=food.is_snack_suitable
        )
        return {"success": True, "data": {"id": new_id, **food.model_dump()}}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))


# =============================================================================
# CATEGORIES
# =============================================================================

@app.get("/api/categories", response_model=CategoryListResponse)
def list_categories():
    """Get all food categories."""
    try:
        categories = queries.get_all_categories()
        return CategoryListResponse(success=True, count=len(categories), categories=categories)
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/categories/{category_id}", response_model=CategoryResponse)
def get_category(category_id: int):
    """Get a specific category by ID."""
    try:
        category = queries.get_category_by_id(category_id)
        if not category:
            raise HTTPException(status_code=404, detail="Category not found")
        return CategoryResponse(success=True, data=category)
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/categories", status_code=201)
def create_category(category: CategoryCreate):
    """Create a new food category."""
    try:
        new_id = queries.create_category(
            name=category.name,
            icon=category.icon,
            color=category.color,
            sort_order=category.sort_order
        )
        return {"success": True, "data": {"id": new_id, **category.model_dump()}}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))


# =============================================================================
# TEMPLATES
# =============================================================================

@app.get("/api/templates", response_model=TemplateListResponse)
def list_templates(
    segment: Optional[str] = Query(None, description="Filter by segment (A, B, C, D)"),
    type: Optional[str] = Query(None, description="Filter by type (SCR, LGI, KTP)")
):
    """Get all diet templates."""
    try:
        templates = queries.get_all_templates(segment, type)
        return TemplateListResponse(success=True, count=len(templates), templates=templates)
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/templates/{template_id}", response_model=TemplateResponse)
def get_template(template_id: int):
    """Get a specific diet template by ID."""
    try:
        template = queries.get_template_by_id(template_id)
        if not template:
            raise HTTPException(status_code=404, detail="Template not found")
        return TemplateResponse(success=True, template=template)
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/templates/{template_id}/full", response_model=TemplateFullResponse)
def get_template_full(template_id: int):
    """Get full diet template with days, meals, and food items."""
    try:
        template = queries.get_template_full(template_id)
        if not template:
            raise HTTPException(status_code=404, detail="Template not found")
        return TemplateFullResponse(success=True, template=template)
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/templates", status_code=201)
def create_template(template: TemplateCreate):
    """Create a new diet template."""
    try:
        new_id = queries.create_template(
            code=template.code,
            name=template.name,
            description=template.description,
            segment=template.segment,
            type=template.type,
            duration_days=template.duration_days,
            calories_target=template.calories_target,
            notes=template.notes
        )
        return {"success": True, "data": {"id": new_id, **template.model_dump()}}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))


# =============================================================================
# BENCHMARK ENDPOINTS
# =============================================================================

@app.get("/api/benchmark/complex-query")
def benchmark_complex_query():
    """Complex query for benchmarking - aggregates nutritional data by category."""
    try:
        results = queries.get_nutritional_stats_by_category()
        return {"success": True, "data": results}
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/benchmark/bulk-insert", status_code=201)
def benchmark_bulk_insert(request: BulkInsertRequest):
    """Bulk insert meal items for benchmarking."""
    try:
        items = [item.model_dump() for item in request.items]
        inserted = queries.bulk_insert_meal_items(request.meal_id, items)
        return {
            "success": True,
            "inserted_count": inserted,
            "message": f"Inserted {inserted} items"
        }
    except Error as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
