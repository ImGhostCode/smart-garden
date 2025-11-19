function errorHandler(err, req, res, next) {
    const statusCode = err.statusCode || 500;

    res.status(statusCode).json({
        status: 'error',
        code: statusCode,
        message: err.message || 'Internal Server Error',
        errors: err.errors || [],
        meta: {
            timestamp: new Date().toISOString(),
            request_id: req.headers['x-request-id'] || 'N/A'
        }
    });
}

module.exports = errorHandler;
