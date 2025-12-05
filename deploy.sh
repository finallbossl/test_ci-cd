#!/bin/bash

# Script để deploy production manually
# Usage: ./deploy.sh

set -e

echo "🚀 Starting deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="backend-api"
CONTAINER_NAME="backend-api"
PORT="8080"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Build the image
echo -e "${YELLOW}📦 Building Docker image...${NC}"
docker build -t $IMAGE_NAME ./Backend

# Stop and remove old container if exists
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo -e "${YELLOW}🛑 Stopping old container...${NC}"
    docker stop $CONTAINER_NAME || true
    docker rm $CONTAINER_NAME || true
fi

# Run new container
echo -e "${YELLOW}▶️  Starting new container...${NC}"
docker run -d \
  --name $CONTAINER_NAME \
  --restart unless-stopped \
  -p $PORT:8080 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e ConnectionStrings__DefaultConnection="${DB_CONNECTION_STRING:-Server=localhost;Database=DataTest;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;}" \
  $IMAGE_NAME

# Wait for container to be healthy
echo -e "${YELLOW}⏳ Waiting for container to be ready...${NC}"
sleep 5

# Health check
if curl -f http://localhost:$PORT/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo -e "${GREEN}🌐 API is running at http://localhost:$PORT${NC}"
    echo -e "${GREEN}🏥 Health check: http://localhost:$PORT/health${NC}"
else
    echo -e "${RED}❌ Health check failed. Check logs with: docker logs $CONTAINER_NAME${NC}"
    exit 1
fi

# Show container status
echo -e "\n${YELLOW}📊 Container status:${NC}"
docker ps -f name=$CONTAINER_NAME

echo -e "\n${GREEN}✨ Done!${NC}"

