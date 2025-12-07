# 🐛 Debug Render Backend Error

## 🔍 Kiểm Tra Backend

### 1. Test Health Endpoint

Mở browser và truy cập:
```
https://test-ci-cd-fus0.onrender.com/health
```

**Kết quả mong đợi:**
```json
{"status":"healthy","timestamp":"2025-12-06T..."}
```

**Nếu lỗi:**
- **503 Service Unavailable** → Backend đang sleep (đợi ~30s)
- **500 Internal Server Error** → Backend có lỗi (check logs)
- **404 Not Found** → Endpoint không tồn tại

---

### 2. Test API Endpoint

Mở browser và truy cập:
```
https://test-ci-cd-fus0.onrender.com/api/tasks
```

**Kết quả mong đợi:**
```json
[]
```

**Nếu lỗi:**
- **500 Internal Server Error** → Database connection issue hoặc backend error
- **CORS error** → CORS chưa được cấu hình đúng

---

### 3. Check Browser Console

1. Mở browser DevTools (F12)
2. Vào tab **Console**
3. Xem error messages:
   ```
   API Error: {url: '...', status: 500, error: {...}}
   ```

4. Vào tab **Network**
5. Tìm request đến `/api/tasks`
6. Xem:
   - **Status Code**: 200, 500, 503, etc.
   - **Response**: JSON error message

---

## 🔧 Các Lỗi Thường Gặp

### Lỗi 1: Backend Sleep (503)

**Triệu chứng:**
- Request mất ~30-60 giây
- Status: 503 Service Unavailable
- Response: "Service Unavailable"

**Giải pháp:**
1. Đợi ~30 giây
2. Click "Retry" lại
3. Backend sẽ wake up và hoạt động bình thường

---

### Lỗi 2: Database Connection Error (500)

**Triệu chứng:**
- Status: 500 Internal Server Error
- Response: `{"message":"An error occurred while retrieving tasks"}`

**Nguyên nhân:**
- PostgreSQL connection string sai
- Database chưa được tạo
- Database đang sleep (free tier)

**Giải pháp:**

1. **Check Render Dashboard:**
   - Vào Backend Service → Logs
   - Xem error messages về database

2. **Check Connection String:**
   - Vào Backend Service → Environment
   - Verify `ConnectionStrings__DefaultConnection`

3. **Check Database:**
   - Vào Database Service → Logs
   - Verify database đang chạy

4. **Re-deploy Backend:**
   - Vào Backend Service → Manual Deploy
   - Backend sẽ tự động tạo database nếu chưa có

---

### Lỗi 3: CORS Error

**Triệu chứng:**
- Browser console: `CORS policy: No 'Access-Control-Allow-Origin' header`
- Network tab: Status 200 nhưng response bị block

**Giải pháp:**

1. **Check CORS Configuration:**
   - Vào Backend Service → Environment
   - Verify `FRONTEND_URLS` có chứa frontend URL

2. **Update FRONTEND_URLS:**
   ```
   FRONTEND_URLS=http://localhost:8080,http://localhost:5173,https://your-frontend.onrender.com
   ```

3. **Re-deploy Backend:**
   - Save changes
   - Backend sẽ restart với CORS mới

---

## 📋 Checklist Debug

- [ ] Test health endpoint: `/health`
- [ ] Test API endpoint: `/api/tasks`
- [ ] Check browser console errors
- [ ] Check browser network tab
- [ ] Check Render backend logs
- [ ] Check Render database logs
- [ ] Verify connection string
- [ ] Verify CORS configuration
- [ ] Check if backend is sleeping

---

## 🚀 Quick Fix

### Nếu Backend Sleep:

1. **Đợi ~30 giây** sau request đầu tiên
2. **Click "Retry"** trong frontend
3. Backend sẽ wake up

### Nếu Database Error:

1. **Vào Render Dashboard** → Backend Service
2. **Logs tab** → Xem error messages
3. **Environment tab** → Verify connection string
4. **Manual Deploy** → Re-deploy backend

### Nếu CORS Error:

1. **Vào Render Dashboard** → Backend Service
2. **Environment tab** → Update `FRONTEND_URLS`
3. **Save Changes** → Backend sẽ restart

---

**Kiểm tra từng bước để tìm nguyên nhân!** 🔍



