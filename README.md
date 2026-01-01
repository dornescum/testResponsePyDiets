# Diet API Test Suite

 pip install -r /Users/mihaidornescu/Documents/PERSONAL/Python/FAST_API/speedTest/requirements.txt
Python test suite for the Diet API based on the benchmark blueprint.

## Setup

```bash
cd tests
pip install -r requirements.txt
```

## Usage

```bash
# Run all API tests
python diet_api_test.py

# Run tests against a different URL
python diet_api_test.py --url http://localhost:8000

# Run with benchmarks
python diet_api_test.py --benchmark

# Run only benchmarks
python diet_api_test.py --benchmark-only --duration 30 --connections 10

# Verify database connection
python diet_api_test.py --verify-db
```

## Configuration

Default MySQL credentials (from project .env):

- Host: localhost
- Port: 3306
- User: clinic_user
- Password: 0216846822
- Database: medical_clinic

## Test Coverage

### API Tests

- Health check (`/health`)
- Categories CRUD (`/api/categories`)
- Foods with pagination and filters (`/api/foods`)
- Templates with complex joins (`/api/templates`)
- Benchmark endpoints (`/api/benchmark/*`)

### Benchmarks

- Simple CRUD: GET /api/categories
- Paginated list: GET /api/foods
- Filtered list: GET /api/foods with category
- Complex join: GET /api/templates/{id}/full

 Files updated/created:

- requirements.txt - added FastAPI, uvicorn, pydantic
- main.py - FastAPI application

  Endpoints available:

  | Endpoint            | Description                   |
  |---------------------|-------------------------------|
  | GET /               | API info                      |
  | GET /api/foods      | List all foods (with filters) |
  | GET /api/foods/{id} | Get specific food             |
  | GET /api/categories | List all categories           |
  | GET /docs           | Swagger UI documentation      |

  Query parameters for /api/foods:

- category_id - filter by category
- snack_only - filter snack-suitable foods
- search - search by name

  To run the server:
  python main.py

# or

  uvicorn main:app --reload

  You'll need to set database credentials via environment variables or update DB_CONFIG in main.py:

- DB_HOST (default: localhost)
- DB_USER (default: root)
- DB_PASSWORD (default: empty)
- DB_NAME (default: medical_clinic)

> uvicorn main:app --reload

> python diet_api_test.py
