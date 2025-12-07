# 🔧 Fix Render Connection String Error

## ❌ Lỗi:

```
System.ArgumentException: Format of the initialization string does not conform to specification starting at index 0.
```

## 🔍 Nguyên Nhân:

Render inject connection string từ database service nhưng format có thể không đúng với Npgsql.

### Vấn Đề:

1. **Render inject connection string** từ `fromDatabase` trong `render.yaml`
2. **Format có thể là URI**: `postgresql://user:pass@host:port/db`
3. **Npgsql cần format**: `Host=host;Port=port;Database=db;Username=user;Password=pass`

---

## ✅ Giải Pháp 1: Set Connection String Thủ Công (Recommended)

### Bước 1: Lấy Connection String từ Render

1. Vào **Render Dashboard** → **Database Service** (`my-database`)
2. **Connections** tab
3. Copy **"Internal Database URL"** (dùng cho services trong cùng Render)
   - Format: `postgresql://user:password@host:5432/dbname?sslmode=require`

### Bước 2: Set Trong Backend Service

1. Vào **Backend Service** → **Environment** tab
2. Tìm hoặc tạo variable: `ConnectionStrings__DefaultConnection`
3. **Paste connection string** bạn đã copy
4. **Save Changes**

### Bước 3: Remove fromDatabase từ render.yaml (Nếu Có)

Nếu bạn dùng `render.yaml`, comment hoặc xóa phần `fromDatabase`:

```yaml
envVars:
  - key: ConnectionStrings__DefaultConnection
    # fromDatabase:
    #   name: my-database
    #   property: connectionString
    sync: false  # Set manually in dashboard
```

---

## ✅ Giải Pháp 2: Dùng Connection String Đã Có

Bạn đã có connection string:

```
postgresql://db_test_ip24_user:JdETR5HQymycpyM7qHay0vxQcpFnBhtl@dpg-d4qcvm8gjchc73ba1m9g-a.singapore-postgres.render.com/db_test_ip24
```

### Set Trong Render Dashboard:

1. **Backend Service** → **Environment**
2. Add/Update:
   ```
   ConnectionStrings__DefaultConnection=postgresql://db_test_ip24_user:JdETR5HQymycpyM7qHay0vxQcpFnBhtl@dpg-d4qcvm8gjchc73ba1m9g-a.singapore-postgres.render.com/db_test_ip24
   ```
3. **Save Changes**
4. **Manual Deploy**

---

## ✅ Giải Pháp 3: Code Đã Tự Động Parse (Đã Fix)

Code đã được update để tự động convert PostgreSQL URI format sang Npgsql format.

**Nếu vẫn lỗi:**
- Set connection string thủ công trong dashboard (Giải pháp 1 hoặc 2)

---

## 🔍 Kiểm Tra Connection String

### Trong Render Logs:

1. Vào **Backend Service** → **Logs**
2. Tìm dòng: `Connection string: ...`
3. Kiểm tra format

### Format Đúng:

**PostgreSQL URI (Render format):**
```
postgresql://user:pass@host:5432/dbname?sslmode=require
```

**Npgsql format (sau khi parse):**
```
Host=host;Port=5432;Database=dbname;Username=user;Password=pass;SSL Mode=Require
```

---

## 📝 Quick Fix Steps

1. **Vào Render Dashboard** → Backend Service
2. **Environment** tab
3. **Set connection string thủ công:**
   ```
   ConnectionStrings__DefaultConnection=postgresql://db_test_ip24_user:JdETR5HQymycpyM7qHay0vxQcpFnBhtl@dpg-d4qcvm8gjchc73ba1m9g-a.singapore-postgres.render.com/db_test_ip24
   ```
4. **Save Changes**
5. **Manual Deploy**
6. ✅ **Done!**

---

## ⚠️ Lưu Ý

- **Connection string chứa password** - không commit vào Git
- **Chỉ set trong Render dashboard** Environment Variables
- **Code đã tự động parse** PostgreSQL URI format

---

**Set connection string thủ công trong Render dashboard sẽ fix lỗi này!** 🚀

