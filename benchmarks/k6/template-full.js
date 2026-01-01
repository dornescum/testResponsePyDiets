import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const latency = new Trend('latency');

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';

// Template IDs to test (assumes these exist from seed data)
const TEMPLATE_IDS = [1, 2, 3];

export const options = {
    stages: [
        { duration: '10s', target: 30 },
        { duration: '30s', target: 30 },
        { duration: '10s', target: 0 },
    ],
    thresholds: {
        http_req_duration: ['p(95)<2000'],  // Complex query, allow 2s
        errors: ['rate<0.01'],
    },
};

export default function () {
    // Randomly select a template
    const templateId = TEMPLATE_IDS[Math.floor(Math.random() * TEMPLATE_IDS.length)];

    const res = http.get(`${BASE_URL}/api/templates/${templateId}/full`);

    check(res, {
        'status is 200': (r) => r.status === 200,
        'has success': (r) => JSON.parse(r.body).success === true,
        'has template': (r) => JSON.parse(r.body).template !== undefined,
        'has days array': (r) => {
            const body = JSON.parse(r.body);
            return body.template && Array.isArray(body.template.days);
        },
    });

    errorRate.add(res.status !== 200);
    latency.add(res.timings.duration);

    sleep(0.2);
}

export function handleSummary(data) {
    return {
        'stdout': JSON.stringify({
            test: 'template-full',
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
