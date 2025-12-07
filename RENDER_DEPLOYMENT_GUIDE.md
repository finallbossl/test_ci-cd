# 🚀 Hướng Dẫn Deploy Lên Render.com

Hướng dẫn chi tiết từng bước để deploy backend và frontend lên Render.com.

## 📋 Yêu Cầu

- ✅ Tài khoản GitHub (để kết nối repo)
- ✅ Tài khoản Render.com (free)
- ✅ Database sẽ được migrate từ SQL Server sang PostgreSQL (Render chỉ có PostgreSQL free)

---

## 🗄️ Bước 1: Chuẩn Bị Database Migration

Render chỉ hỗ trợ PostgreSQL ở free tier, nên cần migrate database.

### 1.1. Install PostgreSQL Tools (Optional - để test locally)

```bash
# Windows (nếu chưa có)
# Download từ: https://www.postgresql.org/download/windows/

# Linux/Mac
sudo apt install postgresql-client  # Linux
brew install postgresql             # Mac
```

### 1.2. Update Code (Đã được thực hiện)

✅ Backend đã được cập nhật để hỗ trợ cả SQL Server và PostgreSQL
✅ Package `Npgsql.EntityFrameworkCore.PostgreSQL` đã được thêm vào `Backend.csproj`
✅ `Program.cs` tự động detect database type từ connection string

### 1.3. Test Connection String Format

Render sẽ cung cấp connection string dạng:
```
postgresql://user:password@host:5432/dbname?sslmode=require
```

Hoặc:
```
Host=host;Port=5432;Database=dbname;Username=user;Password=password;SSL Mode=Require;
```

Backend sẽ tự động detect và sử dụng PostgreSQL provider.

---

## 🔧 Bước 2: Tạo PostgreSQL Database trên Render

1. **Đăng nhập Render**: https://render.com
   - Đăng nhập bằng GitHub account

2. **Tạo Database**:
   - Click **"New +"** → **"PostgreSQL"**
   - Settings:
     - **Name**: `my-database` (hoặc tên bạn muốn)
     - **Database**: `DataTest`
     - **User**: `mydbuser` (tự động generate)
     - **Region**: **Singapore** (gần Việt Nam nhất)
     - **PostgreSQL Version**: 15 (recommended)
     - **Plan**: **Free** (90 ngày free, sau đó $7/tháng)
   
   ⚠️ **Lưu ý**: 
   - Free tier chỉ có 90 ngày
   - Sau 90 ngày cần upgrade lên Starter ($7/tháng) hoặc xóa và tạo lại

3. **Lấy Connection String**:
   - Vào Database service → **"Connections"** tab
   - Copy **"Internal Database URL"** (dùng cho backend service)
   - Format: `postgresql://user:password@host:5432/dbname?sslmode=require`

---

## 🚀 Bước 3: Deploy Backend

### 3.1. Tạo Web Service

1. **Click "New +"** → **"Web Service"**

2. **Connect GitHub Repository**:
   - Chọn repo `test_ci-cd`
   - Branch: `main`

3. **Configure Service**:
   - **Name**: `backend-api`
   - **Region**: **Singapore**
   - **Branch**: `main`
   - **Root Directory**: (để trống hoặc `Backend`)
   - **Environment**: **Docker**
   - **Dockerfile Path**: `Backend/Dockerfile`
   - **Docker Context**: `Backend`
   - **Instance Type**: **Free** (sẽ sleep sau 15 phút)
     - ⚠️ Nếu muốn không sleep: chọn **Starter** ($7/tháng)
   - **Auto-Deploy**: **Yes** (tự động deploy khi push code)

4. **Environment Variables**:
   
   Click **"Advanced"** → Add environment variables:
   
   ```
   ASPNETCORE_ENVIRONMENT=Production
   ASPNETCORE_URLS=http://0.0.0.0:8080
   ```
   
   **Connection String** (chọn từ database):
   - Key: `ConnectionStrings__DefaultConnection`
   - Value: Click **"Link Database"** → Chọn database bạn đã tạo
   - Render sẽ tự động inject connection string
   
   **Frontend URLs** (tạm thời để trống, sẽ set sau khi frontend deploy):
   - Key: `FRONTEND_URLS`
   - Value: (sẽ set sau)

