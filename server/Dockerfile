# Use the official Node.js runtime as the base image
FROM node:24-alpine

WORKDIR /usr/src/app

COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S smart-garden -u 1001

# Copy the rest of the application code
COPY --chown=smart-garden:nodejs . .

# Create logs directory if your app writes logs
RUN mkdir -p /usr/src/app/logs && \
    chown -R smart-garden:nodejs /usr/src/app/logs

# Switch to non-root user
USER smart-garden

# Expose the port the app runs on
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Command to run the application
CMD ["npm", "start"]
