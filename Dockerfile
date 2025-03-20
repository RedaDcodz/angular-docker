# Stage 1: Development environment
FROM node:16 AS dev

WORKDIR /app

# Copy package.json and package-lock.json to install dependencies
COPY package*.json ./

RUN npm install

# Copy the rest of the app files
COPY . .

# Expose Angular development server port
EXPOSE 4200

# Start the Angular app in development mode
CMD ["npm", "start", "--", "--host", "0.0.0.0", "--poll", "2000"]

