# 🏗️ Kiến Trúc CI/CD với GitHub Actions + Render

## 📋 Tổng Quan

**GitHub Actions = CI/CD Pipeline**  
**Render = Runtime Environment (Môi trường chạy)**

---

## 🔄 Luồng CI/CD Hoàn Chỉnh

```
┌─────────────────┐
│   Developer     │
│   (Push Code)   │
└────────┬────────┘
         │
         │ git push origin main
         ▼
┌─────────────────────────────────────┐
│   GitHub Repository                 │
└────────┬────────────────────────────┘
         │
         │ Trigger GitHub Actions
         ▼
┌─────────────────────────────────────┐
│   GitHub Actions (CI/CD)            │
│   ┌───────────────────────────────┐ │
│   │ 1. Build & Test               │ │
│   │    - Run dotnet build         │ │
│   │    - Run tests                │ │
│   └───────────────────────────────┘ │
│   ┌───────────────────────────────┐ │
│   │ 2. Build Docker Image         │ │
│   │    - Build from Dockerfile    │ │
│   │    - Push to GHCR             │ │
│   └───────────────────────────────┘ │
│   ┌───────────────────────────────┐ │
│   │ 3. (Optional) Deploy Trigger  │ │
│   │    - Notify Render            │ │
│   └───────────────────────────────┘ │
└────────┬────────────────────────────┘
         │
         │ Code changes detected
         ▼
┌─────────────────────────────────────┐
│   Render (Runtime Environment)      │
│   ┌───────────────────────────────┐ │
│   │ Auto-Deploy (if enabled)      │ │
│   │ - Pull latest code from Git   │ │
│   │ - Rebuild application         │ │
│   │ - Restart services            │ │
│   └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

## 🔧 Vai Trò Của Từng Component

### 1. GitHub Actions (CI/CD Pipeline)

**Chức năng:**
- ✅ **Continuous Integration (CI)**
  - Build code
  - Run tests
  - Lint và code quality checks
  
- ✅ **Continuous Delivery (CD)**
  - Build Docker images
  - Push images lên container registry (GHCR)
  - Trigger deployments

**Workflows:**
- `ci.yml` - CI cho PRs và feature branches
- `deploy-production-self-hosted.yml` - Deploy lên self-hosted runner
- `deploy-render.yml` - Build và push images (Render auto-deploy)

---

### 2. Render (Runtime Environment)

**Chức năng:**
- ✅ **Hosting & Runtime**
  - Chạy backend API (Docker container)
  - Host frontend (Static files)
  - Manage database (PostgreSQL)

- ✅ **Auto-Deploy**
  - Tự động detect code changes từ GitHub
  - Pull code mới
  - Rebuild và restart services

**Services:**
- Backend Web Service (Docker)
- Frontend Static Site
- PostgreSQL Database

---

## 📊 So Sánh

| Component | Vai Trò | Nơi Chạy | Quản Lý |
|-----------|---------|----------|---------|
| **GitHub Actions** | CI/CD Pipeline | GitHub Cloud | GitHub |
| **Render** | Runtime Environment | Render Cloud | Render |
| **GitHub Container Registry** | Image Storage | GitHub Cloud | GitHub |

---

## 🚀 Workflow Chi Tiết

### Khi Push Code:

#### Bước 1: GitHub Actions Build & Test ✅
```yaml
jobs:
  build-and-test:
    - Checkout code
    - Setup .NET
    - Restore dependencies
    - Build
    - Run tests
```

#### Bước 2: GitHub Actions Build Docker ✅
```yaml
  build-and-push-docker:
    - Build Docker image
    - Push to GHCR
    - Tag với version
```

#### Bước 3: Render Auto-Deploy ✅
```
Render detects code changes
  → Pull latest code from GitHub
  → Rebuild application
  → Restart services
  → Health check
```

---

## ⚙️ Cấu Hình Auto-Deploy trên Render

### Backend Service:

1. **Vào Render Dashboard** → Backend Service
2. **Settings** → **Auto-Deploy**:
   - ✅ **Auto-Deploy**: Enabled
   - **Branch**: `main`
   - **Root Directory**: (để trống)
   - **Build Command**: (Render dùng Dockerfile)
   - **Start Command**: (Render tự động)

3. **Environment Variables**:
   ```
   ASPNETCORE_ENVIRONMENT=Production
   ASPNETCORE_URLS=http://0.0.0.0:8080
   ConnectionStrings__DefaultConnection=[from database]
   FRONTEND_URLS=[frontend URL]
   ```

### Frontend Service:

1. **Auto-Deploy**: Enabled
2. **Branch**: `main`
3. **Root Directory**: `Frontend`
4. **Build Command**: `npm install && npm run build`
5. **Publish Directory**: `dist`

---

## 🔄 Hai Mô Hình CI/CD

### Mô Hình 1: Render Auto-Deploy (Hiện Tại) ⭐

**Flow:**
```
GitHub Push → Render Auto-Deploy → Rebuild → Deploy
```

**Ưu điểm:**
- ✅ Đơn giản
- ✅ Render tự động handle mọi thứ
- ✅ Không cần config phức tạp

**Nhược điểm:**
- ⚠️ Build trên Render (chậm hơn)
- ⚠️ Không có full control pipeline

---

### Mô Hình 2: GitHub Actions + Render Webhook (Nâng Cao)

**Flow:**
```
GitHub Push → GitHub Actions Build → Push Image → Render Webhook → Deploy
```

**Ưu điểm:**
- ✅ Build nhanh hơn (GitHub Actions)
- ✅ Full control pipeline
- ✅ Reuse Docker images

**Nhược điểm:**
- ⚠️ Phức tạp hơn
- ⚠️ Cần setup webhook

---

## 📝 Checklist CI/CD Setup

### GitHub Actions:
- [x] CI workflow cho PRs
- [x] Build & Test workflow
- [x] Docker build & push workflow
- [x] Deploy to Render workflow (optional)

### Render:
- [ ] Auto-deploy enabled cho Backend
- [ ] Auto-deploy enabled cho Frontend
- [ ] Environment variables configured
- [ ] Database linked
- [ ] Health checks configured

---

## 🎯 Best Practices

### 1. Branch Strategy:
- `main` → Production (auto-deploy)
- `develop` → Staging (optional)
- Feature branches → CI only

### 2. Docker Images:
- ✅ Tag với git SHA
- ✅ Tag với `latest` cho main branch
- ✅ Cache layers để build nhanh hơn

### 3. Environment Variables:
- ✅ Secrets trong Render dashboard
- ❌ Không commit secrets vào Git

### 4. Health Checks:
- ✅ Configure health check endpoint
- ✅ Monitor deployment status

---

## 🔗 Tài Liệu

- GitHub Actions: https://docs.github.com/en/actions
- Render Docs: https://render.com/docs
- Render Auto-Deploy: https://render.com/docs/auto-deploy

---

## ✅ Kết Luận

**GitHub Actions = CI/CD Pipeline (Build, Test, Package)**  
**Render = Runtime Environment (Host, Run, Scale)**

**Cả hai làm việc cùng nhau:**
- GitHub Actions: Đảm bảo code quality và build images
- Render: Chạy application và tự động deploy khi có code mới

🚀 **Đây là mô hình hiện đại: CI/CD trên GitHub, Runtime trên Render!**

