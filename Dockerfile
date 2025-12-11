# Multi-stage build for security and size optimization
FROM ruby:2.7.7-slim as builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy gemfiles and install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.1.4 \
    && bundle config set --local without 'development test' \
    && bundle install --jobs $(nproc) --retry 3 \
    && bundle clean --force

# Production stage
FROM ruby:2.7.7-slim

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create non-root user
RUN groupadd -r appuser && useradd --no-log-init -r -g appuser appuser

WORKDIR /app

# Copy bundled gems from builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app/vendor /app/vendor

# Copy application code
COPY . .

# Set proper ownership and permissions
RUN chown -R appuser:appuser /app \
    && chmod -R 755 /app \
    && chmod +x /app/bin/* \
    && mkdir -p /app/tmp /app/log \
    && chown -R appuser:appuser /app/tmp /app/log

# Switch to non-root user
USER appuser

# Set environment variables
ENV RAILS_ENV=production
ENV RACK_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000

# Make startup script executable
RUN chmod +x bin/start-production

CMD ["bin/start-production"]