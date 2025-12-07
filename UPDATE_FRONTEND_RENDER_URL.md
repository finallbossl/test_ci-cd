# 🔗 Update Frontend để Dùng Render Backend

## ✅ Đã Cập Nhật

### 1. Frontend API URL

**File:** `Frontend/shared/api.ts`

Đã update để dùng Render backend:
```typescript
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 
  'https://test-ci-cd-fus0.onrender.com'; // Render backend URL
```

### 2. Backend CORS

**File:** `Backend/Backend/Program.cs`

Đã thêm Render frontend URL vào CORS:
```csharp
"https://test-ci-cd-fus0.onrender.com" // Render frontend (nếu có)
```

---

## 🚀 Cách Sử Dụng

### Option 1: Dùng Code Mặc Định (Đã Update)

Frontend sẽ tự động dùng Render backend URL:
```
https://test-ci-cd-fus0.onrender.com
```

**Không cần làm gì thêm!** Chỉ cần:
1. Commit và push code
2. Deploy frontend lên Render
3. Frontend sẽ tự động connect đến backend

### Option 2: Dùng Environment Variable (Nếu Cần)

Nếu muốn override URL qua environment variable:

**Trong Render Dashboard (Frontend Service):**
- Environment Variables:
  ```
  VITE_API_BASE_URL=https://test-ci-cd-fus0.onrender.com
  ```

---

## 🔧 Cập Nhật CORS Trong Backend (Render)

### Nếu Frontend Cũng Deploy Lên Render:

1. **Vào Render Dashboard** → Backend Service
2. **Environment** tab
3. **Update `FRONTEND_URLS`:**
   ```
   FRONTEND_URLS=https://frontend-xxxx.onrender.com,https://test-ci-cd-fus0.onrender.com
   ```
   (Thêm cả frontend URL nếu có)

4. **Save Changes**
5. Backend sẽ tự động redeploy

---

## ✅ Test

### 1. Test Backend:

```bash
curl https://test-ci-cd-fus0.onrender.com/health
curl https://test-ci-cd-fus0.onrender.com/api/tasks
```

### 2. Test Frontend:

1. Mở frontend trong browser
2. Check browser console:
   ```
   API Base URL: https://test-ci-cd-fus0.onrender.com
   ```
3. Test tạo/sửa/xóa tasks

---

## 📝 Checklist

- [x] Update `Frontend/shared/api.ts` với Render backend URL
- [x] Update Backend CORS để cho phép Render frontend
- [ ] Commit và push code
- [ ] Deploy frontend lên Render (nếu chưa có)
- [ ] Update `FRONTEND_URLS` trong Backend Service (nếu frontend cũng trên Render)
- [ ] Test frontend connect đến backend

---

**Frontend đã được update để dùng Render backend!** 🚀

