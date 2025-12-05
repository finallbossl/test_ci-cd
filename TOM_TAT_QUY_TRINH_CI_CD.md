# 📋 Tóm tắt Quy trình CI/CD - Từ đầu đến cuối

Tài liệu tóm tắt toàn bộ quy trình CI/CD đã được setup.

## 🎯 Tổng quan

**Repository:** https://github.com/finallbossl/test_ci-cd  
**Server Production:** `finalboss` (172.24.180.191)  
**Runner:** Self-Hosted Runner trên server `finalboss`

---

## 📦 1. Cấu trúc Project

### Files đã tạo:

#### Docker Configuration
- ✅ `Backend/Dockerfile` - Multi-stage build cho .NET 8.0
- ✅ `Backend/.dockerignore` - Loại trừ files không cần thiết
- ✅ `docker-compose.yml` - Setup với SQL Server và Backend API
- ✅ `Backend/appsettings.Production.json` - Config cho production

#### GitHub Actions Workflows
- ✅ `.github/workflows/ci.yml` - CI pipeline cho Pull Requests
- ✅ `.github/workflows/deploy-production.yml` - Auto deploy khi push vào main/master
- ✅ `.github/workflows/deploy-production-self-hosted.yml` - Workflow dùng self-hosted runner

#### Documentation
- ✅ `README_DEPLOYMENT.md` - Hướng dẫn deploy
- ✅ `HUONG_DAN_CI_CD.md` - Hướng dẫn chi tiết CI/CD
- ✅ `QUICK_START_CI_CD.md` - Quick start guide
- ✅ `SETUP_SELF_HOSTED_RUNNER.md` - Hướng dẫn setup runner
- ✅ Các file troubleshooting khác

#### Scripts
- ✅ `deploy.sh` - Script deploy manual (Linux/Mac)
- ✅ `deploy.ps1` - Script deploy manual (Windows)
- ✅ `setup-runner.sh` - Script tự động setup runner

---

## 🔄 2. Quy trình CI/CD hoạt động như thế nào?

### Khi push code lên branch `main` hoặc `master`:

```
1. Push code lên GitHub
   ↓
2. GitHub Actions tự động trigger workflow
   ↓
3. Job 1: Build and Test
   - Chạy trên: ubuntu-latest (GitHub cloud)
   - Restore dependencies
   - Build .NET project
   - Run tests
   ↓
4. Job 2: Build and Push Docker Image
   - Chạy trên: ubuntu-latest (GitHub cloud)
   - Build Docker image
   - Push image lên GitHub Container Registry (ghcr.io)
   ↓
5. Job 3: Deploy to Production
   - Chạy trên: self-hosted (server finalboss)
   - Login to GitHub Container Registry
   - Pull Docker image mới nhất
   - Stop container cũ (backend-api)
   - Run container mới với image mới
   - Health check
   ↓
✅ Deploy thành công!
```

---

## 🛠️ 3. Các thành phần đã setup

### 3.1. Docker

**Dockerfile:**
- Multi-stage build (build → publish → runtime)
- Non-root user
- Health check endpoint
- Port 8080

**Docker Compose:**
- Backend API service
- SQL Server service
- Network và volumes

### 3.2. GitHub Actions

**CI Pipeline (`ci.yml`):**
- Chạy khi có Pull Request
- Build và test code
- Build Docker image để test

**Production Deploy (`deploy-production.yml`):**
- Chạy khi push vào main/master
- 3 jobs: Build → Build Docker → Deploy
- Deploy tự động lên server

### 3.3. Self-Hosted Runner

**Đã setup trên server `finalboss`:**
- Runner version: 2.329.0
- Service: `actions.runner.finallbossl-test_ci-cd.finalboss.service`
- Status: Active (running)
- Location: `~/actions-runner`

---

## 🔐 4. GitHub Secrets đã setup

| Secret Name | Mô tả | Giá trị |
|------------|-------|---------|
| `PRODUCTION_HOST` | IP server (không dùng nữa với self-hosted) | `172.24.180.191` |
| `PRODUCTION_USER` | Username SSH (không dùng nữa) | `boss` |
| `PRODUCTION_SSH_KEY` | SSH private key (không dùng nữa) | - |
| `PRODUCTION_PORT` | SSH port (không dùng nữa) | `22` |
| `PRODUCTION_URL` | URL API | `http://172.24.180.191:8080` |
| `PRODUCTION_DB_CONNECTION` | Connection string SQL Server | `Server=...;Database=...;...` |

**Lưu ý:** Với self-hosted runner, không cần SSH secrets nữa vì runner chạy trực tiếp trên server.

---

## 📝 5. Các bước đã thực hiện

### Bước 1: Tạo Docker Configuration
- ✅ Tạo Dockerfile
- ✅ Tạo docker-compose.yml
- ✅ Tạo appsettings.Production.json

