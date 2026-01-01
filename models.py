from pydantic import BaseModel
from typing import Optional


# Response models
class FoodCategory(BaseModel):
    id: int
    name: str
    icon: Optional[str] = None
    color: Optional[str] = None
    sort_order: int


class FoodItem(BaseModel):
    id: int
    category_id: int
    category_name: Optional[str] = None
    name: str
    description: Optional[str] = None
    default_portion_grams: int
    calories_per_100g: Optional[float] = None
    protein_per_100g: Optional[float] = None
    carbs_per_100g: Optional[float] = None
    fat_per_100g: Optional[float] = None
    fiber_per_100g: Optional[float] = None
    is_snack_suitable: bool
    status: bool


class FoodListResponse(BaseModel):
    success: bool
    count: int
    foods: list[FoodItem]


class CategoryListResponse(BaseModel):
    success: bool
    count: int
    categories: list[FoodCategory]


# Request models for POST
class CategoryCreate(BaseModel):
    name: str
    icon: Optional[str] = None
    color: Optional[str] = None
    sort_order: int = 0


class FoodCreate(BaseModel):
    category_id: int
    name: str
    description: Optional[str] = None
    default_portion_grams: int = 100
    calories_per_100g: Optional[float] = None
    protein_per_100g: Optional[float] = None
    carbs_per_100g: Optional[float] = None
    fat_per_100g: Optional[float] = None
    fiber_per_100g: Optional[float] = None
    is_snack_suitable: bool = False


class TemplateCreate(BaseModel):
    code: str
    name: str
    description: Optional[str] = None
    segment: str
    type: str
    duration_days: int = 30
    calories_target: Optional[int] = None
    notes: Optional[str] = None


# Benchmark models
class BulkInsertItem(BaseModel):
    food_item_id: int
    portion_grams_min: int
    portion_grams_max: int
    portion_description: Optional[str] = None
    is_optional: bool = False
    sort_order: int = 0


class BulkInsertRequest(BaseModel):
    meal_id: int
    items: list[BulkInsertItem]
