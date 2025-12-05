#!/bin/bash

# Script để fix network cho backend và SQL Server containers

echo "🔧 Fixing network connection between backend and SQL Server..."

# Tạo network nếu chưa có
docker network create backend-network 2>/dev/null || echo "Network already exists"

# Kiểm tra SQL Server container
if docker ps --format '{{.Names}}' | grep -q '^sqlserver-db$'; then
    echo "✅ SQL Server container is running"
    # Kết nối SQL Server vào network
    docker network connect backend-network sqlserver-db 2>/dev/null || echo "SQL Server already in network"
    
    # Thêm network alias nếu chưa có
    docker network disconnect backend-network sqlserver-db 2>/dev/null
    docker network connect backend-network sqlserver-db --alias sqlserver 2>/dev/null || true
else
    echo "❌ SQL Server container not found"
fi

# Kiểm tra Backend container
if docker ps --format '{{.Names}}' | grep -q '^backend-api$'; then
    echo "✅ Backend container is running"
    # Kết nối Backend vào network
    docker network connect backend-network backend-api 2>/dev/null || echo "Backend already in network"
    
    # Restart backend để áp dụng network changes
    echo "🔄 Restarting backend container..."
    docker restart backend-api
    sleep 5
    echo "✅ Backend restarted"
else
    echo "❌ Backend container not found"
fi

echo ""
echo "📊 Network status:"
docker network inspect backend-network --format '{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null || echo "No containers in network"

echo ""
echo "✨ Done! Check logs with: docker logs backend-api"