### Bước 2: Tạo GitHub Actions Workflows
- ✅ Tạo CI workflow
- ✅ Tạo Production Deploy workflow
- ✅ Cập nhật để dùng self-hosted runner

### Bước 3: Setup Self-Hosted Runner
- ✅ Download runner trên server
- ✅ Cấu hình runner với token
- ✅ Cài đặt như systemd service
- ✅ Start service

### Bước 4: Push code lên GitHub
- ✅ Push tất cả files
- ✅ Workflow tự động chạy

---

## 🚀 6. Cách sử dụng

### Deploy tự động (Khuyến nghị)

```bash
# Từ máy local
git add .
git commit -m "Your changes"
git push origin main
```

→ Workflow tự động chạy và deploy!

### Deploy manual

Vào GitHub → Actions → Chọn workflow → "Run workflow"

### Xem kết quả

1. **GitHub Actions:**
   - https://github.com/finallbossl/test_ci-cd/actions

2. **Docker Images:**
   - https://github.com/finallbossl/test_ci-cd/packages

3. **Runner Status:**
   - https://github.com/finallbossl/test_ci-cd/settings/actions/runners

4. **Server:**
   ```bash
   # SSH vào server
   ssh boss@finalboss
   
   # Kiểm tra container
   docker ps
   docker logs backend-api
   
   # Test API
   curl http://localhost:8080/health
   ```

---

## 🔍 7. Kiểm tra và Monitoring

### Kiểm tra Runner

```bash
# Trên server
sudo ./svc.sh status
sudo journalctl -u actions.runner.*.service -f
```

### Kiểm tra Container

```bash
# Xem containers đang chạy
docker ps

# Xem logs
docker logs backend-api

# Xem logs real-time
docker logs -f backend-api
```

### Kiểm tra API

```bash
# Health check
curl http://localhost:8080/health

# Hoặc từ browser
http://172.24.180.191:8080/health
```

---

## 🐛 8. Troubleshooting

### Runner không chạy

```bash
# Restart runner
sudo ./svc.sh restart

# Xem logs
sudo journalctl -u actions.runner.*.service -f
```

### Container không start

```bash
# Xem logs
docker logs backend-api

# Kiểm tra image
docker images | grep test_ci-cd
```

### Workflow fail

- Xem logs trong GitHub Actions tab
- Kiểm tra runner có online không
- Kiểm tra secrets đã setup đúng chưa

---

## 📊 9. Workflow Jobs chi tiết

### Job 1: Build and Test
- **Runner:** `ubuntu-latest`
- **Steps:**
  1. Checkout code
  2. Setup .NET 8.0
  3. Restore dependencies
  4. Build project
  5. Run tests

### Job 2: Build and Push Docker Image
- **Runner:** `ubuntu-latest`
- **Steps:**
  1. Checkout code
  2. Setup Docker Buildx
  3. Login to GitHub Container Registry
  4. Build Docker image
  5. Push image to registry

### Job 3: Deploy to Production
- **Runner:** `self-hosted` (server finalboss)
- **Steps:**
  1. Checkout code
  2. Login to GitHub Container Registry
  3. Pull latest image
  4. Stop old container
  5. Run new container
  6. Clean up old images
  7. Health check

---

## ✅ 10. Checklist hoàn thành

- [x] Docker configuration
- [x] GitHub Actions workflows
- [x] Self-hosted runner setup
- [x] GitHub Secrets setup
- [x] Workflow đã chạy thành công
- [x] Container đang chạy trên server
- [x] API accessible

---

## 🎉 Kết quả

**CI/CD Pipeline hoàn chỉnh:**
- ✅ Tự động build và test khi push code
- ✅ Tự động build Docker image
- ✅ Tự động deploy lên production
- ✅ Health check tự động
- ✅ Rollback dễ dàng (pull image cũ)

**Ưu điểm:**
- 🚀 Deploy nhanh (runner trên server)
- 🔒 An toàn (không cần mở SSH ra internet)
- 🔄 Tự động hoàn toàn
- 📊 Dễ monitor và debug

---

## 📚 Tài liệu tham khảo

- **Hướng dẫn chi tiết:** [HUONG_DAN_CI_CD.md](./HUONG_DAN_CI_CD.md)
- **Quick Start:** [QUICK_START_CI_CD.md](./QUICK_START_CI_CD.md)
- **Setup Runner:** [SETUP_SELF_HOSTED_RUNNER.md](./SETUP_SELF_HOSTED_RUNNER.md)
- **Deployment Guide:** [README_DEPLOYMENT.md](./README_DEPLOYMENT.md)

---

**🎊 Quy trình CI/CD đã hoàn tất và sẵn sàng sử dụng!**

