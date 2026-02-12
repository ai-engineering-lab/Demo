# Use Red Hat UBI 9 minimal (hardened base image)
FROM registry.access.redhat.com/ubi9/ubi-minimal

# Install nginx
RUN microdnf install -y nginx \
    && microdnf clean all

# Create non-root user
RUN useradd -r -u 1001 -g root nginxuser

# Create website content
RUN echo "<!DOCTYPE html>" > /usr/share/nginx/html/index.html && \
    echo "<html><head><title>Hello</title></head>" >> /usr/share/nginx/html/index.html && \
    echo "<body><h1>Hello There!</h1></body></html>" >> /usr/share/nginx/html/index.html

# Adjust permissions for non-root execution
RUN chown -R 1001:0 /usr/share/nginx/html \
    && chown -R 1001:0 /var/lib/nginx \
    && chown -R 1001:0 /var/log/nginx \
    && chmod -R g=u /usr/share/nginx/html /var/lib/nginx /var/log/nginx

# Expose port 8080 (non-privileged port)
EXPOSE 8080

# Modify nginx to listen on 8080 instead of 80
RUN sed -i 's/listen       80;/listen       8080;/g' /etc/nginx/nginx.conf

# Switch to non-root user
USER 1001

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
