const client = require('prom-client');
const appConfig = require('../config/app.config');

// HTTP request duration metrics for Prometheus
const httpRequestDurationSeconds = new client.Histogram({
    name: `${appConfig.metric_prefix}http_request_duration_seconds`,
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['method', 'route', 'status_code'],
    buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
    registers: [client.register],
});

const metricMiddleware = (req, res, next) => {
    const endTimer = httpRequestDurationSeconds.startTimer();

    res.on('finish', () => {
        const routePath = req.route && req.route.path ? req.route.path : req.path;
        const baseUrl = req.baseUrl || '';
        const route = `${baseUrl}${routePath}` || 'unknown';

        endTimer({
            method: req.method,
            route,
            status_code: res.statusCode,
        });
    });

    next();
};
module.exports = metricMiddleware;