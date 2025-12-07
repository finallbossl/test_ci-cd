# 🔄 Chạy Migration Trên Render

Hướng dẫn chạy Entity Framework migrations trên Render để tạo database tables.

---

## 🎯 Vấn Đề

Lỗi: `relation "tasks" does not exist`

**Nguyên nhân:**
- Table `tasks` chưa được tạo trong PostgreSQL database
- `EnsureCreated()` không hoạt động đúng với migrations

**Giải pháp:**
- Sử dụng `Database.Migrate()` để tự động chạy migrations
- Hoặc chạy migration thủ công qua Render Shell

---

## ✅ Giải Pháp 1: Tự Động (Đã Cập Nhật Code)

Code đã được cập nhật để tự động chạy migrations khi start:

```csharp
await context.Database.MigrateAsync();
```

**Cách hoạt động:**
1. Backend start → Tự động check pending migrations
2. Nếu có migrations chưa chạy → Tự động apply
3. Table `tasks` sẽ được tạo tự động

**Sau khi deploy:**
- Backend sẽ tự động chạy migrations
- Check logs để xác nhận: `"Database migrations applied successfully"`

---

## 🔧 Giải Pháp 2: Chạy Thủ Công Qua Render Shell

Nếu tự động không work, chạy thủ công:

### Bước 1: Vào Render Shell

1. Vào **Render Dashboard**
2. Chọn **Backend Service** → **"Shell"** tab
3. Click **"Open Shell"**

### Bước 2: Chạy Migration

```bash
# Navigate to project directory
cd /opt/render/project/src/Backend/Backend

# Run migration
dotnet ef database update
```

**Hoặc nếu path khác:**

```bash
# Find project directory
find /opt/render/project -name "*.csproj" -type f

# Navigate to Backend directory
cd /opt/render/project/src/Backend/Backend

# Run migration
dotnet ef database update
```

### Bước 3: Verify

```bash
# Check if table exists (via psql if available)
# Or check backend logs after restart
```

---

## 🔧 Giải Pháp 3: Chạy Migration Từ Local Machine

### Bước 1: Get Connection String

1. Vào **Render Dashboard** → **Database** → **"Connections"** tab
2. Copy **"External Database URL"** (cho phép kết nối từ bên ngoài)

### Bước 2: Set Connection String Locally

**Option A: Environment Variable**

```bash
# Windows PowerShell
$env:ConnectionStrings__DefaultConnection="postgresql://user:pass@host:5432/dbname?sslmode=require"

# Linux/Mac
export ConnectionStrings__DefaultConnection="postgresql://user:pass@host:5432/dbname?sslmode=require"
```

**Option B: appsettings.json** (temporary)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "postgresql://user:pass@host:5432/dbname?sslmode=require"
  }
}
```

### Bước 3: Run Migration

```bash
cd Backend/Backend
dotnet ef database update
```

### Bước 4: Remove Connection String

Sau khi chạy xong, xóa connection string khỏi `appsettings.json` (nếu đã thêm).

---

## 🔍 Kiểm Tra Migration Status

### Check Logs trên Render

Sau khi deploy, check **Backend Service** → **"Logs"** tab:

**Thành công:**
```
✅ Applying database migrations...
✅ Database migrations applied successfully.
✅ Tasks table exists and is accessible after migration.
```

**Lỗi:**
```
❌ Failed to apply migrations. Error: ...
```

### Test API

```bash
# Test GET /api/tasks
curl https://test-ci-cd-fus0.onrender.com/api/tasks

# Should return: [] (empty array, not error)
```

---

## 🐛 Troubleshooting

### Lỗi: "No migrations found"

**Nguyên nhân:** Migration files không có trong Docker image

**Giải pháp:**
1. Đảm bảo `Migrations/` folder được copy vào Docker
2. Check `Dockerfile` có copy migrations:

```dockerfile
COPY Backend.csproj ./
COPY . ./
# This should include Migrations/ folder
```

### Lỗi: "Migration already applied"

**Nguyên nhân:** Migration đã chạy nhưng table vẫn không có

**Giải pháp:**
1. Drop và recreate database (nếu có thể)
2. Hoặc drop table và chạy lại migration:

```sql
-- Via Render Shell hoặc psql
DROP TABLE IF EXISTS "tasks" CASCADE;
DROP TABLE IF EXISTS "__EFMigrationsHistory" CASCADE;
```

Sau đó restart backend để migration chạy lại.

### Lỗi: "Table name case mismatch"

**Nguyên nhân:** PostgreSQL case-sensitive, migration tạo "Tasks" nhưng code tìm "tasks"

**Giải pháp:** ✅ Đã fix - Migration đã được update để tạo table `tasks` (lowercase)

---

## 📋 Checklist

- [ ] Code đã được update để dùng `Database.Migrate()`
- [ ] Migration file đã được update (table name = "tasks")
- [ ] Backend đã deploy lên Render
- [ ] Check logs thấy "Database migrations applied successfully"
- [ ] Test API: `GET /api/tasks` trả về `[]` (không lỗi)

---

## 🚀 Quick Fix (Nếu Cần Ngay)

Nếu cần fix ngay, chạy SQL trực tiếp:

```sql
-- Via Render Database → "Connect" → psql
CREATE TABLE IF NOT EXISTS tasks (
    "Id" text PRIMARY KEY,
    "Title" character varying(500) NOT NULL,
    "Description" character varying(2000),
    "Tag" character varying(50) NOT NULL,
    "Date" character varying(10) NOT NULL,
    "Time" character varying(10) NOT NULL,
    "Completed" boolean NOT NULL
);
```

Sau đó restart backend.

---

## ✅ Kết Luận

**Cách tốt nhất:**
1. ✅ Code đã tự động chạy migrations khi start
2. ✅ Deploy lại backend
3. ✅ Check logs để verify

**Nếu không work:**
- Chạy migration thủ công qua Render Shell
- Hoặc chạy từ local machine với connection string từ Render
