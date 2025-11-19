class ApiResponse {
    constructor(status, statusCode, message, data = {}, errors = {}, meta = {}) {
        this.status = status // success or error
        this.statusCode = statusCode;
        this.message = message;
        this.data = data;
        this.errors = errors;
        this.meta = {
            timestamp: new Date().toISOString(),
            ...meta
        }
    }
}

class ApiSuccess extends ApiResponse {
    constructor(statusCode = 200, message = 'Success', data = {}, meta = {}) {
        super('success', statusCode, message, data, [], meta);
    }
}

class ApiError extends ApiResponse {
    constructor(statusCode = 500, message = 'Internal Server Error', errors = {}, meta = {}) {
        super('error', statusCode, message, {}, errors, meta);
    }
}

module.exports = {
    ApiSuccess, ApiError
}
