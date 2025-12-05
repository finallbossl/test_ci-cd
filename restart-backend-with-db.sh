#!/bin/bash

# Script để restart backend với connection string đúng

echo "🔧 Restarting backend with correct database connection..."

# Connection string đúng với network alias
DB_CONNECTION="Server=sqlserver;Database=DataTest;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;"

# Kiểm tra containers
if ! docker ps --format '{{.Names}}' | grep -q '^sqlserver-db$'; then
    echo "❌ SQL Server container not running"
    exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q '^backend-api$'; then
    echo "❌ Backend container not running"
    exit 1
fi

echo "✅ Both containers are running"

# Stop và remove backend container
echo "🛑 Stopping backend container..."
docker stop backend-api
docker rm backend-api

# Get image name
IMAGE_NAME=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep 'ghcr.io/finallbossl/test_ci-cd' | head -n1)
if [ -z "$IMAGE_NAME" ]; then
    IMAGE_NAME="ghcr.io/finallbossl/test_ci-cd:latest"
fi

echo "📦 Using image: $IMAGE_NAME"

# Run backend với connection string đúng
echo "▶️  Starting backend with correct connection string..."
docker run -d \
  --name backend-api \
  --restart unless-stopped \
  --network backend-network \
  -p 8080:8080 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e ConnectionStrings__DefaultConnection="$DB_CONNECTION" \
  $IMAGE_NAME

echo "⏳ Waiting for backend to start..."
sleep 10

# Check logs
echo ""
echo "📋 Recent logs:"
docker logs backend-api | tail -20

echo ""
echo "✨ Done! Test with:"
echo "   curl http://localhost:8080/health"
echo "   curl http://localhost:8080/api/tasks"

