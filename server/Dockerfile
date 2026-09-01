# Node.js 20 LTS Alpine Image
FROM node:20-alpine

# Working directory inside container
WORKDIR /app

# Copy package definition files
COPY package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Expose backend port
EXPOSE 5000

# Default environment
ENV NODE_ENV=production

# Start command
CMD ["node", "src/server.js"]
