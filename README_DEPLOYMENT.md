# Hướng dẫn Deploy Production

Quy trình tự động deploy production với Docker và GitHub Actions.

> 📖 **Xem hướng dẫn chi tiết từng bước:** [HUONG_DAN_CI_CD.md](./HUONG_DAN_CI_CD.md)

## 📋 Yêu cầu

- Docker và Docker Compose
- GitHub repository
- Server production với SSH access

## 🐳 Docker

### Build và chạy local

```bash
# Build image
docker build -t backend-api ./Backend

# Chạy với docker-compose (bao gồm SQL Server)
docker-compose up -d

# Xem logs
docker-compose logs -f backend

# Dừng
docker-compose down
```

### Chạy container riêng lẻ

```bash
# Chạy SQL Server
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=YourStrong@Passw0rd" \
  -p 1433:1433 --name sqlserver-db \
  -d mcr.microsoft.com/mssql/server:2022-latest

# Chạy Backend
docker run -d \
  --name backend-api \
  -p 8080:8080 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e ConnectionStrings__DefaultConnection="Server=host.docker.internal;Database=DataTest;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;" \
  backend-api
```

## 🚀 GitHub Actions CI/CD

### Setup Secrets

Vào GitHub repository → Settings → Secrets and variables → Actions, thêm các secrets sau:

1. **PRODUCTION_HOST**: Địa chỉ IP hoặc domain của server production
2. **PRODUCTION_USER**: Username SSH để kết nối server
3. **PRODUCTION_SSH_KEY**: Private SSH key để kết nối server
4. **PRODUCTION_PORT**: Port SSH (mặc định: 22)
5. **PRODUCTION_URL**: URL của API production (ví dụ: http://your-domain.com:8080)
6. **PRODUCTION_DB_CONNECTION**: Connection string cho database production

### Workflows

#### 1. CI Pipeline (`.github/workflows/ci.yml`)
- Chạy khi có Pull Request hoặc push vào branch khác main/master
- Build và test code
- Build Docker image để test

#### 2. Production Deploy (`.github/workflows/deploy-production.yml`)
- Chạy khi push vào branch `main` hoặc `master`
- Build và test code
- Build và push Docker image lên GitHub Container Registry
- Deploy tự động lên server production

### Quy trình deploy

1. Push code lên branch `main` hoặc `master`
2. GitHub Actions tự động:
   - Build và test code
   - Build Docker image
   - Push image lên GitHub Container Registry
   - SSH vào server production
   - Pull image mới nhất
   - Dừng container cũ
   - Chạy container mới
   - Health check

## 🔧 Cấu hình Production

### Environment Variables

Trên server production, có thể override các biến môi trường:

```bash
docker run -d \
  --name backend-api \
  -p 8080:8080 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e ConnectionStrings__DefaultConnection="your-connection-string" \
  ghcr.io/your-username/your-repo:latest
```

### Database Migrations

Để chạy migrations trên production:

```bash
# Vào trong container
docker exec -it backend-api bash

# Hoặc chạy migration từ local
dotnet ef database update --project Backend --connection "your-connection-string"
```

## 📝 Lưu ý

1. **Security**: 
   - Đổi password SQL Server trong production
   - Sử dụng secrets để lưu connection strings
   - Không commit sensitive data vào git

2. **Database**: 
   - Đảm bảo SQL Server đã được setup trên production
   - Connection string phải đúng với môi trường production

3. **CORS**: 
   - Cập nhật CORS policy trong `Program.cs` để cho phép domain production

4. **Health Check**: 
   - Endpoint `/health` được sử dụng để kiểm tra container health
   - Đảm bảo endpoint này accessible

## 🐛 Troubleshooting

### Container không start
```bash
# Xem logs
docker logs backend-api

# Kiểm tra container status
docker ps -a
```

### Database connection error
- Kiểm tra connection string
- Đảm bảo SQL Server đang chạy
- Kiểm tra firewall rules

### GitHub Actions fail
- Kiểm tra secrets đã được setup đúng
- Kiểm tra SSH key có quyền truy cập server
- Xem logs trong GitHub Actions tab

