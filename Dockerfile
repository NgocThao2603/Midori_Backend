# syntax=docker/dockerfile:1

### -------- BASE IMAGE --------
ARG RUBY_VERSION=3.2.2
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Cài các dependency chung cho cả build và runtime
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Biến môi trường chung
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

### -------- BUILD STAGE --------
FROM base AS build

# Cài thêm các dependency để build native extensions (và MeCab)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    default-libmysqlclient-dev \
    git \
    pkg-config \
    mecab \
    libmecab-dev \
    mecab-ipadic \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Copy Gemfile và cài gem
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy source code ứng dụng
COPY . .

# Precompile code trước để giảm startup time
RUN bundle exec bootsnap precompile app/ lib/

# Precompile asset nếu có
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

### -------- FINAL STAGE --------
FROM base

# ✅ Cài lại MeCab runtime trong final image
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    mecab \
    libmecab-dev \
    mecab-ipadic \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Copy từ build stage
COPY --from=build ${BUNDLE_PATH} ${BUNDLE_PATH}
COPY --from=build /rails /rails

# Cấu hình biến môi trường cho natto (nếu cần)
ENV MECAB_PATH=/usr/lib/x86_64-linux-gnu/libmecab.so

# Tạo user không phải root
RUN groupadd --system --gid 1000 rails && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash rails && \
    chown -R rails:rails /rails

USER rails

# Expose port Puma
EXPOSE 3000

# Default CMD
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
