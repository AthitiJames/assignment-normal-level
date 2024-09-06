# Base image
FROM ruby:3.3.1-alpine as base

# Set working directory
WORKDIR /rails

# Set environment variables for production
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    SECRET_KEY_BASE="9df7ca72a5c15b477a13089721406ea97fe405811395d364582b446ede69fcab25460502b6246523b9d6ae5c22f833b403de7b7e070cb8d9985c4936ff7235fc"

# Install dependencies
RUN apk add --no-cache \
    build-base \
    libxml2-dev \
    libxslt-dev \
    libffi-dev \
    postgresql-dev \
    nodejs \
    yarn \
    tzdata \
    git \
    bash \
    curl   # ติดตั้ง bash และ curl ใน base stage

# Set bundle config to disable frozen mode
RUN bundle config set frozen false

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

USER root

# Install application gems
RUN bundle install --no-cache && \
    if [ -d "/usr/local/bundle/gems" ]; then \
        rm -rf /usr/local/bundle/cache/*.gem && \
        find /usr/local/bundle/gems/ -name "*.c" -delete && \
        find /usr/local/bundle/gems/ -name "*.o" -delete; \
    fi

# Copy application code
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# Final stage
FROM base

# Add non-root user
RUN adduser -D rails
USER rails

# Expose the Rails app port
EXPOSE 3000

# Start the Rails server
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
