#!/bin/bash
# Diet API Benchmark Runner for FastAPI
# Usage: ./run-benchmark.sh [base_url]

set -e

# Configuration
BASE_URL=${1:-http://localhost:8000}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K6_DIR="$SCRIPT_DIR/k6"
RESULTS_DIR="$SCRIPT_DIR/results"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Create results directory with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULT_DIR="$RESULTS_DIR/$TIMESTAMP"
mkdir -p "$RESULT_DIR"

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Diet API Benchmark Suite (FastAPI)${NC}"
echo -e "${GREEN}============================================${NC}"
echo -e "Target: ${YELLOW}$BASE_URL${NC}"
echo -e "Results: ${YELLOW}$RESULT_DIR${NC}"
echo ""

# Check if k6 is installed
if ! command -v k6 &> /dev/null; then
    echo -e "${RED}Error: k6 is not installed${NC}"
    echo "Install with:"
    echo "  macOS: brew install k6"
    echo "  Linux: sudo snap install k6"
    echo "  Docker: docker run -i grafana/k6 run -"
    exit 1
fi

# Wait for service to be ready
echo -e "${YELLOW}Waiting for service...${NC}"
max_attempts=30
attempt=0
until curl -s "$BASE_URL/health" > /dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ $attempt -ge $max_attempts ]; then
        echo -e "${RED}Service not responding after $max_attempts attempts${NC}"
        exit 1
    fi
    echo "  Attempt $attempt/$max_attempts..."
    sleep 1
done
echo -e "${GREEN}Service is ready!${NC}"
echo ""

# ============================================
# Test 1: Simple CRUD - GET /api/categories
# ============================================
echo -e "${GREEN}[1/4] Testing: GET /api/categories (simple read)${NC}"
k6 run \
    --out json="$RESULT_DIR/categories.json" \
    -e BASE_URL=$BASE_URL \
    "$K6_DIR/categories.js" 2>&1 | tee "$RESULT_DIR/categories.log"
echo ""

# ============================================
# Test 2: Paginated List - GET /api/foods
# ============================================
echo -e "${GREEN}[2/4] Testing: GET /api/foods (list with filters)${NC}"
k6 run \
    --out json="$RESULT_DIR/foods-list.json" \
    -e BASE_URL=$BASE_URL \
    "$K6_DIR/foods-list.js" 2>&1 | tee "$RESULT_DIR/foods-list.log"
echo ""

# ============================================
# Test 3: Complex Join - GET /api/templates/{id}/full
# ============================================
echo -e "${GREEN}[3/4] Testing: GET /api/templates/{id}/full (complex join)${NC}"
k6 run \
    --out json="$RESULT_DIR/template-full.json" \
    -e BASE_URL=$BASE_URL \
    "$K6_DIR/template-full.js" 2>&1 | tee "$RESULT_DIR/template-full.log"
echo ""

# ============================================
# Test 4: Bulk Insert - POST /api/benchmark/bulk-insert
# ============================================
echo -e "${GREEN}[4/4] Testing: POST /api/benchmark/bulk-insert (write performance)${NC}"
k6 run \
    --out json="$RESULT_DIR/bulk-insert.json" \
    -e BASE_URL=$BASE_URL \
    "$K6_DIR/bulk-insert.js" 2>&1 | tee "$RESULT_DIR/bulk-insert.log"
echo ""

# ============================================
# Generate Summary
# ============================================
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Benchmark Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Results saved to: $RESULT_DIR"
echo ""
echo "Files:"
ls -la "$RESULT_DIR"
