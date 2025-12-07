# 🧪 Test Render Backend

## Kiểm Tra Backend Có Đang Chạy

### 1. Test Health Endpoint

```bash
# PowerShell
Invoke-WebRequest -Uri "https://test-ci-cd-fus0.onrender.com/health" -UseBasicParsing

# Hoặc dùng browser
# Mở: https://test-ci-cd-fus0.onrender.com/health
```

**Kết quả mong đợi:**
```json
{"status":"healthy","timestamp":"2025-12-06T..."}
```

### 2. Test API Endpoint

```bash
# PowerShell
Invoke-WebRequest -Uri "https://test-ci-cd-fus0.onrender.com/api/tasks" -UseBasicParsing

# Hoặc dùng browser
# Mở: https://test-ci-cd-fus0.onrender.com/api/tasks
```

**Kết quả mong đợi:**
```json
[]
```

---

## ⚠️ Render Free Tier - Sleep Mode

**Render free tier sẽ sleep sau 15 phút không có traffic.**

**Khi backend sleep:**
- Request đầu tiên sẽ mất ~30-60 giây để wake up
- Sau đó backend sẽ hoạt động bình thường

**Giải pháp:**
1. **Đợi ~30 giây** sau request đầu tiên
2. **Upgrade lên paid plan** ($7/tháng) để không sleep
3. **Dùng external service** để ping backend mỗi 10 phút (giữ wake)

---

## 🔍 Debug Frontend Connection

### Check Browser Console

1. Mở browser DevTools (F12)
2. Vào tab **Console**
3. Xem logs:
   ```
   API Base URL: https://test-ci-cd-fus0.onrender.com
   Environment: Development
   API Request: https://test-ci-cd-fus0.onrender.com/api/tasks GET
   ```

### Check Network Tab

1. Vào tab **Network**
2. Tìm request đến `/api/tasks`
3. Xem:
   - **Status**: 200 (OK) hoặc 503 (Service Unavailable - đang sleep)
   - **Response**: JSON data hoặc error message

---

## ✅ Đã Fix

1. ✅ Export `API_BASE_URL` từ `api.ts`
2. ✅ Import vào `Index.tsx`
3. ✅ Update error message để hiển thị đúng URL
4. ✅ Thêm thông báo về Render free tier sleep

---

**Frontend đã được update để hiển thị đúng backend URL!** 🚀

