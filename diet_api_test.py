#!/usr/bin/env python3
"""
Diet API Benchmark Test Suite
Based on DIET_BENCHMARK_BLUEPRINT.md OpenAPI Specification

Requirements:
    pip install requests mysql-connector-python tabulate

Usage:
    python diet_api_test.py                     # Run all tests
    python diet_api_test.py --benchmark         # Run benchmarks
    python diet_api_test.py --verify-db         # Verify DB connection
"""

import argparse
import json
import random
import statistics
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from datetime import datetime
from typing import Any, Dict, List, Optional

try:
    import requests
except ImportError:
    print("Error: requests library required. Run: pip install requests")
    sys.exit(1)

# =============================================================================
# CONFIGURATION
# =============================================================================

@dataclass
class Config:
    """API and Database configuration"""
    # API Settings
    base_url: str = "http://localhost:8000"
    timeout: int = 30

    # MySQL Credentials (from project .env)
    db_host: str = "localhost"
    db_port: int = 3306
    db_user: str = "clinic_user"
    db_password: str = "clinic_password"
    db_name: str = "medical_clinic"

    # Benchmark Settings
    benchmark_duration: int = 30  # seconds
    benchmark_connections: int = 10
    benchmark_requests_per_test: int = 100


config = Config()


# =============================================================================
# RESULT TRACKING
# =============================================================================

@dataclass
class TestResult:
    """Individual test result"""
    name: str
    passed: bool
    status_code: int
    response_time_ms: float
    message: str = ""
    data: Optional[Dict] = None


@dataclass
class BenchmarkResult:
    """Benchmark test result"""
    test_name: str
    requests_total: int
    requests_success: int
    requests_failed: int
    requests_per_second: float
    avg_latency_ms: float
    p50_latency_ms: float
    p95_latency_ms: float
    p99_latency_ms: float
    min_latency_ms: float
    max_latency_ms: float
    error_rate: float


class ResultTracker:
    """Track and display test results"""

    def __init__(self):
        self.results: List[TestResult] = []
        self.benchmarks: List[BenchmarkResult] = []

    def add_result(self, result: TestResult):
        self.results.append(result)
        status = "✓" if result.passed else "✗"
        print(f"  {status} {result.name}: {result.status_code} ({result.response_time_ms:.1f}ms)")
        if not result.passed and result.message:
            print(f"    └─ {result.message}")

    def add_benchmark(self, result: BenchmarkResult):
        self.benchmarks.append(result)

    def summary(self) -> Dict[str, Any]:
        passed = sum(1 for r in self.results if r.passed)
        failed = sum(1 for r in self.results if not r.passed)
        return {
            "total": len(self.results),
            "passed": passed,
            "failed": failed,
            "success_rate": passed / len(self.results) * 100 if self.results else 0,
        }

    def print_summary(self):
        print("\n" + "=" * 60)
        print("TEST SUMMARY")
        print("=" * 60)

        s = self.summary()
        print(f"Total Tests: {s['total']}")
        print(f"Passed: {s['passed']}")
        print(f"Failed: {s['failed']}")
        print(f"Success Rate: {s['success_rate']:.1f}%")

        if self.benchmarks:
            print("\n" + "-" * 60)
            print("BENCHMARK RESULTS")
            print("-" * 60)

            try:
                from tabulate import tabulate
                headers = ["Test", "Req/s", "Avg(ms)", "P95(ms)", "P99(ms)", "Errors"]
                rows = [
                    [
                        b.test_name,
                        f"{b.requests_per_second:.1f}",
                        f"{b.avg_latency_ms:.1f}",
                        f"{b.p95_latency_ms:.1f}",
                        f"{b.p99_latency_ms:.1f}",
                        f"{b.error_rate:.2%}",
                    ]
                    for b in self.benchmarks
                ]
                print(tabulate(rows, headers=headers, tablefmt="grid"))
            except ImportError:
                for b in self.benchmarks:
                    print(f"\n{b.test_name}:")
                    print(f"  Requests/sec: {b.requests_per_second:.1f}")
                    print(f"  Avg Latency: {b.avg_latency_ms:.1f}ms")
                    print(f"  P95 Latency: {b.p95_latency_ms:.1f}ms")
                    print(f"  P99 Latency: {b.p99_latency_ms:.1f}ms")
                    print(f"  Error Rate: {b.error_rate:.2%}")


