# Caching System Documentation

## Overview

This application implements an in-memory caching layer using `node-cache` to reduce database load and improve response times. The caching system follows the **Cache-Aside (Lazy Loading)** pattern.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       Request Flow                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   Client Request                                             │
│         │                                                    │
│         ▼                                                    │
│   ┌─────────────┐                                           │
│   │  Controller │                                           │
│   └──────┬──────┘                                           │
│          │                                                   │
│          ▼                                                   │
│   ┌──────────────────┐      ┌─────────────┐                │
│   │ cachedDatabase.js│ ───▶ │   cache.js  │                │
│   └────────┬─────────┘      └──────┬──────┘                │
│            │                       │                         │
│            │    Cache Miss         │ Cache Hit               │
│            ▼                       │                         │
│   ┌─────────────┐                 │                         │
│   │ database.js │                 │                         │
│   └──────┬──────┘                 │                         │
│          │                        │                         │
│          ▼                        │                         │
│   ┌─────────────┐                 │                         │
│   │    MySQL    │                 │                         │
│   └─────────────┘                 │                         │
│          │                        │                         │
│          └────────────────────────┘                         │
│                      │                                       │
│                      ▼                                       │
│              Response to Client                              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## File Structure

```
src/
├── utils/
│   └── cache.js              # Core cache utility (node-cache wrapper)
├── middleware/
│   └── cache.js              # Route-level caching middleware (optional)
├── models/
│   ├── database.js           # Original database operations
│   └── cachedDatabase.js     # Cached wrapper (decorator pattern)
├── routes/
│   └── api.js                # Cache management API endpoints
└── views/
    └── admin/
        └── cache.ejs         # Cache management dashboard
```

## Configuration

Cache settings are defined in `src/utils/cache.js`:

```javascript
const CONFIG = {
    DEFAULT_TTL: 300,      // 5 minutes default TTL
    CHECK_PERIOD: 60,      // Check for expired keys every 60 seconds
    MAX_KEYS: 5000,        // Maximum cached keys
    USE_CLONES: true,      // Clone values for safety
    DELETE_ON_EXPIRE: true // Auto-delete expired keys
};
```

### TTL Presets

| Constant | Duration | Use Case |
|----------|----------|----------|
| `TTL.SHORT` | 1 min | Frequently changing data |
| `TTL.MEDIUM` | 5 min | Default |
| `TTL.LONG` | 15 min | Stable data |
| `TTL.VERY_LONG` | 1 hour | Rarely changing data |
| `TTL.FOOD_CATEGORIES` | 15 min | Food categories |
| `TTL.FOOD_ITEMS` | 5 min | Food items |
| `TTL.DIET_TEMPLATES` | 10 min | Diet templates |
| `TTL.DIET_TEMPLATE_FULL` | 5 min | Full template with meals |

## Cached Entities

### Currently Cached

| Entity | Methods Cached | TTL | Invalidation Trigger |
|--------|---------------|-----|---------------------|
| FoodCategory | `getAll()`, `findById()` | 15 min | create, update, delete |
| FoodItem | `getAll()`, `findById()`, `findByCategory()` | 5 min | create, update, delete |
| DietTemplate | `getAll()`, `findById()`, `findByCode()`, `getFullTemplate()` | 10 min | create, update, archive |
| DietTag | `getAll()`, `getByCategory()` | 15 min | create, update, delete |

### Not Cached (Pass-through)

These entities are passed through without caching due to their real-time nature:

- `User` - Security sensitive
- `Patient` - Frequently updated
- `MedicalRecord` - Real-time medical data
- `MedicalVisit` - Real-time data
- `Appointment` - Time-sensitive
- `PatientDiet` - Active diet tracking

## Usage

### Using Cached Database in Controllers

```javascript
// Import the cached database instead of the original
const { FoodCategory, DietTemplate } = require('../models/cachedDatabase');

// Use exactly like the original - caching is transparent
const categories = await FoodCategory.getAll();
const template = await DietTemplate.getFullTemplate(id);
```

