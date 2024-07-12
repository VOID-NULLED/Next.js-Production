# Stage 1: Build the Next.js app
FROM node:latest AS builder

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json to the container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

# Build the Next.js app for production
RUN npm run build

# Stage 2: Nginx to serve static files
FROM nginx:alpine AS nginx

# Copy the build output to Nginx html directory
COPY --from=builder /app/out /usr/share/nginx/html

# Copy custom Nginx configuration file (optional)
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 8080

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

# Stage 3: Production image
FROM node:latest

# Set the working directory
WORKDIR /app

# Copy the built app from the builder stage
COPY --from=builder /app ./

# Install only production dependencies
RUN npm install --production

# Expose port 3000
EXPOSE 3000

# Start the Next.js app in production mode
CMD ["npm", "run", "start"]