5. **Click "Create Web Service"**

6. **Chờ Build và Deploy**:
   - Render sẽ build Docker image
   - Deploy và start service
   - Thời gian: ~5-10 phút

7. **Lấy Backend URL**:
   - Sau khi deploy xong, bạn sẽ thấy URL: `https://backend-api-xxxx.onrender.com`
   - Copy URL này để dùng cho frontend

---

## 🎨 Bước 4: Deploy Frontend

### 4.1. Tạo Static Site

1. **Click "New +"** → **"Static Site"**

2. **Connect GitHub Repository**:
   - Chọn repo `test_ci-cd`
   - Branch: `main`

3. **Configure Site**:
   - **Name**: `frontend`
   - **Branch**: `main`
   - **Root Directory**: `Frontend`
   - **Build Command**: 
     ```
     npm install && npm run build
     ```
   - **Publish Directory**: `dist`
   - **Auto-Deploy**: **Yes**

4. **Environment Variables** (Optional):
   
   Nếu bạn muốn set API URL qua environment variable:
   - Key: `VITE_API_BASE_URL`
   - Value: `https://backend-api-xxxx.onrender.com` (URL từ backend service)

   ⚠️ **Lưu ý**: Frontend code hiện tại đang hardcode URL. Có thể update sau.

5. **Click "Create Static Site"**

6. **Chờ Build và Deploy**:
   - Render sẽ build frontend
   - Deploy static files
   - Thời gian: ~3-5 phút

7. **Lấy Frontend URL**:
   - Sau khi deploy xong: `https://frontend-xxxx.onrender.com`
   - Copy URL này

---

## 🔗 Bước 5: Cập Nhật CORS và API URL

### 5.1. Update Backend CORS

1. Vào **Backend Service** → **"Environment"** tab

2. Update `FRONTEND_URLS`:
   - Value: `https://frontend-xxxx.onrender.com` (URL từ frontend service)
   - Nếu có nhiều frontend URLs, dùng dấu phẩy: `url1,url2`

3. **Manual Deploy** để apply changes:
   - Click **"Manual Deploy"** → **"Deploy latest commit"**

### 5.2. Update Frontend API URL

**Option 1: Update trong code** (Recommended)

1. Update `Frontend/shared/api.ts`:
   ```typescript
   const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 
     'https://backend-api-xxxx.onrender.com';
   ```

2. Commit và push:
   ```bash
   git add Frontend/shared/api.ts
   git commit -m "Update API URL for Render"
   git push origin main
   ```

3. Render sẽ tự động redeploy

**Option 2: Sử dụng Environment Variable**

Nếu đã set `VITE_API_BASE_URL` trong step 4.1, code sẽ tự động dùng nó.

---

## 🗄️ Bước 6: Run Database Migrations

Render không tự động chạy EF migrations, cần chạy thủ công.

### Option 1: Chạy Migration qua Render Shell (Recommended)

1. Vào **Backend Service** → **"Shell"** tab

2. Run commands:
   ```bash
   cd /opt/render/project/src
   dotnet ef database update
   ```

### Option 2: Chạy Migration Locally

1. **Get Connection String từ Render**:
   - Vào Database → **"Connections"** tab
   - Copy **"External Database URL"** (cho phép kết nối từ bên ngoài)

2. **Update `appsettings.json`** (local):
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "postgresql://user:pass@host:5432/dbname?sslmode=require"
     }
   }
   ```

3. **Run migration**:
   ```bash
   cd Backend
   dotnet ef database update
   ```

### Option 3: Tự Động Tạo Database (Đơn giản nhất)

Backend code đã có logic `EnsureCreated()` tự động tạo database và tables khi start lần đầu.

✅ **Khuyến nghị**: Dùng Option 3 (tự động) để đơn giản.

---

## ✅ Bước 7: Test Deployment

### 7.1. Test Backend

```bash
# Health check
curl https://backend-api-xxxx.onrender.com/health

