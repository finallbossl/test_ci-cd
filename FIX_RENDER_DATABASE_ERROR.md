# 🔧 Fix Render Database Error - "An error occurred while retrieving tasks"

## 🐛 Vấn Đề

Khi test API endpoint `https://test-ci-cd-fus0.onrender.com/api/tasks`, nhận được:
```json
{
  "message": "An error occurred while retrieving tasks"
}
```

**Status Code:** 500 Internal Server Error

---

## 🔍 Nguyên Nhân

Lỗi này xảy ra khi backend không thể kết nối hoặc query database. Có thể do:

1. **Database chưa được tạo** - Backend chưa chạy `EnsureCreated()`
2. **Connection string sai** - PostgreSQL connection string không đúng
3. **Database đang sleep** - PostgreSQL free tier có thể sleep
4. **Table chưa được tạo** - Migration chưa chạy

---

## ✅ Giải Pháp

### Bước 1: Check Render Backend Logs

1. **Vào Render Dashboard:**
   - https://dashboard.render.com
   - Chọn **Backend Service** (backend-api)

2. **Vào tab Logs:**
   - Xem error messages về database
   - Tìm các dòng như:
     ```
     Error getting tasks: ...
     Cannot connect to database
     Failed to create database
     ```

### Bước 2: Check Database Connection

1. **Vào Backend Service** → **Environment** tab
2. **Verify `ConnectionStrings__DefaultConnection`:**
   - Phải có format: `postgresql://...` hoặc `Host=...;Database=...`
   - Database name phải đúng

3. **Vào Database Service** → **Logs** tab
   - Verify database đang chạy
   - Xem có error messages không

### Bước 3: Re-deploy Backend

**Cách 1: Manual Deploy (Khuyến nghị)**

1. **Vào Backend Service** → **Manual Deploy**
2. **Click "Deploy latest commit"**
3. **Đợi deploy xong** (~2-3 phút)
4. **Backend sẽ tự động:**
   - Kết nối database
   - Tạo database nếu chưa có
   - Tạo tables nếu chưa có

**Cách 2: Trigger Deploy Hook**

Nếu có Deploy Hook URL:
```bash
curl -X POST "https://api.render.com/deploy/srv-xxx?key=xxx"
```

### Bước 4: Verify Database Creation

Sau khi re-deploy, check logs:

**Tìm các dòng:**
```
Checking database connection...
Database does not exist. Creating database...
Database created successfully.
```

**Hoặc:**
```
Database connection successful.
```

---

## 🔧 Troubleshooting

### Lỗi 1: "Cannot connect to database"

**Nguyên nhân:**
- Connection string sai
- Database service chưa start
- Network issue

**Giải pháp:**
1. **Check connection string** trong Environment variables
2. **Verify database service** đang running
3. **Re-deploy backend**

### Lỗi 2: "Failed to create database"

**Nguyên nhân:**
- Database đã tồn tại nhưng không accessible
- Permission issue
- Connection timeout

**Giải pháp:**
1. **Check database logs** trong Render Dashboard
2. **Verify database service** đang running
3. **Try manual deploy** lại

### Lỗi 3: "Table 'Tasks' does not exist"

**Nguyên nhân:**
- Database được tạo nhưng tables chưa được tạo
- `EnsureCreated()` chưa chạy thành công

**Giải pháp:**
1. **Re-deploy backend** - `EnsureCreated()` sẽ chạy lại
2. **Check logs** để verify tables được tạo

---

## 📋 Checklist

- [ ] Check Render backend logs
- [ ] Verify connection string trong Environment
- [ ] Check database service logs
- [ ] Verify database service đang running
- [ ] Re-deploy backend
- [ ] Check logs sau deploy để verify database creation
- [ ] Test API endpoint lại: `/api/tasks`

---

## 🚀 Quick Fix

**Nếu không chắc chắn, làm theo thứ tự:**

1. **Vào Render Dashboard** → Backend Service
2. **Manual Deploy** → Deploy latest commit
3. **Đợi deploy xong** (~2-3 phút)
4. **Check logs** → Verify "Database created successfully"
5. **Test API** → `https://test-ci-cd-fus0.onrender.com/api/tasks`

**Backend sẽ tự động tạo database và tables!** ✅

---

## 💡 Tips

1. **Luôn check logs trước** khi debug
2. **Re-deploy backend** thường fix được hầu hết database issues
3. **Database free tier có thể sleep** - đợi ~30s sau request đầu tiên
4. **Connection string phải đúng format** - Render tự động inject nếu dùng `fromDatabase`

---

**Sau khi re-deploy, database sẽ được tạo tự động!** 🚀

