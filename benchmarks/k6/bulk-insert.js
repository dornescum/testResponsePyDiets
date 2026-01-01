import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const latency = new Trend('latency');

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';

export const options = {
    stages: [
        { duration: '10s', target: 10 },
        { duration: '30s', target: 10 },
        { duration: '10s', target: 0 },
    ],
    thresholds: {
        http_req_duration: ['p(95)<3000'],  // Bulk insert can be slow
        errors: ['rate<0.05'],              // Allow higher error rate for writes
    },
};

// Generate random meal items
function generateMealItems(count) {
    const items = [];
    for (let i = 0; i < count; i++) {
        items.push({
            food_item_id: Math.floor(Math.random() * 49) + 1,
            portion_grams_min: 50 + Math.floor(Math.random() * 100),
            portion_grams_max: 150 + Math.floor(Math.random() * 100),
            portion_description: `${Math.floor(Math.random() * 3) + 1} serving(s)`,
            is_optional: Math.random() > 0.7,
            sort_order: i,
        });
    }
    return items;
}

export default function () {
    const payload = JSON.stringify({
        meal_id: Math.floor(Math.random() * 10) + 1,
        items: generateMealItems(50),  // 50 items per request
    });

    const params = {
        headers: {
            'Content-Type': 'application/json',
        },
    };

    const res = http.post(`${BASE_URL}/api/benchmark/bulk-insert`, payload, params);

    check(res, {
        'status is 201': (r) => r.status === 201,
        'has success': (r) => JSON.parse(r.body).success === true,
        'items inserted': (r) => JSON.parse(r.body).inserted_count > 0,
    });

    errorRate.add(res.status !== 201);
    latency.add(res.timings.duration);

    sleep(0.5);
}

export function handleSummary(data) {
    return {
        'stdout': JSON.stringify({
            test: 'bulk-insert',
            requests_total: data.metrics.http_reqs.values.count,
            requests_per_second: data.metrics.http_reqs.values.rate,
            avg_latency_ms: data.metrics.http_req_duration.values.avg,
            min_latency_ms: data.metrics.http_req_duration.values.min,
            max_latency_ms: data.metrics.http_req_duration.values.max,
            p50_latency_ms: data.metrics.http_req_duration.values['p(50)'],
            p90_latency_ms: data.metrics.http_req_duration.values['p(90)'],
            p95_latency_ms: data.metrics.http_req_duration.values['p(95)'],
            p99_latency_ms: data.metrics.http_req_duration.values['p(99)'],
            error_rate: data.metrics.errors?.values?.rate || 0,
        }, null, 2) + '\n',
    };
}
