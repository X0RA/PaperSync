FROM python:latest

# Install Node.js, npm, and other necessary dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Create and set working directory
WORKDIR /app

# Ensure the repo directory exists and has correct permissions
RUN mkdir -p /app/repo && chown -R 1000:1000 /app/repo

# Copy the cache file into the repo directory
COPY cache /app/repo/cache

# Copy the startup script
COPY docker-startup.sh /app/
RUN chmod +x /app/docker-startup.sh

# Set the startup script as the entry point
ENTRYPOINT ["/app/docker-startup.sh"]