### Cache-Aside Pattern

```javascript
const cache = require('../utils/cache');

// Manual cache-aside pattern
const data = await cache.getOrSet(
    'my-cache-key',
    async () => await expensiveQuery(),
    300 // TTL in seconds
);
```

### Namespaced Keys

```javascript
const { makeKey, NAMESPACE } = require('../utils/cache');

// Creates key: "food:categories:all"
const key = makeKey(NAMESPACE.FOOD, 'categories:all');
```

## Cache Invalidation

Cache is automatically invalidated when data is modified:

```javascript
// In cachedDatabase.js - automatic invalidation on update
update: async (id, data) => {
    const result = await db.FoodCategory.update(id, data);

    if (result.success) {
        cache.del(makeKey(NAMESPACE.FOOD, `category:${id}`));
        cache.del(makeKey(NAMESPACE.FOOD, 'categories:all'));
    }

    return result;
}
```

### Manual Invalidation

```javascript
const cache = require('../utils/cache');

// Delete specific key
cache.del('food:categories:all');

// Invalidate by namespace
cache.invalidateNamespace('food');

// Invalidate by pattern
cache.invalidatePattern('diet:template');

// Flush everything
cache.flush();
```

## API Endpoints

All endpoints require admin authentication.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check (public) |
| GET | `/api/cache/stats` | Get cache statistics |
| POST | `/api/cache/flush` | Flush entire cache |
| POST | `/api/cache/flush/:namespace` | Flush specific namespace |

### Example Response: `/api/cache/stats`

```json
{
    "success": true,
    "data": {
        "hits": 150,
        "misses": 23,
        "hitRate": "86.71%",
        "sets": 45,
        "deletes": 12,
        "keys": 28,
        "uptime": 3600,
        "keysList": ["food:categories:all", "diet:templates:list:20:0"]
    }
}
```

## Admin Dashboard

Access the cache management dashboard at:

```
/admin/cache
```

Features:
- Real-time cache statistics
- Hit rate monitoring
- Namespace-based cache flushing
- Full cache flush
- Cached keys list (development mode only)

## Route-Level Caching (Optional)

For caching entire route responses:

```javascript
const { cacheResponse } = require('../middleware/cache');

// Cache this route's response for 5 minutes
router.get('/api/categories', cacheResponse(300), getCategories);

// With custom key generator
router.get('/api/items',
    cacheResponse(300, req => `items:page:${req.query.page}`),
    getItems
);
```

## Best Practices

### Do

- Cache read-heavy, rarely-changing data
- Use appropriate TTLs based on data volatility
- Invalidate cache on data mutations
- Monitor hit rates regularly
- Use namespaces for organized cache management

### Don't

- Cache user-specific or sensitive data
- Cache real-time data (appointments, active sessions)
- Set TTLs longer than necessary
- Forget to invalidate on updates
- Cache paginated data without page parameters in key

## Monitoring

### Key Metrics to Watch

| Metric | Healthy Range | Action if Outside |
|--------|---------------|-------------------|
| Hit Rate | > 80% | Review TTLs, check invalidation patterns |
| Keys Count | < MAX_KEYS | Increase MAX_KEYS or reduce TTLs |
| Memory Usage | < 100MB | Reduce cached data or MAX_KEYS |

### Logging

Cache events are logged via Winston:

```
[debug] Cache HIT: food:categories:all
[debug] Cache MISS: diet:template:5
[info] Cache invalidated: food categories
[info] Cache flushed by user 1
```

## Performance Impact Estimate

### What's Cached vs Not Cached

| Cached (Read-Heavy) | Not Cached (Real-Time) |
|---------------------|------------------------|
| FoodCategory | Patient |
| FoodItem | MedicalRecord |
| DietTemplate | MedicalVisit |
| DietTag | Appointment |
| | User (auth) |

### Realistic Estimates by Scenario

