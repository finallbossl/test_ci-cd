# 🚀 Deploy Ngay Lên Render - Hướng Dẫn Nhanh

Bạn đã có connection string PostgreSQL từ Render, giờ deploy ngay!

## 📋 Connection String của bạn:

```
postgresql://db_test_ip24_user:JdETR5HQymycpyM7qHay0vxQcpFnBhtl@dpg-d4qcvm8gjchc73ba1m9g-a.singapore-postgres.render.com/db_test_ip24
```

---

## ⚡ Deploy Backend (5 phút)

### Bước 1: Tạo Web Service trên Render

1. **Truy cập**: https://dashboard.render.com
2. **Click "New +"** → **"Web Service"**
3. **Connect GitHub Repository**:
   - Chọn repo: `test_ci-cd`
   - Branch: `main`

### Bước 2: Configure Service

**Basic Settings:**
- **Name**: `backend-api` (hoặc tên bạn muốn)
- **Region**: **Singapore** (đã đúng - database ở Singapore)
- **Branch**: `main`
- **Root Directory**: (để trống)
- **Environment**: **Docker**
- **Dockerfile Path**: `Backend/Dockerfile`
- **Docker Context**: `Backend`
- **Instance Type**: **Free** (sẽ sleep sau 15 phút)
- **Auto-Deploy**: **Yes** ✅

### Bước 3: Set Environment Variables

Click **"Advanced"** → Add các environment variables:

```
ASPNETCORE_ENVIRONMENT=Production
```

```
ASPNETCORE_URLS=http://0.0.0.0:8080
```

```
ConnectionStrings__DefaultConnection=postgresql://db_test_ip24_user:JdETR5HQymycpyM7qHay0vxQcpFnBhtl@dpg-d4qcvm8gjchc73ba1m9g-a.singapore-postgres.render.com/db_test_ip24
```

⚠️ **Copy chính xác connection string của bạn!**

```
FRONTEND_URLS=
```
(Để trống tạm thời, sẽ set sau khi deploy frontend)

### Bước 4: Deploy

1. Click **"Create Web Service"**
2. Render sẽ bắt đầu build Docker image
3. Chờ ~5-10 phút để build và deploy
4. ✅ **Copy Backend URL**: `https://backend-api-xxxx.onrender.com`

---

## 🎨 Deploy Frontend (3 phút)

### Bước 1: Tạo Static Site

1. **Click "New +"** → **"Static Site"**
2. **Connect GitHub Repository**:
   - Repo: `test_ci-cd`
   - Branch: `main`

### Bước 2: Configure

- **Name**: `frontend`
- **Branch**: `main`
- **Root Directory**: `Frontend`
- **Build Command**: 
  ```
  npm install && npm run build
  ```
- **Publish Directory**: `dist`
- **Auto-Deploy**: **Yes** ✅

### Bước 3: Set Environment Variable

**Optional** (nếu muốn dùng env variable):
- Key: `VITE_API_BASE_URL`
- Value: `https://backend-api-xxxx.onrender.com` (URL từ backend service)

### Bước 4: Deploy

1. Click **"Create Static Site"**
2. Chờ build (~3-5 phút)
3. ✅ **Copy Frontend URL**: `https://frontend-xxxx.onrender.com`

---

## 🔗 Cập Nhật CORS

### Bước 1: Update Backend CORS

1. Vào **Backend Service** → **"Environment"** tab
2. Tìm hoặc add variable: `FRONTEND_URLS`
3. **Value**: `https://frontend-xxxx.onrender.com` (URL từ frontend)
4. Click **"Save Changes"**
5. Render sẽ tự động redeploy

### Bước 2: Update Frontend API URL (Nếu cần)

**Option 1: Dùng Environment Variable** (Đã set ở bước trên)

**Option 2: Update trong code**:

1. Edit `Frontend/shared/api.ts`:
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

---

## 🗄️ Database Migration

Backend sẽ tự động tạo database và tables lần đầu chạy (vì code có `EnsureCreated()`).

✅ **Không cần chạy migration thủ công!**

Nếu muốn chạy migration thủ công:

1. Vào **Backend Service** → **"Shell"** tab
2. Run:
   ```bash
   cd /opt/render/project/src
   dotnet ef database update
   ```

---

## ✅ Test Deployment

### Test Backend:

```bash
# Health check
curl https://backend-api-xxxx.onrender.com/health

# Test API
curl https://backend-api-xxxx.onrender.com/api/tasks
```

### Test Frontend:

1. Mở browser: `https://frontend-xxxx.onrender.com`
2. Test:
   - ✅ Load tasks
   - ✅ Create task
   - ✅ Update task
   - ✅ Delete task

---

## 📊 Kiểm Tra Logs

### Backend Logs:
- Vào **Backend Service** → **"Logs"** tab
- Kiểm tra:
  - ✅ Database connection successful
  - ✅ Application started
  - ✅ Listening on http://0.0.0.0:8080

### Frontend Logs:
- Vào **Frontend Service** → **"Logs"** tab
- Kiểm tra build thành công

---

## ⚠️ Lưu Ý Quan Trọng

1. **Backend Free Tier**: 
   - Sẽ **sleep sau 15 phút** không có request
   - Request đầu tiên sau khi sleep sẽ mất **~30 giây** để wake up
   - ✅ Để không sleep: Upgrade lên **Starter plan** ($7/tháng)

2. **Database Name**: 
   - Database của bạn: `db_test_ip24`
   - Backend sẽ tự tạo tables trong database này

3. **Connection String Security**:
   - ⚠️ **KHÔNG commit connection string vào Git!**
   - Chỉ set trong Render dashboard Environment Variables

4. **Auto-Deploy**:
   - ✅ Tự động deploy khi push code lên `main` branch
   - ✅ Backend và Frontend sẽ tự động rebuild và redeploy

---

## 🐛 Troubleshooting

### ❌ Lỗi: "Cannot connect to database"

**Giải pháp**:
1. Kiểm tra connection string đã được copy đúng chưa
2. Kiểm tra database service đang running trên Render
3. Check logs trong Backend Service → Logs

### ❌ Lỗi: "CORS policy blocked"

**Giải pháp**:
1. Update `FRONTEND_URLS` trong Backend Service → Environment
2. Save và chờ redeploy
3. Đảm bảo frontend URL đúng (có https://)

### ❌ Backend không start

**Giải pháp**:
1. Check Logs trong Backend Service
2. Kiểm tra Dockerfile path: `Backend/Dockerfile`
3. Kiểm tra Docker context: `Backend`

---

## 🎉 Hoàn Thành!

Sau khi deploy xong, bạn sẽ có:

- ✅ **Backend API**: `https://backend-api-xxxx.onrender.com`
- ✅ **Frontend**: `https://frontend-xxxx.onrender.com`
- ✅ **Database**: PostgreSQL (managed by Render)
- ✅ **Auto-deploy**: Tự động khi push code

**Chúc mừng! 🚀**

