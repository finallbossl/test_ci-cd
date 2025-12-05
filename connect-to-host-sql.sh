#!/bin/bash

# Script để kết nối backend với SQL Server Express trên host

echo "🔧 Connecting backend to SQL Server Express on host..."

# Connection string cho SQL Server Express trên host
# Lưu ý: Cần enable SQL Authentication và tạo user 'sa' với password
# Server có thể là: host.docker.internal, 172.24.180.191, hoặc IP của host
DB_CONNECTION="Server=host.docker.internal,1433;Database=DataTest;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;"

# Hoặc nếu biết IP chính xác:
# DB_CONNECTION="Server=172.24.180.191,1433;Database=DataTest;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;"

echo "Using connection string: Server=host.docker.internal,1433"

# Kiểm tra backend container
if ! docker ps --format '{{.Names}}' | grep -q '^backend-api$'; then
    echo "❌ Backend container not running"
    exit 1
fi

echo "✅ Backend container is running"

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

# Run backend với connection string đến host SQL Server
echo "▶️  Starting backend with host SQL Server connection..."
docker run -d \
  --name backend-api \
  --restart unless-stopped \
  --add-host=host.docker.internal:host-gateway \
  -p 8080:8080 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e ConnectionStrings__DefaultConnection="$DB_CONNECTION" \
  $IMAGE_NAME

echo "⏳ Waiting for backend to start..."
sleep 15

# Check logs
echo ""
echo "📋 Recent logs:"
docker logs backend-api | tail -30

echo ""
echo "✨ Done! Test with:"
echo "   curl http://localhost:8080/health"
echo "   curl http://localhost:8080/api/tasks"
echo ""
echo "⚠️  Lưu ý:"
echo "   1. Đảm bảo SQL Server Express đã enable SQL Authentication"
echo "   2. Đảm bảo user 'sa' đã được tạo và có password 'YourStrong@Passw0rd'"
echo "   3. Đảm bảo SQL Server Browser service đang chạy"
echo "   4. Đảm bảo firewall cho phép port 1433"

