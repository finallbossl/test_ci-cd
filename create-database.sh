#!/bin/bash

# Script để tạo database và tables trong SQL Server container

echo "🔧 Creating database and tables..."

# Kiểm tra SQL Server container
if ! docker ps --format '{{.Names}}' | grep -q '^sqlserver-db$'; then
    echo "❌ SQL Server container not running"
    exit 1
fi

echo "✅ SQL Server container is running"

# Tạo database và tables bằng cách chạy SQL commands
echo "Creating database DataTest..."
docker exec -i sqlserver-db /opt/mssql-tools/bin/sqlcmd \
  -S localhost \
  -U sa \
  -P YourStrong@Passw0rd \
  -Q "IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DataTest') CREATE DATABASE DataTest;" \
  2>/dev/null || echo "Database may already exist"

echo "✅ Database created or already exists"

# Kiểm tra xem table Tasks đã tồn tại chưa
echo "Checking if Tasks table exists..."
TABLE_EXISTS=$(docker exec -i sqlserver-db /opt/mssql-tools/bin/sqlcmd \
  -S localhost \
  -U sa \
  -P YourStrong@Passw0rd \
  -d DataTest \
  -Q "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Tasks';" \
  -h -1 \
  2>/dev/null | tr -d '[:space:]')

if [ "$TABLE_EXISTS" = "0" ]; then
    echo "Creating Tasks table..."
    docker exec -i sqlserver-db /opt/mssql-tools/bin/sqlcmd \
      -S localhost \
      -U sa \
      -P YourStrong@Passw0rd \
      -d DataTest \
      -Q "CREATE TABLE Tasks (
          Id nvarchar(450) PRIMARY KEY,
          Title nvarchar(500) NOT NULL,
          Description nvarchar(2000) NOT NULL,
          Tag nvarchar(50) NOT NULL,
          Date nvarchar(10) NOT NULL,
          Time nvarchar(10) NOT NULL,
          Completed bit NOT NULL
      );" \
      2>/dev/null
    echo "✅ Tasks table created"
else
    echo "✅ Tasks table already exists"
fi

echo ""
echo "✨ Done! Restart backend to apply changes:"
echo "   docker restart backend-api"


