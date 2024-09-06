FROM ruby:3.3.1-alpine as base

WORKDIR /rails

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle"

# Install dependencies
RUN apk add --no-cache \
    build-base \
    libxml2-dev \
    libxslt-dev \
    libffi-dev \
    postgresql-dev
RUN apk add --no-cache musl-dev g++ make


RUN apk update && \
    apk add --no-cache build-base libxml2-dev libxslt-dev zlib-dev

# Set bundle config for without development and test environments
RUN bundle config set without 'development test'

# Install application gems
COPY Gemfile Gemfile.lock ./
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

# Run as non-root user
RUN adduser -D rails
USER rails

EXPOSE 3000

# Start the Rails server
CMD ["./bin/rails", "server"]
