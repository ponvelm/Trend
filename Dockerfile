# Use official Nginx image
FROM nginx:alpine

# Set working directory in container
WORKDIR /usr/share/nginx/html

# Copy the built frontend files
COPY dist/ .

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
