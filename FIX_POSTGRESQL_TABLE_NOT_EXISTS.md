# 🔧 Fix PostgreSQL "relation Tasks does not exist" Error

## 🐛 Vấn Đề

Lỗi khi query database:
```
Npgsql.PostgresException: 42P01: relation "Tasks" does not exist
```

**Nguyên nhân:**
- Table "Tasks" chưa được tạo trong PostgreSQL database
- `EnsureCreated()` có thể chưa chạy thành công
- PostgreSQL case-sensitive naming

---

## ✅ Đã Fix

### 1. Explicit Table Name Mapping

**File:** `Backend/Backend/Data/ApplicationDbContext.cs`

Đã thêm explicit table name mapping:
```csharp
entity.ToTable("Tasks"); // Explicit table name for PostgreSQL compatibility
```

### 2. Improved Table Creation Logic

**File:** `Backend/Backend/Program.cs`

Đã cải thiện logic để:
- Verify tables exist sau khi tạo database
- Tự động tạo tables nếu database tồn tại nhưng tables chưa có
- Better error logging

---

## 🚀 Giải Pháp

### Option 1: Re-deploy Backend (Khuyến nghị)

1. **Vào Render Dashboard** → Backend Service
2. **Manual Deploy** → Deploy latest commit
3. **Đợi deploy xong** (~2-3 phút)
4. **Check logs** để verify:
   ```
   Database created successfully.
   Tables created successfully.
   Tasks table exists and is accessible.
   ```

### Option 2: Manual Table Creation (Nếu cần)

Nếu re-deploy không work, có thể tạo table thủ công:

**Vào Render Dashboard** → Database Service → **Connect** → **psql**

Chạy SQL:
```sql
CREATE TABLE IF NOT EXISTS "Tasks" (
    "Id" VARCHAR(450) PRIMARY KEY,
    "Title" VARCHAR(500) NOT NULL,
    "Description" VARCHAR(2000) NOT NULL,
    "Tag" VARCHAR(50) NOT NULL,
    "Date" VARCHAR(10) NOT NULL,
    "Time" VARCHAR(10) NOT NULL,
    "Completed" BOOLEAN NOT NULL
);
```

---

## 🔍 Verify Fix

Sau khi re-deploy, test API:

```
https://test-ci-cd-fus0.onrender.com/api/tasks
```

**Kết quả mong đợi:**
```json
[]
```

**Nếu vẫn lỗi:**
- Check Render logs để xem error messages
- Verify connection string đúng
- Check database service đang running

---

## 📋 Checklist

- [ ] Code đã được update (explicit table name)
- [ ] Re-deploy backend
- [ ] Check logs → Verify "Tables created successfully"
- [ ] Test API endpoint → `/api/tasks`
- [ ] Verify response → `[]` (empty array)

---

## 💡 Tips

1. **PostgreSQL case-sensitive:** Table names phải được quote nếu có uppercase
2. **EnsureCreated():** Tự động tạo tables dựa trên DbContext model
3. **Re-deploy:** Thường fix được hầu hết database issues
4. **Check logs:** Luôn check logs để verify database creation

---

**Sau khi re-deploy, table sẽ được tạo tự động!** 🚀

