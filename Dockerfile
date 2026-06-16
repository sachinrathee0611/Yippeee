# Use the lightweight Nginx Alpine base image
FROM nginx:alpine

# Clean up any default static files template provided by Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copy local application code into the Nginx web root directory
COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY app.js /usr/share/nginx/html/

# Expose port 80 to allow incoming web traffic to the container
EXPOSE 80

# Start Nginx in the foreground so the Docker container remains active
CMD ["nginx", "-g", "daemon off;"]