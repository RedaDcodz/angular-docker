# Stage 1: Build the Angular app
FROM node:16 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to install dependencies
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy the rest of the app files
COPY . .

# Build the Angular app for production
RUN npm run build --prod

# Stage 2: Run unit tests (test stage)
FROM node:16 AS test

# Set the working directory inside the container
WORKDIR /app

# Copy the app files and dependencies from the build stage
COPY --from=build /app /app

# Install testing dependencies (Jest, Karma, etc.)
RUN npm install --only=dev

# Install Chrome for Karma tests
RUN apt-get update && apt-get install -y wget curl unzip \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
    && apt-get update && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Set Chrome binary path
ENV CHROME_BIN=/usr/bin/google-chrome

# Run the tests (e.g., with Karma or Jest)
RUN npm test

# Stage 3: Serve the app with Nginx (prod stage)
FROM nginx:alpine AS prod

# Copy the built app from the build container to Nginx
COPY --from=build /app/dist/my-angular-app /usr/share/nginx/html

# Expose port 80 for the app
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
