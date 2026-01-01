import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const latency = new Trend('latency');

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';

export const options = {
    stages: [
        { duration: '10s', target: 50 },   // Ramp up
        { duration: '30s', target: 50 },   // Steady state
        { duration: '10s', target: 0 },    // Ramp down
    ],
    thresholds: {
        http_req_duration: ['p(95)<500'],
        errors: ['rate<0.01'],
    },
};

export default function () {
    // GET all categories
    const res = http.get(`${BASE_URL}/api/categories`);

    check(res, {
        'status is 200': (r) => r.status === 200,
        'has success': (r) => JSON.parse(r.body).success === true,
        'has categories': (r) => Array.isArray(JSON.parse(r.body).categories),
    });

    errorRate.add(res.status !== 200);
    latency.add(res.timings.duration);

    sleep(0.1);
}

export function handleSummary(data) {
    return {
        'stdout': JSON.stringify({
            test: 'categories',
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
