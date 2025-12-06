#!/bin/bash

# Script chính để restart backend với SQL Server Express trên host
# Usage: ./restart-backend.sh

set -e

echo "🔧 Restarting backend with SQL Server 2025 on host..."

# Connection string cho SQL Server 2025 trên host
DB_CONNECTION="Server=192.168.102.8,14330;Database=DataTest;User Id=sa;Password=28122003;TrustServerCertificate=True;"

# Get image name
IMAGE_NAME=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep 'ghcr.io/finallbossl/test_ci-cd' | head -n1)
if [ -z "$IMAGE_NAME" ]; then
    IMAGE_NAME="ghcr.io/finallbossl/test_ci-cd:latest"
    echo "⚠️  Image not found locally, will pull: $IMAGE_NAME"
fi

echo "📦 Using image: $IMAGE_NAME"

# Stop và remove container cũ nếu có
if docker ps -a --format '{{.Names}}' | grep -q '^backend-api$'; then
    echo "🛑 Stopping old container..."
    docker stop backend-api 2>/dev/null || true
    docker rm backend-api 2>/dev/null || true
fi

# Pull image nếu cần
if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "$IMAGE_NAME"; then
    echo "📥 Pulling image..."
    docker pull "$IMAGE_NAME"
fi

# Run backend container
echo "▶️  Starting backend container..."
docker run -d \
  --name backend-api \
  --restart unless-stopped \
  -p 8080:8080 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e ConnectionStrings__DefaultConnection="$DB_CONNECTION" \
  $IMAGE_NAME

echo "⏳ Waiting for backend to initialize..."
sleep 15

# Check logs
echo ""
echo "📋 Recent logs:"
docker logs backend-api | tail -20

# Health check
echo ""
echo "🏥 Health check..."
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ Backend is healthy!"
    echo ""
    echo "✨ Done! API is running at:"
    echo "   http://localhost:8080/health"
    echo "   http://localhost:8080/api/tasks"
else
    echo "⚠️  Health check failed. Check logs: docker logs backend-api"
    exit 1
fi

