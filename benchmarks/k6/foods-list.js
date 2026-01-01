import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const latency = new Trend('latency');

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';

export const options = {
    stages: [
        { duration: '10s', target: 50 },
        { duration: '30s', target: 50 },
        { duration: '10s', target: 0 },
    ],
    thresholds: {
        http_req_duration: ['p(95)<1000'],
        errors: ['rate<0.01'],
    },
};

export default function () {
    // Randomly select category filter
    const category = Math.floor(Math.random() * 10) + 1;
    const useFilter = Math.random() > 0.5;

    const url = useFilter
        ? `${BASE_URL}/api/foods?category_id=${category}`
        : `${BASE_URL}/api/foods`;

    const res = http.get(url);

    check(res, {
        'status is 200': (r) => r.status === 200,
        'has success': (r) => JSON.parse(r.body).success === true,
        'has foods array': (r) => Array.isArray(JSON.parse(r.body).foods),
    });

    errorRate.add(res.status !== 200);
    latency.add(res.timings.duration);

    sleep(0.1);
}

export function handleSummary(data) {
    return {
        'stdout': JSON.stringify({
            test: 'foods-list',
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
