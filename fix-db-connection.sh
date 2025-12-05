#!/bin/bash

# Script để fix database connection - kiểm tra và sửa tất cả

echo "🔧 Fixing database connection..."

# 1. Kiểm tra SQL Server có network alias chưa
echo "1. Checking SQL Server network alias..."
SQL_ALIAS=$(docker network inspect backend-network --format '{{range $container, $config := .Containers}}{{if eq $container "f1066cc6458675d642f90359b48015906245e2407981eee8cae3a2875ac032b2"}}{{range $alias := $config.Aliases}}{{$alias}} {{end}}{{end}}{{end}}' 2>/dev/null)

if ! echo "$SQL_ALIAS" | grep -q "sqlserver"; then
    echo "   ⚠️  SQL Server doesn't have 'sqlserver' alias. Fixing..."
    # Disconnect và reconnect với alias
    docker network disconnect backend-network sqlserver-db 2>/dev/null || true
    docker network connect backend-network sqlserver-db --alias sqlserver
    echo "   ✅ Added 'sqlserver' alias"
else
    echo "   ✅ SQL Server has 'sqlserver' alias"
fi

# 2. Test kết nối từ backend container
echo ""
echo "2. Testing connection from backend container..."
docker exec backend-api ping -c 1 sqlserver 2>/dev/null && echo "   ✅ Can ping sqlserver" || echo "   ❌ Cannot ping sqlserver"

# 3. Kiểm tra connection string hiện tại
echo ""
echo "3. Current connection string in container:"
docker exec backend-api printenv | grep ConnectionStrings || echo "   ⚠️  No ConnectionStrings found in environment"

# 4. Restart backend với connection string đúng
echo ""
echo "4. Restarting backend with correct connection string..."
DB_CONNECTION="Server=sqlserver;Database=DataTest;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;"

# Stop và remove
docker stop backend-api
docker rm backend-api

# Get image
IMAGE_NAME=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep 'ghcr.io/finallbossl/test_ci-cd' | head -n1)
if [ -z "$IMAGE_NAME" ]; then
    IMAGE_NAME="ghcr.io/finallbossl/test_ci-cd:latest"
fi

# Run với connection string đúng
docker run -d \
  --name backend-api \
  --restart unless-stopped \
  --network backend-network \
  -p 8080:8080 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e ConnectionStrings__DefaultConnection="$DB_CONNECTION" \
  $IMAGE_NAME

echo "   ✅ Backend restarted"

# 5. Đợi và kiểm tra
echo ""
echo "5. Waiting for backend to initialize..."
sleep 15

echo ""
echo "6. Checking logs..."
docker logs backend-api | tail -20

echo ""
echo "✨ Done! Test with:"
echo "   curl http://localhost:8080/health"
echo "   curl http://localhost:8080/api/tasks"