# Test API
curl https://backend-api-xxxx.onrender.com/api/tasks
```

### 7.2. Test Frontend

1. Mở browser: `https://frontend-xxxx.onrender.com`
2. Test các chức năng:
   - Load tasks
   - Create task
   - Update task
   - Delete task

### 7.3. Check Logs

- **Backend Logs**: Backend Service → **"Logs"** tab
- **Frontend Logs**: Frontend Service → **"Logs"** tab

---

## 🔧 Troubleshooting

### ❌ Lỗi: "Cannot connect to database"

**Nguyên nhân**: Connection string chưa đúng hoặc database chưa được link

**Giải pháp**:
1. Kiểm tra database đã được link trong backend service chưa
2. Check connection string trong Environment Variables
3. Kiểm tra database đã được tạo và running

### ❌ Lỗi: "CORS policy blocked"

**Nguyên nhân**: Frontend URL chưa được thêm vào CORS

**Giải pháp**:
1. Update `FRONTEND_URLS` environment variable trong backend
2. Manual deploy lại backend service

### ❌ Lỗi: "Table does not exist"

**Nguyên nhân**: Migration chưa chạy

**Giải pháp**:
1. Vào Backend Service → Shell
2. Run: `dotnet ef database update`
3. Hoặc backend sẽ tự tạo tables lần đầu (nếu dùng `EnsureCreated()`)

### ❌ Backend Sleep (Free Tier)

**Vấn đề**: Backend free tier sẽ sleep sau 15 phút không dùng
- Request đầu tiên sẽ mất ~30s để wake up

**Giải pháp**:
1. Upgrade lên **Starter plan** ($7/tháng) - không sleep
2. Hoặc dùng service như UptimeRobot để ping backend mỗi 5 phút

### ❌ Database Free Tier Hết Hạn

**Vấn đề**: Database free tier chỉ 90 ngày

**Giải pháp**:
1. Upgrade lên **Starter plan** ($7/tháng)
2. Hoặc backup data và tạo database mới (mất data cũ)

---

## 💰 Chi Phí

### Free Tier (90 ngày đầu):
- ✅ Backend: **FREE** (sleep sau 15 phút)
- ✅ Frontend: **FREE**
- ✅ Database: **FREE** (90 ngày)

**Tổng: $0/tháng**

### Sau 90 ngày (nếu giữ free tier):
- ✅ Backend: **FREE** (sleep)
- ✅ Frontend: **FREE**
- ❌ Database: **$7/tháng**

**Tổng: $7/tháng**

### Production (Không sleep):
- Backend: **$7/tháng** (Starter plan)
- Frontend: **FREE**
- Database: **$7/tháng**

**Tổng: $14/tháng**

---

## 🚀 Auto-Deploy với render.yaml

Nếu bạn muốn deploy tự động từ file config:

1. File `render.yaml` đã được tạo ở root của repo

2. **Deploy từ YAML**:
   - Vào Dashboard → **"New +"** → **"Blueprint"**
   - Connect repo
   - Render sẽ tự động detect và deploy từ `render.yaml`

3. **Update Environment Variables** sau khi deploy:
   - `FRONTEND_URLS` trong backend service
   - `VITE_API_BASE_URL` trong frontend service (nếu dùng)

---

## 📝 Checklist

- [ ] Tạo PostgreSQL database trên Render
- [ ] Deploy backend service
- [ ] Deploy frontend service
- [ ] Update CORS trong backend
- [ ] Update API URL trong frontend
- [ ] Run database migrations
- [ ] Test backend health check
- [ ] Test frontend
- [ ] Test tạo/sửa/xóa tasks

---

## 🎉 Hoàn Thành!

Sau khi hoàn tất, bạn sẽ có:
- ✅ Backend API: `https://backend-api-xxxx.onrender.com`
- ✅ Frontend: `https://frontend-xxxx.onrender.com`
- ✅ Database: PostgreSQL (managed by Render)
- ✅ Auto-deploy: Tự động deploy khi push code lên GitHub

**Chúc mừng! 🎊**

---

## 📚 Tài Liệu Tham Khảo

- Render Docs: https://render.com/docs
- PostgreSQL on Render: https://render.com/docs/databases
- Render Pricing: https://render.com/pricing