**Scenario: Admin browsing diet templates**
```
Without cache:  10 page views = 10 DB queries
With cache:     10 page views = 1 DB query + 9 cache hits
Reduction:      90%
```

**Scenario: Staff assigning diets to patients**
```
Load food categories:     1 query → cached (90% reduction)
Load food items:          1 query → cached (85% reduction)
Load diet templates:      1 query → cached (90% reduction)
Load patient data:        1 query → NOT cached (0% reduction)
Save assignment:          1 query → NOT cached (0% reduction)

Overall reduction:        ~60%
```

**Scenario: Doctor viewing patient records**
```
Patient data:             NOT cached
Medical records:          NOT cached
Visits:                   NOT cached
Patient diet (current):   NOT cached

Overall reduction:        ~0% (correct - real-time data)
```

### Overall Estimate

| Use Case | Traffic % | Cache Reduction | Weighted |
|----------|-----------|-----------------|----------|
| Diet/Food browsing | 25% | 85-90% | 22% |
| Patient management | 50% | 0-10% | 3% |
| Template editing | 15% | 70% | 10% |
| Admin/Auth | 10% | 5% | 0.5% |

**Estimated Total DB Reduction: 30-40%**

### Where It Helps Most

```
High Impact:
├── GET /foods/categories      → 90% fewer queries
├── GET /foods/items           → 85% fewer queries
├── GET /diets/templates       → 90% fewer queries
├── GET /diets/templates/:id   → 85% fewer queries (full template)
└── Diet assignment dropdowns  → 80% fewer queries

Low/No Impact:
├── Patient CRUD               → 0% (not cached)
├── Medical records            → 0% (not cached)
├── Appointments               → 0% (not cached)
└── Authentication             → 0% (not cached)
```

### Real Numbers Example

Assuming 1000 requests/hour:

| Without Cache | With Cache |
|---------------|------------|
| ~1000 DB queries | ~650 DB queries |
| MySQL connections busy | More idle connections |
| Avg response: 50-100ms | Avg response: 5-15ms (cached) |

### How to Measure Actual Impact

```javascript
// In your app after running for a while
const stats = cache.getStats();
console.log(`
  Hit Rate: ${stats.hitRate}
  DB Queries Saved: ~${stats.hits}
  Cache Misses (DB hits): ${stats.misses}
`);
```

### Summary

| Metric | Estimate |
|--------|----------|
| DB query reduction | **30-40%** |
| Response time improvement | **60-80%** for cached routes |
| Memory cost | **~10-50MB** |
| Best ROI | Diet/Food browsing pages |

The cache is most valuable for the diet system (templates, foods, categories) which are read-heavy and rarely change. Patient data correctly remains uncached for real-time accuracy.

## Scaling Considerations

### Current Setup (Single Instance)

- In-memory cache is sufficient
- No additional infrastructure needed
- Cache is lost on restart

### When to Migrate to Redis

Consider Redis when:
- Running multiple Node.js instances (PM2 cluster mode)
- Cache size exceeds 200MB
- Need cache persistence across restarts
- Sharing cache between services
- Implementing real-time features (pub/sub)

### Migration Path

1. Install Redis: `npm install ioredis`
2. Create Redis adapter implementing same interface
3. Update `cache.js` to use Redis client
4. No changes needed in `cachedDatabase.js` or controllers

## Troubleshooting

### Cache Not Working

1. Verify import: `require('../models/cachedDatabase')`
2. Check cache stats at `/admin/cache`
3. Review logs for cache hits/misses

### Stale Data

1. Check TTL settings
2. Verify invalidation on mutations
3. Manually flush via API or dashboard

### High Memory Usage

1. Reduce `MAX_KEYS` in config
2. Lower TTLs for large datasets
3. Review what's being cached

## Future Improvements

- [ ] Add cache warming on startup
- [ ] Implement cache compression for large objects
- [ ] Add per-key TTL monitoring
- [ ] Redis adapter for horizontal scaling
- [ ] Cache analytics and reporting