tracker = ResultTracker()


# =============================================================================
# HTTP CLIENT
# =============================================================================

class APIClient:
    """HTTP client for Diet API"""

    def __init__(self, base_url: str = None, timeout: int = None):
        self.base_url = base_url or config.base_url
        self.timeout = timeout or config.timeout
        self.session = requests.Session()

    def _url(self, path: str) -> str:
        return f"{self.base_url}{path}"

    def _request(self, method: str, path: str, **kwargs) -> requests.Response:
        kwargs.setdefault("timeout", self.timeout)
        url = self._url(path)
        return self.session.request(method, url, **kwargs)

    def get(self, path: str, **kwargs) -> requests.Response:
        return self._request("GET", path, **kwargs)

    def post(self, path: str, **kwargs) -> requests.Response:
        return self._request("POST", path, **kwargs)

    def put(self, path: str, **kwargs) -> requests.Response:
        return self._request("PUT", path, **kwargs)

    def delete(self, path: str, **kwargs) -> requests.Response:
        return self._request("DELETE", path, **kwargs)

    def timed_get(self, path: str, **kwargs) -> tuple:
        """GET with timing, returns (response, time_ms)"""
        start = time.perf_counter()
        response = self.get(path, **kwargs)
        elapsed = (time.perf_counter() - start) * 1000
        return response, elapsed

    def timed_post(self, path: str, **kwargs) -> tuple:
        """POST with timing, returns (response, time_ms)"""
        start = time.perf_counter()
        response = self.post(path, **kwargs)
        elapsed = (time.perf_counter() - start) * 1000
        return response, elapsed


client = APIClient()


# =============================================================================
# TEST FUNCTIONS
# =============================================================================

