# 🚀 Hướng Dẫn Triển Khai Lên Cloud

Dự án của bạn có thể triển khai lên nhiều cloud provider khác nhau. Dưới đây là các lựa chọn phù hợp nhất:

## 📋 Tổng Quan Dự Án

- **Backend**: ASP.NET Core 8.0 (Docker container)
- **Frontend**: React + Vite (Static files)
- **Database**: SQL Server
- **CI/CD**: GitHub Actions

---

## 🆓 TL;DR - CÁC TÙY CHỌN MIỄN PHÍ

**Bạn muốn deploy FREE? Đây là top 3 lựa chọn:**

### 🥇 1. Railway.app - $0/tháng (Trong free credit $5)
- ✅ 100% miễn phí cho small apps
- ✅ Không sleep, luôn online
- ✅ Auto-deploy từ GitHub
- ✅ Đơn giản nhất
- ⚠️ Cần migrate SQL Server → PostgreSQL
- 📖 [Xem hướng dẫn chi tiết](#-option-1-railwayapp-100-free---recommended)

### 🥈 2. Render.com - $0-7/tháng
- ✅ Free tier cho backend + frontend
- ✅ Database free 90 ngày
- ✅ Rất dễ setup
- ⚠️ Backend sleep sau 15 phút không dùng (wake up ~30s)
- 📖 [Xem hướng dẫn chi tiết](#-option-2-rendercom-free-với-giới-hạn-hợp-lý)

### 🥉 3. Fly.io - $0/tháng
- ✅ Hoàn toàn miễn phí
- ✅ Không sleep, luôn online
- ✅ 3 VMs miễn phí
- ⚠️ Cần dùng Supabase cho database (free)
- 📖 [Xem hướng dẫn chi tiết](#-option-3-flyio-100-free-không-sleep)

**👉 Scroll xuống phần "[HƯỚNG DẪN DEPLOY MIỄN PHÍ](#-hướng-dẫn-deploy-miễn-phí-step-by-step)" để xem hướng dẫn chi tiết!**

---

## ☁️ 1. Microsoft Azure (Đề xuất #1)

### ✅ Ưu điểm:
- Hỗ trợ tốt nhất cho .NET Core và SQL Server
- Tích hợp với GitHub Actions
- Có free tier cho SQL Database
- Azure Container Instances (ACI) cho backend
- Azure Static Web Apps cho frontend

### 💰 Chi phí ước tính:
- **Backend (Azure Container Instances)**: ~$15-30/tháng
- **Frontend (Azure Static Web Apps)**: **Miễn phí** (100GB bandwidth)
- **Database (Azure SQL Database)**: ~$5-15/tháng (Basic tier)
- **Tổng**: ~$20-45/tháng

### 📝 Cách triển khai:

#### 1.1. Backend - Azure Container Instances (ACI)

```yaml
# .github/workflows/deploy-azure.yml
name: Deploy to Azure

on:
  push:
    branches: [main]

jobs:
  deploy-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Login to Azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Build and push to ACR
        uses: azure/docker-login@v1
        with:
          login-server: ${{ secrets.ACR_SERVER }}
          username: ${{ secrets.ACR_USERNAME }}
          password: ${{ secrets.ACR_PASSWORD }}
      
      - name: Build image
        run: docker build -t ${{ secrets.ACR_SERVER }}/backend:latest ./Backend
      
      - name: Push image
        run: docker push ${{ secrets.ACR_SERVER }}/backend:latest
      
      - name: Deploy to ACI
        uses: azure/aci-deploy@v1
        with:
          resource-group: my-resource-group
          dns-name-label: my-backend-api
          image: ${{ secrets.ACR_SERVER }}/backend:latest
          registry-login-server: ${{ secrets.ACR_SERVER }}
          registry-username: ${{ secrets.ACR_USERNAME }}
          registry-password: ${{ secrets.ACR_PASSWORD }}
          name: backend-api
          location: 'Southeast Asia'
          ports: 8080
          environment-variables: |
            ASPNETCORE_ENVIRONMENT=Production
            ConnectionStrings__DefaultConnection=${{ secrets.AZURE_SQL_CONNECTION }}
```

#### 1.2. Frontend - Azure Static Web Apps

```yaml
# .github/workflows/deploy-frontend-azure.yml
name: Deploy Frontend to Azure

on:
  push:
    branches: [main]
    paths:
      - 'Frontend/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Frontend
        working-directory: ./Frontend
        run: |
          npm install
          npm run build
      
      - name: Deploy to Azure Static Web Apps
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/Frontend"
          output_location: "dist"
```

#### 1.3. Database - Azure SQL Database

```bash
# Tạo Azure SQL Database
az sql server create \
  --name my-sql-server \
  --resource-group my-resource-group \
  --location "Southeast Asia" \
  --admin-user sa \
  --admin-password YourPassword123

az sql db create \
  --resource-group my-resource-group \
  --server my-sql-server \
  --name DataTest \
  --service-objective Basic
```

---

## 🐳 2. AWS (Amazon Web Services)

### ✅ Ưu điểm:
- Dịch vụ phong phú
- ECS/Fargate cho container
- S3 + CloudFront cho frontend
- RDS cho SQL Server

### 💰 Chi phí ước tính:
- **Backend (ECS Fargate)**: ~$15-25/tháng
- **Frontend (S3 + CloudFront)**: ~$1-5/tháng
- **Database (RDS SQL Server Express)**: ~$15-30/tháng
- **Tổng**: ~$31-60/tháng

### 📝 Cách triển khai:

#### 2.1. Backend - ECS Fargate

```yaml
# .github/workflows/deploy-aws.yml
name: Deploy to AWS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-southeast-1
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Build and push image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: backend-api
          IMAGE_TAG: latest
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG ./Backend
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
      
      - name: Deploy to ECS
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: task-definition.json
          service: backend-api
          cluster: my-cluster
```

#### 2.2. Frontend - S3 + CloudFront

```bash
# Build frontend
cd Frontend
npm install
npm run build

# Deploy to S3
aws s3 sync dist/ s3://my-frontend-bucket --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*"
```

---

## 🌐 3. Google Cloud Platform (GCP)

### ✅ Ưu điểm:
- Cloud Run cho backend (pay-per-use)
- Cloud SQL cho database
- Cloud Storage + CDN cho frontend
- $300 free credit trong 90 ngày

### 💰 Chi phí ước tính:
- **Backend (Cloud Run)**: ~$5-20/tháng (pay-per-use)
- **Frontend (Cloud Storage + CDN)**: ~$1-3/tháng
- **Database (Cloud SQL)**: ~$15-25/tháng
- **Tổng**: ~$21-48/tháng

### 📝 Cách triển khai:

#### 3.1. Backend - Cloud Run

```yaml
# .github/workflows/deploy-gcp.yml
name: Deploy to GCP

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Cloud SDK
        uses: google-github-actions/setup-gcloud@v1
      
      - name: Authenticate to GCP
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
      
      - name: Configure Docker
        run: gcloud auth configure-docker
      
      - name: Build and push image
        run: |
          docker build -t gcr.io/${{ secrets.GCP_PROJECT_ID }}/backend:latest ./Backend
          docker push gcr.io/${{ secrets.GCP_PROJECT_ID }}/backend:latest
      
      - name: Deploy to Cloud Run
        run: |
          gcloud run deploy backend-api \
            --image gcr.io/${{ secrets.GCP_PROJECT_ID }}/backend:latest \
            --platform managed \
            --region asia-southeast1 \
            --allow-unauthenticated \
            --set-env-vars ASPNETCORE_ENVIRONMENT=Production \
            --set-secrets ConnectionStrings__DefaultConnection=sql-connection-string:latest
```

---

## 🐙 4. DigitalOcean

### ✅ Ưu điểm:
- Đơn giản, dễ sử dụng
- Giá rẻ
- App Platform cho full-stack deployment
- Managed SQL Server

### 💰 Chi phí ước tính:
- **App Platform (Backend + Frontend)**: ~$12/tháng
- **Managed Database (SQL Server)**: ~$15/tháng
- **Tổng**: ~$27/tháng

### 📝 Cách triển khai:

Tạo `app.yaml`:

```yaml
name: my-app
region: sgp

services:
  - name: backend
    source_dir: /Backend
    github:
      repo: your-username/test_ci-cd
      branch: main
      deploy_on_push: true
    dockerfile_path: Dockerfile
    http_port: 8080
    instance_count: 1
    instance_size_slug: basic-xxs
    envs:
      - key: ASPNETCORE_ENVIRONMENT
        value: Production
      - key: ConnectionStrings__DefaultConnection
        value: ${db.DATABASE_URL}
    routes:
      - path: /api

  - name: frontend
    source_dir: /Frontend
    github:
      repo: your-username/test_ci-cd
      branch: main
    build_command: npm install && npm run build
    output_dir: dist
    instance_count: 1
    instance_size_slug: basic-xxs
    routes:
      - path: /

databases:
  - name: db
    engine: SQLSERVER
    version: "2022"
    production: false
```

---

## 🚢 5. Heroku

### ✅ Ưu điểm:
- Đơn giản nhất
- Có free tier (hạn chế)
- Không cần config phức tạp

### ❌ Nhược điểm:
- Không hỗ trợ SQL Server tốt (phải dùng PostgreSQL)
- Giá cao cho production
- Free tier bị giới hạn nhiều

### 💰 Chi phí:
- **Dyno (Backend)**: $7/tháng
- **PostgreSQL**: $9/tháng
- **Tổng**: ~$16/tháng (nhưng cần migrate sang PostgreSQL)

---

## 🔥 6. Railway (Đề xuất cho nhỏ/gọn)

### ✅ Ưu điểm:
- Rất đơn giản
- Hỗ trợ Docker
- Có free tier
- Tự động deploy từ GitHub

### 💰 Chi phí:
- **Free tier**: $5 credit/tháng
- **Production**: Pay-as-you-go

### 📝 Cách triển khai:

1. Kết nối GitHub repo với Railway
2. Tạo service từ Dockerfile
3. Add database (SQL Server hoặc PostgreSQL)
4. Set environment variables
5. Deploy tự động!

---

## 🆓 CÁC TÙY CHỌN MIỄN PHÍ (FREE TIER)

### 🏆 TOP 3 Lựa Chọn Miễn Phí Tốt Nhất:

#### 1. Railway.app ⭐⭐⭐⭐⭐ (Đề xuất #1)
**Miễn phí hoàn toàn cho development!**

✅ **Free Tier:**
- $5 credit/tháng (đủ cho small app)
- Backend + Frontend + Database
- Auto-deploy từ GitHub
- HTTPS tự động
- Custom domain (miễn phí)

💰 **Cách dùng free:**
- Backend: ~$2-3/tháng (từ free credit)
- Frontend: ~$1/tháng
- Database (PostgreSQL): ~$1-2/tháng
- **Tổng: ~$4-6/tháng trong free credit** → **HOÀN TOÀN MIỄN PHÍ!**

⚠️ **Lưu ý:** Railway dùng PostgreSQL, không phải SQL Server. Cần migrate database.

#### 2. Render.com ⭐⭐⭐⭐⭐
**Miễn phí hoàn toàn với giới hạn hợp lý!**

✅ **Free Tier:**
- Web Service: Miễn phí (sleep sau 15 phút không dùng)
- Static Site: Miễn phí vĩnh viễn
- PostgreSQL: Miễn phí (90 ngày, sau đó $7/tháng)

💰 **Cách dùng free:**
- Backend: **MIỄN PHÍ** (sleep khi không dùng)
- Frontend: **MIỄN PHÍ** (static hosting)
- Database: **MIỄN PHÍ 90 ngày**, sau đó $7/tháng
- **Tổng: $0-7/tháng**

📝 **Setup nhanh:**
1. Connect GitHub repo
2. Tạo Web Service từ Dockerfile
3. Tạo Static Site cho frontend
4. Tạo PostgreSQL database
5. Done!

#### 3. Fly.io ⭐⭐⭐⭐
**Miễn phí cho small apps!**

✅ **Free Tier:**
- 3 shared-cpu-1x VMs miễn phí
- 3GB persistent volumes
- 160GB outbound data transfer

💰 **Cách dùng free:**
- Backend: **MIỄN PHÍ** (1 VM)
- Frontend: **MIỄN PHÍ** (static files)
- Database: Cần dùng PostgreSQL (có thể dùng Supabase free)
- **Tổng: $0/tháng**

---

### 🎁 Các Free Tier Khác:

#### Azure Free Account (12 tháng free)
✅ **Free Tier:**
- $200 credit trong 30 ngày đầu
- Azure Static Web Apps: Miễn phí vĩnh viễn (100GB bandwidth)
- Azure SQL Database: 12 tháng free (DTU-based Basic tier)
- Container Instances: $200 credit

💰 **Chi phí sau 12 tháng:**
- Frontend: **MIỄN PHÍ**
- Backend: ~$15/tháng
- Database: ~$5/tháng
- **Tổng: ~$20/tháng**

#### AWS Free Tier (12 tháng free)
✅ **Free Tier:**
- EC2 t2.micro: 750 giờ/tháng (12 tháng)
- S3: 5GB storage
- RDS: Không có free tier cho SQL Server (chỉ có PostgreSQL)

💰 **Chi phí sau 12 tháng:** ~$30-50/tháng

#### GCP Free Tier ($300 credit trong 90 ngày)
✅ **Free Tier:**
- $300 credit trong 90 ngày
- Cloud Run: 2 triệu requests/tháng miễn phí
- Cloud SQL: Không có free tier

💰 **Chi phí sau 90 ngày:** ~$21-48/tháng

---

## 💡 GIẢI PHÁP 100% MIỄN PHÍ (RECOMMENDED)

### Option 1: Railway + Supabase (Best Choice) 🏆

**Setup:**
1. **Backend trên Railway** - Dùng free credit ($5/tháng)
2. **Frontend trên Railway** - Static hosting (từ free credit)
3. **Database trên Supabase** - PostgreSQL miễn phí (500MB)

✅ **Chi phí: HOÀN TOÀN MIỄN PHÍ**
✅ **Cần migrate từ SQL Server sang PostgreSQL** (dễ dàng với EF Core)

### Option 2: Render.com (Easiest) 🚀

**Setup:**
1. **Backend trên Render** - Free tier (sleep khi không dùng)
2. **Frontend trên Render** - Static site miễn phí
3. **PostgreSQL trên Render** - Free 90 ngày

✅ **Chi phí: $0-7/tháng** (sau 90 ngày chỉ phí database)
⚠️ **Backend sẽ sleep** sau 15 phút không dùng (wake up ~30s khi có request)

### Option 3: Fly.io + Supabase 💨

**Setup:**
1. **Backend trên Fly.io** - Free tier (3 VMs)
2. **Frontend trên Fly.io** - Static files miễn phí
3. **Database trên Supabase** - PostgreSQL miễn phí

✅ **Chi phí: HOÀN TOÀN MIỄN PHÍ**
✅ **Không sleep, luôn online**

---

## 📊 So Sánh Tổng Quan

| Cloud Provider | Chi phí/tháng | Free Tier | Độ khó | Hỗ trợ .NET | Hỗ trợ SQL Server | Đề xuất |
|----------------|---------------|-----------|--------|-------------|-------------------|---------|
| **Railway** | **$0-6** (free credit) | ✅ $5/tháng | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ (PostgreSQL) | ⭐⭐⭐⭐⭐ |
| **Render** | **$0-7** | ✅ Free tier | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ (PostgreSQL) | ⭐⭐⭐⭐⭐ |
| **Fly.io** | **$0** | ✅ 3 VMs free | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ (PostgreSQL) | ⭐⭐⭐⭐⭐ |
| **Azure** | $20-45 | ⚠️ 12 tháng free | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **AWS** | $31-60 | ⚠️ 12 tháng free | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **GCP** | $21-48 | ⚠️ $300/90 ngày | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **DigitalOcean** | $27 | ❌ Không có | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Heroku** | $16+ | ⚠️ Hạn chế | ⭐⭐⭐⭐ | ⭐⭐ | ⭐ (PostgreSQL) | ⭐⭐ |

---

## 🎯 Khuyến Nghị Theo Use Case

### 🆓 Cho FREE/Development/Demo (Ưu tiên $0):
1. **Railway** ⭐⭐⭐⭐⭐ - $0/tháng (trong free credit), đơn giản nhất
2. **Fly.io** ⭐⭐⭐⭐⭐ - $0/tháng, không sleep, luôn online
3. **Render** ⭐⭐⭐⭐ - $0/tháng (database free 90 ngày)

### 💼 Cho Production (Ưu tiên ổn định & hỗ trợ):
1. **Microsoft Azure** - Tốt nhất cho .NET + SQL Server ($20-45/tháng)
2. **AWS** - Nếu cần dịch vụ phong phú ($31-60/tháng)
3. **GCP** - Nếu muốn pay-per-use ($21-48/tháng)

### 🚀 Cho Startup (Ưu tiên chi phí thấp):
1. **Railway** - $0-6/tháng (free credit)
2. **Fly.io** - $0/tháng
3. **Render** - $0-7/tháng
4. **DigitalOcean** - App Platform $27/tháng

---

## 📝 Checklist Trước Khi Deploy Lên Cloud

### Backend:
- [ ] Update connection string trong `appsettings.Production.json`
- [ ] Update CORS policy trong `Program.cs` để cho phép domain mới
- [ ] Test Docker image build locally
- [ ] Verify health check endpoint (`/health`)
- [ ] Set up environment variables
- [ ] Configure logging

### Frontend:
- [ ] Update `API_BASE_URL` trong `shared/api.ts`
- [ ] Build và test static files locally
- [ ] Configure routing (SPA)
- [ ] Set up CDN (nếu cần)

### Database:
- [ ] Tạo database trên cloud
- [ ] Run migrations
- [ ] Test connection từ cloud backend
- [ ] Backup strategy
- [ ] Security (firewall rules)

### CI/CD:
- [ ] Update GitHub Actions workflow
- [ ] Set up secrets trong GitHub
- [ ] Test deployment pipeline
- [ ] Set up monitoring/alerting

---

## 🔐 Secrets Cần Thiết

### Azure:
- `AZURE_CREDENTIALS`
- `ACR_SERVER`
- `ACR_USERNAME`
- `ACR_PASSWORD`
- `AZURE_SQL_CONNECTION`

### AWS:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

### GCP:
- `GCP_SA_KEY`
- `GCP_PROJECT_ID`

---

## 🚀 HƯỚNG DẪN DEPLOY MIỄN PHÍ (STEP-BY-STEP)

### 🏆 Option 1: Railway.app (100% FREE - Recommended)

#### Bước 1: Đăng ký Railway
1. Truy cập: https://railway.app
2. Đăng nhập bằng GitHub
3. Bạn sẽ có **$5 free credit/tháng** tự động

#### Bước 2: Deploy Backend
1. Click **"New Project"** → **"Deploy from GitHub repo"**
2. Chọn repo `test_ci-cd`
3. Railway sẽ detect Dockerfile tự động
4. Chọn **"Add Dockerfile"** → Path: `Backend/Dockerfile`
5. Railway sẽ build và deploy tự động!

#### Bước 3: Tạo Database (PostgreSQL - FREE)
⚠️ **Lưu ý:** Railway không có SQL Server free. Cần dùng PostgreSQL.

1. Trong project, click **"+ New"** → **"Database"** → **"Add PostgreSQL"**
2. Database sẽ được tạo tự động (miễn phí trong free credit)

#### Bước 4: Migrate SQL Server → PostgreSQL
1. **Cập nhật `Backend.csproj`** để dùng PostgreSQL:
```xml
<PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="8.0.0" />
```

2. **Update `Program.cs`**:
```csharp
// Thay đổi từ
options.UseSqlServer(connectionString);
// Thành
options.UseNpgsql(connectionString);
```

3. **Chạy migration**:
```bash
dotnet ef migrations add MigrateToPostgres
dotnet ef database update
```

#### Bước 5: Set Environment Variables
Trong Railway backend service:
1. Click **"Variables"** tab
2. Add:
   - `ASPNETCORE_ENVIRONMENT=Production`
   - `ConnectionStrings__DefaultConnection` = [Lấy từ PostgreSQL service → Variables → DATABASE_URL]

#### Bước 6: Deploy Frontend
1. **"+ New"** → **"Empty Service"**
2. Chọn **"Deploy from GitHub repo"** → chọn repo
3. Root Directory: `/Frontend`
4. Build Command: `npm install && npm run build`
5. Output Directory: `dist`
6. Start Command: (để trống - static site)

#### Bước 7: Set Frontend API URL
Trong Frontend service → Variables:
- `VITE_API_BASE_URL` = [Backend URL từ Railway, ví dụ: https://backend-production-xxxx.up.railway.app]

✅ **Done! Tổng chi phí: $0 (nằm trong free credit $5/tháng)**

---

### 🚀 Option 2: Render.com (FREE với giới hạn hợp lý)

#### Bước 1: Đăng ký Render
1. Truy cập: https://render.com
2. Đăng nhập bằng GitHub
3. Free tier có sẵn!

#### Bước 2: Deploy Backend
1. **"New +"** → **"Web Service"**
2. Connect GitHub repo
3. Settings:
   - **Name**: `backend-api`
   - **Environment**: `Docker`
   - **Dockerfile Path**: `Backend/Dockerfile`
   - **Region**: Singapore (gần Việt Nam)
   - **Branch**: `main`
   - **Instance Type**: **Free** (sẽ sleep sau 15 phút)
   - **Auto-Deploy**: Yes

4. **Environment Variables**:
   - `ASPNETCORE_ENVIRONMENT=Production`
   - `ConnectionStrings__DefaultConnection` = [Sẽ set sau khi tạo DB]

5. Click **"Create Web Service"**

⚠️ **Lưu ý:** Backend sẽ sleep sau 15 phút không dùng. Request đầu tiên sẽ mất ~30s để wake up.

#### Bước 3: Tạo PostgreSQL Database
1. **"New +"** → **"PostgreSQL"**
2. Settings:
   - **Name**: `mydatabase`
   - **Database**: `DataTest`
   - **User**: `mydbuser`
   - **Region**: Singapore
   - **Plan**: **Free** (chỉ 90 ngày, sau đó $7/tháng)
3. Click **"Create Database"**

4. **Lấy Connection String:**
   - Vào Database → **"Connections"** tab
   - Copy **"Internal Database URL"**
   - Format: `postgresql://user:pass@host:5432/dbname`

#### Bước 4: Update Backend Environment Variable
1. Vào Backend service → **"Environment"**
2. Update `ConnectionStrings__DefaultConnection` với connection string từ database

#### Bước 5: Deploy Frontend
1. **"New +"** → **"Static Site"**
2. Connect GitHub repo
3. Settings:
   - **Name**: `frontend`
   - **Branch**: `main`
   - **Root Directory**: `Frontend`
   - **Build Command**: `npm install && npm run build`
   - **Publish Directory**: `dist`
   - **Auto-Deploy**: Yes

4. **Environment Variables** (nếu cần):
   - `VITE_API_BASE_URL` = [Backend URL từ Render]

✅ **Done! Tổng chi phí: $0 (90 ngày đầu), sau đó $7/tháng (chỉ database)**

---

### 💨 Option 3: Fly.io (100% FREE, không sleep)

#### Bước 1: Install Fly CLI
```bash
# Windows (PowerShell)
iwr https://fly.io/install.ps1 -useb | iex

# Linux/Mac
curl -L https://fly.io/install.sh | sh
```

#### Bước 2: Login Fly.io
```bash
fly auth login
```

#### Bước 3: Deploy Backend
```bash
cd Backend
fly launch

# Chọn:
# - App name: [tên app của bạn]
# - Region: sin (Singapore)
# - PostgreSQL: No (sẽ dùng Supabase)
# - Redis: No
```

#### Bước 4: Tạo Database trên Supabase (FREE)
1. Truy cập: https://supabase.com
2. Đăng nhập bằng GitHub
3. **"New Project"**
4. Settings:
   - **Name**: `mydatabase`
   - **Database Password**: [tạo password]
   - **Region**: Southeast Asia (Singapore)
5. Click **"Create new project"**

6. **Lấy Connection String:**
   - Vào **Project Settings** → **Database**
   - Copy **"Connection string"** (URI format)

#### Bước 5: Set Environment Variables
```bash
fly secrets set ASPNETCORE_ENVIRONMENT=Production
fly secrets set ConnectionStrings__DefaultConnection="[Connection string từ Supabase]"
```

#### Bước 6: Deploy Frontend
```bash
cd Frontend
fly launch --name [frontend-app-name]

# Sau đó set environment:
fly secrets set VITE_API_BASE_URL=https://[backend-app-name].fly.dev
```

✅ **Done! Tổng chi phí: $0 (hoàn toàn miễn phí, không sleep)**

---

## 📋 QUICK COMPARISON: Free Options

| Platform | Chi phí | Sleep? | Setup | Database | Rating |
|----------|---------|--------|-------|----------|--------|
| **Railway** | $0 (free credit) | ❌ No | ⭐⭐⭐⭐⭐ | PostgreSQL | ⭐⭐⭐⭐⭐ |
| **Render** | $0 (90 ngày DB) | ⚠️ Yes (15 phút) | ⭐⭐⭐⭐⭐ | PostgreSQL | ⭐⭐⭐⭐ |
| **Fly.io** | $0 | ❌ No | ⭐⭐⭐ | PostgreSQL | ⭐⭐⭐⭐⭐ |
| **Azure** | $0 (12 tháng) | ❌ No | ⭐⭐⭐ | SQL Server | ⭐⭐⭐⭐ |

---

## 🎯 KHUYẾN NGHỊ CHO BẠN

### Nếu muốn 100% FREE và không sleep:
→ **Fly.io + Supabase** ⭐⭐⭐⭐⭐

### Nếu muốn đơn giản nhất:
→ **Railway** ⭐⭐⭐⭐⭐

### Nếu muốn có free tier lâu dài:
→ **Render** (database chỉ free 90 ngày) ⭐⭐⭐⭐

### Nếu muốn giữ SQL Server:
→ **Azure** (12 tháng free, sau đó ~$20/tháng) ⭐⭐⭐⭐

---

## 💡 Tips

1. **Bắt đầu với Railway/DigitalOcean** để test nhanh
2. **Chuyển sang Azure** khi cần production ổn định
3. **Sử dụng managed database** thay vì tự quản lý
4. **Enable HTTPS** cho tất cả services
5. **Set up monitoring** (Application Insights, CloudWatch, etc.)
6. **Backup database** định kỳ
7. **Use environment variables** cho tất cả secrets

---

## 📚 Tài Liệu Tham Khảo

- Azure: https://docs.microsoft.com/azure/
- AWS: https://docs.aws.amazon.com/
- GCP: https://cloud.google.com/docs
- DigitalOcean: https://docs.digitalocean.com/
- Railway: https://docs.railway.app/

---

**Cần hỗ trợ triển khai lên cloud cụ thể nào? Hãy cho tôi biết!** 🚀

