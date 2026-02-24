# Stage 1: Build Flutter Web App
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set working directory
WORKDIR /app

# Copy files and build in one layer to reduce image size
COPY pubspec.yaml pubspec.lock ./
COPY . .

# Single RUN command to minimize layers
RUN flutter pub get --no-precompile && \
    rm -rf /root/.pub-cache/hosted/pub.dartlang.org/*/*/example && \
    flutter build web \
    --release \
    --web-renderer canvaskit \
    --dart-define=dart.vm.product=true \
    --tree-shake-icons \
    --source-maps && \
    rm -rf /app/build/web/canvaskit/*.wasm.map && \
    find /app/build/web -name "*.map" -type f -delete

# Stage 2: Serve with Nginx (minimal)
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Add custom nginx config for SPA
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    gzip on; \
    gzip_vary on; \
    gzip_min_length 1024; \
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/javascript application/xml+rss application/json; \
}' > /etc/nginx/conf.d/default.conf

# Copy the built web app from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Use non-root user for security
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

USER nginx

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