def test_health_check() -> TestResult:
    """Test /health endpoint"""
    try:
        resp, elapsed = client.timed_get("/health")
        data = resp.json() if resp.text else {}

        passed = resp.status_code == 200
        return TestResult(
            name="GET /health",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            data=data,
        )
    except Exception as e:
        return TestResult(
            name="GET /health",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_list_categories() -> TestResult:
    """Test GET /api/categories"""
    try:
        resp, elapsed = client.timed_get("/api/categories")
        data = resp.json() if resp.text else {}

        passed = (
            resp.status_code == 200
            and data.get("success") is True
            and isinstance(data.get("categories"), list)
        )

        return TestResult(
            name="GET /api/categories",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            message="" if passed else f"Expected success response with categories, got: {data}",
            data=data,
        )
    except Exception as e:
        return TestResult(
            name="GET /api/categories",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_create_category() -> TestResult:
    """Test POST /api/categories"""
    payload = {
        "name": f"Test Category {int(time.time())}",
        "icon": "fa-test",
        "color": "#FF5733",
        "sort_order": 99,
    }

    try:
        resp, elapsed = client.timed_post("/api/categories", json=payload)
        data = resp.json() if resp.text else {}

        passed = resp.status_code == 201 and data.get("success") is True

        return TestResult(
            name="POST /api/categories",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            message="" if passed else f"Create failed: {data}",
            data=data,
        )
    except Exception as e:
        return TestResult(
            name="POST /api/categories",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_get_category(category_id: int = 1) -> TestResult:
    """Test GET /api/categories/{id}"""
    try:
        resp, elapsed = client.timed_get(f"/api/categories/{category_id}")
        data = resp.json() if resp.text else {}

        passed = resp.status_code == 200 and data.get("success") is True

        return TestResult(
            name=f"GET /api/categories/{category_id}",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            data=data,
        )
    except Exception as e:
        return TestResult(
            name=f"GET /api/categories/{category_id}",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_list_foods() -> TestResult:
    """Test GET /api/foods"""
    try:
        resp, elapsed = client.timed_get("/api/foods")
        data = resp.json() if resp.text else {}

        passed = (
            resp.status_code == 200
            and data.get("success") is True
            and isinstance(data.get("foods"), list)
        )

        return TestResult(
            name="GET /api/foods",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            message="" if passed else f"Expected foods list: {data}",
            data=data,
        )
    except Exception as e:
        return TestResult(
            name="GET /api/foods",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_list_foods_filtered() -> TestResult:
    """Test GET /api/foods with category filter"""
    try:
        resp, elapsed = client.timed_get("/api/foods?category_id=1")
        data = resp.json() if resp.text else {}

        passed = resp.status_code == 200 and data.get("success") is True and isinstance(data.get("foods"), list)

        return TestResult(
            name="GET /api/foods?category_id=1",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            data=data,
        )
    except Exception as e:
        return TestResult(
            name="GET /api/foods?category_id=1",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_list_foods_search() -> TestResult:
    """Test GET /api/foods with search"""
    try:
        resp, elapsed = client.timed_get("/api/foods?search=chicken")
        data = resp.json() if resp.text else {}

        passed = resp.status_code == 200 and data.get("success") is True and isinstance(data.get("foods"), list)

        return TestResult(
            name="GET /api/foods?search=chicken",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            data=data,
        )
    except Exception as e:
        return TestResult(
            name="GET /api/foods?search=pollo",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_create_food() -> TestResult:
    """Test POST /api/foods"""
    payload = {
        "category_id": 1,
        "name": f"Test Food {int(time.time())}",
        "description": "Test food item for API testing",
        "default_portion_grams": 100,
        "calories_per_100g": 150.5,
        "protein_per_100g": 12.3,
        "carbs_per_100g": 8.5,
        "fat_per_100g": 5.2,
        "fiber_per_100g": 2.1,
        "is_snack_suitable": True,
    }

    try:
        resp, elapsed = client.timed_post("/api/foods", json=payload)
        data = resp.json() if resp.text else {}

        passed = resp.status_code == 201 and data.get("success") is True

        return TestResult(
            name="POST /api/foods",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            message="" if passed else f"Create failed: {data}",
            data=data,
        )
    except Exception as e:
        return TestResult(
            name="POST /api/foods",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_get_food(food_id: int = 1) -> TestResult:
    """Test GET /api/foods/{id}"""
    try:
        resp, elapsed = client.timed_get(f"/api/foods/{food_id}")
        data = resp.json() if resp.text else {}

        passed = resp.status_code == 200 and data.get("success") is True

        return TestResult(
            name=f"GET /api/foods/{food_id}",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            data=data,
        )
    except Exception as e:
        return TestResult(
            name=f"GET /api/foods/{food_id}",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_list_templates() -> TestResult:
    """Test GET /api/templates"""
    try:
        resp, elapsed = client.timed_get("/api/templates")
        data = resp.json() if resp.text else {}

        passed = (
            resp.status_code == 200
            and data.get("success") is True
            and isinstance(data.get("templates"), list)
        )

        return TestResult(
            name="GET /api/templates",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            data=data,
        )
    except Exception as e:
        return TestResult(
            name="GET /api/templates",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_list_templates_filtered() -> TestResult:
    """Test GET /api/templates with segment filter"""
    try:
        resp, elapsed = client.timed_get("/api/templates?segment=A&type=SCR")
        data = resp.json() if resp.text else {}

        passed = resp.status_code == 200 and data.get("success") is True

        return TestResult(
            name="GET /api/templates?segment=A&type=SCR",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            data=data,
        )
    except Exception as e:
        return TestResult(
            name="GET /api/templates?segment=A",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_get_template(template_id: int = 1) -> TestResult:
    """Test GET /api/templates/{id}"""
    try:
        resp, elapsed = client.timed_get(f"/api/templates/{template_id}")
        data = resp.json() if resp.text else {}

        passed = resp.status_code == 200 and data.get("success") is True

        return TestResult(
            name=f"GET /api/templates/{template_id}",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            data=data,
        )
    except Exception as e:
        return TestResult(
            name=f"GET /api/templates/{template_id}",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_get_template_full(template_id: int = 1) -> TestResult:
    """Test GET /api/templates/{id}/full (complex join)"""
    try:
        resp, elapsed = client.timed_get(f"/api/templates/{template_id}/full")
        data = resp.json() if resp.text else {}

        passed = (
            resp.status_code == 200
            and data.get("success") is True
            and "days" in data.get("template", {})
        )

        return TestResult(
            name=f"GET /api/templates/{template_id}/full",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            message="" if passed else "Expected nested days/meals structure",
            data=data,
        )
    except Exception as e:
        return TestResult(
            name=f"GET /api/templates/{template_id}/full",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_create_template() -> TestResult:
    """Test POST /api/templates"""
    payload = {
        "code": f"TEST-{int(time.time())}",
        "name": f"Test Template {int(time.time())}",
        "description": "Test template for API testing",
        "segment": "A",
        "type": "SCR",
        "duration_days": 30,
        "calories_target": 1500,
    }

    try:
        resp, elapsed = client.timed_post("/api/templates", json=payload)
        data = resp.json() if resp.text else {}

        passed = resp.status_code == 201 and data.get("success") is True

        return TestResult(
            name="POST /api/templates",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            message="" if passed else f"Create failed: {data}",
            data=data,
        )
    except Exception as e:
        return TestResult(
            name="POST /api/templates",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_benchmark_bulk_insert() -> TestResult:
    """Test POST /api/benchmark/bulk-insert"""
    items = [
        {
            "food_item_id": random.randint(1, 50),
            "portion_grams_min": random.randint(50, 100),
            "portion_grams_max": random.randint(150, 200),
            "portion_description": f"{random.randint(1, 3)} serving(s)",
            "is_optional": random.choice([True, False]),
            "sort_order": i,
        }
        for i in range(50)
    ]

    payload = {
        "meal_id": 1,
        "items": items,
    }

    try:
        resp, elapsed = client.timed_post("/api/benchmark/bulk-insert", json=payload)
        data = resp.json() if resp.text else {}

        passed = (
            resp.status_code == 201
            and data.get("success") is True
            and data.get("inserted_count", 0) > 0
        )

        return TestResult(
            name="POST /api/benchmark/bulk-insert (50 items)",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            message="" if passed else f"Bulk insert failed: {data}",
            data=data,
        )
    except Exception as e:
        return TestResult(
            name="POST /api/benchmark/bulk-insert",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


def test_benchmark_complex_query() -> TestResult:
    """Test GET /api/benchmark/complex-query"""
    try:
        resp, elapsed = client.timed_get("/api/benchmark/complex-query")
        data = resp.json() if resp.text else {}

        passed = (
            resp.status_code == 200
            and data.get("success") is True
        )

        return TestResult(
            name="GET /api/benchmark/complex-query",
            passed=passed,
            status_code=resp.status_code,
            response_time_ms=elapsed,
            data=data,
        )
    except Exception as e:
        return TestResult(
            name="GET /api/benchmark/complex-query",
            passed=False,
            status_code=0,
            response_time_ms=0,
            message=str(e),
        )


# =============================================================================
# BENCHMARK FUNCTIONS
# =============================================================================

def run_benchmark(
    name: str,
    request_func,
    duration: int = None,
    connections: int = None,
) -> BenchmarkResult:
    """Run a benchmark test with concurrent requests"""
    duration = duration or config.benchmark_duration
    connections = connections or config.benchmark_connections

    latencies: List[float] = []
    errors = 0
    start_time = time.time()

    def make_request():
        nonlocal errors
        try:
            start = time.perf_counter()
            resp = request_func()
            elapsed = (time.perf_counter() - start) * 1000

            if resp.status_code >= 400:
                errors += 1

            return elapsed
        except Exception:
            errors += 1
            return None

    print(f"  Running benchmark: {name} ({duration}s, {connections} connections)...")

    with ThreadPoolExecutor(max_workers=connections) as executor:
        while time.time() - start_time < duration:
            futures = [executor.submit(make_request) for _ in range(connections)]
            for future in as_completed(futures):
                result = future.result()
                if result is not None:
                    latencies.append(result)

    total_time = time.time() - start_time
    total_requests = len(latencies) + errors

    if latencies:
        sorted_latencies = sorted(latencies)
        p50_idx = int(len(sorted_latencies) * 0.50)
        p95_idx = int(len(sorted_latencies) * 0.95)
        p99_idx = int(len(sorted_latencies) * 0.99)

        result = BenchmarkResult(
            test_name=name,
            requests_total=total_requests,
            requests_success=len(latencies),
            requests_failed=errors,
            requests_per_second=total_requests / total_time,
            avg_latency_ms=statistics.mean(latencies),
            p50_latency_ms=sorted_latencies[p50_idx] if p50_idx < len(sorted_latencies) else 0,
            p95_latency_ms=sorted_latencies[p95_idx] if p95_idx < len(sorted_latencies) else 0,
            p99_latency_ms=sorted_latencies[p99_idx] if p99_idx < len(sorted_latencies) else 0,
            min_latency_ms=min(latencies),
            max_latency_ms=max(latencies),
            error_rate=errors / total_requests if total_requests > 0 else 0,
        )
    else:
        result = BenchmarkResult(
            test_name=name,
            requests_total=total_requests,
            requests_success=0,
            requests_failed=errors,
            requests_per_second=0,
            avg_latency_ms=0,
            p50_latency_ms=0,
            p95_latency_ms=0,
            p99_latency_ms=0,
            min_latency_ms=0,
            max_latency_ms=0,
            error_rate=1.0,
        )

    print(f"    → {result.requests_per_second:.1f} req/s, "
          f"avg: {result.avg_latency_ms:.1f}ms, "
          f"p95: {result.p95_latency_ms:.1f}ms")

    return result


def run_benchmarks():
    """Run all benchmark tests"""
    print("\n" + "=" * 60)
    print("RUNNING BENCHMARKS")
    print("=" * 60)

    # 1. Simple CRUD - GET /api/categories
    tracker.add_benchmark(run_benchmark(
        "GET /api/categories",
        lambda: client.get("/api/categories"),
    ))

    # 2. Paginated List - GET /api/foods
    tracker.add_benchmark(run_benchmark(
        "GET /api/foods (paginated)",
        lambda: client.get(f"/api/foods?page={random.randint(1, 10)}&limit=20"),
    ))

    # 3. Filtered List - GET /api/foods with category
    tracker.add_benchmark(run_benchmark(
        "GET /api/foods (filtered)",
        lambda: client.get(f"/api/foods?category_id={random.randint(1, 5)}&page=1&limit=20"),
    ))

    # 4. Complex Join - GET /api/templates/{id}/full
    tracker.add_benchmark(run_benchmark(
        "GET /api/templates/{id}/full",
        lambda: client.get(f"/api/templates/{random.randint(1, 3)}/full"),
    ))


# =============================================================================
# DATABASE VERIFICATION
# =============================================================================

def verify_database_connection():
    """Verify MySQL database connection and tables"""
    try:
        import mysql.connector
    except ImportError:
        print("Warning: mysql-connector-python not installed")
        print("Run: pip install mysql-connector-python")
        return False

    print("\n" + "=" * 60)
    print("DATABASE VERIFICATION")
    print("=" * 60)

    try:
        conn = mysql.connector.connect(
            host=config.db_host,
            port=config.db_port,
            user=config.db_user,
            password=config.db_password,
            database=config.db_name,
        )

        cursor = conn.cursor()

        print(f"\n✓ Connected to MySQL: {config.db_host}:{config.db_port}/{config.db_name}")

        # Check tables
        tables = [
            "food_categories",
            "food_items",
            "diet_templates",
            "diet_days",
            "diet_meals",
            "diet_meal_items",
        ]

        print("\nTable Status:")
        for table in tables:
            try:
                cursor.execute(f"SELECT COUNT(*) FROM {table}")
                count = cursor.fetchone()[0]
                print(f"  ✓ {table}: {count} rows")
            except mysql.connector.Error as e:
                print(f"  ✗ {table}: {e}")

        cursor.close()
        conn.close()

        return True

    except mysql.connector.Error as e:
        print(f"\n✗ Database connection failed: {e}")
        return False


# =============================================================================
# MAIN TEST RUNNER
# =============================================================================

def run_all_tests():
    """Run all API tests"""
    print("\n" + "=" * 60)
    print("DIET API TEST SUITE")
    print("=" * 60)
    print(f"Target: {config.base_url}")
    print(f"Started: {datetime.now().isoformat()}")

    # Health Check
    print("\n[Health Check]")
    tracker.add_result(test_health_check())

    # Categories Tests
    print("\n[Categories API]")
    tracker.add_result(test_list_categories())
    tracker.add_result(test_get_category(1))
    tracker.add_result(test_create_category())

    # Foods Tests
    print("\n[Foods API]")
    tracker.add_result(test_list_foods())
    tracker.add_result(test_list_foods_filtered())
    tracker.add_result(test_list_foods_search())
    tracker.add_result(test_get_food(1))
    tracker.add_result(test_create_food())

    # Templates Tests
    print("\n[Templates API]")
    tracker.add_result(test_list_templates())
    tracker.add_result(test_list_templates_filtered())
    tracker.add_result(test_get_template(1))
    tracker.add_result(test_get_template_full(1))
    tracker.add_result(test_create_template())

    # Benchmark Endpoints Tests
    print("\n[Benchmark Endpoints]")
    tracker.add_result(test_benchmark_complex_query())
    tracker.add_result(test_benchmark_bulk_insert())


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description="Diet API Test Suite")
    parser.add_argument(
        "--url",
        default=config.base_url,
        help=f"API base URL (default: {config.base_url})",
    )
    parser.add_argument(
        "--benchmark",
        action="store_true",
        help="Run benchmark tests after API tests",
    )
    parser.add_argument(
        "--verify-db",
        action="store_true",
        help="Verify database connection",
    )
    parser.add_argument(
        "--benchmark-only",
        action="store_true",
        help="Only run benchmarks (skip API tests)",
    )
    parser.add_argument(
        "--duration",
        type=int,
        default=config.benchmark_duration,
        help=f"Benchmark duration in seconds (default: {config.benchmark_duration})",
    )
    parser.add_argument(
        "--connections",
        type=int,
        default=config.benchmark_connections,
        help=f"Concurrent connections (default: {config.benchmark_connections})",
    )

    args = parser.parse_args()

    # Update config
    config.base_url = args.url
    config.benchmark_duration = args.duration
    config.benchmark_connections = args.connections
    client.base_url = args.url

    # Run tests
    if args.verify_db:
        verify_database_connection()

    if not args.benchmark_only:
        run_all_tests()

    if args.benchmark or args.benchmark_only:
        run_benchmarks()

    # Print summary
    tracker.print_summary()

    # Exit with proper code
    summary = tracker.summary()
    sys.exit(0 if summary["failed"] == 0 else 1)


if __name__ == "__main__":
    main()
