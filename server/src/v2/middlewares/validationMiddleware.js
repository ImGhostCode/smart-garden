// Validation middleware factory
const createValidationMiddleware = (schema, source = 'body') => {
    return (req, res, next) => {
        let dataToValidate;

        switch (source) {
            case 'body':
                dataToValidate = req.body;
                break;
            case 'params':
                dataToValidate = req.params;
                break;
            case 'query':
                dataToValidate = req.query;
                break;
            default:
                return res.status(500).json({ error: 'Invalid validation source' });
        }

        const { error, value } = schema.validate(dataToValidate, {
            abortEarly: false, // Return all errors, not just the first one
            stripUnknown: true, // Remove unknown fields
            convert: true // Convert strings to numbers/booleans when appropriate
        });

        if (error) {
            const errorMessage = error.details.map(detail => detail.message).join(', ');
            return res.status(400).json({
                status: 'error',
                code: 400,
                message: errorMessage,
                errors: error.details
            });
        }

        // Replace the original data with the validated/converted data
        switch (source) {
            case 'body':
                req.body = value;
                break;
            case 'params':
                req.params = value;
                break;
            case 'query':
                req.query = value;
                break;
        }

        next();
    };
};

// Convenience middleware creators
const validateBody = (schema) => createValidationMiddleware(schema, 'body');
const validateParams = (schema) => createValidationMiddleware(schema, 'params');
const validateQuery = (schema) => createValidationMiddleware(schema, 'query');

module.exports = {
    validateBody,
    validateParams,
    validateQuery
};