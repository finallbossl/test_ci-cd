# 🔧 Fix PostgreSQL Table Name - Case Sensitivity Issue

## 🐛 Vấn Đề

Logs cho thấy:
```
Tables created successfully.
...
relation "Tasks" does not exist
```

**Nguyên nhân:**
- PostgreSQL **case-sensitive** với unquoted identifiers
- Table name "Tasks" (uppercase) không được tìm thấy
- `EnsureCreated()` có thể tạo table với tên khác hoặc không quote đúng

---

## ✅ Giải Pháp

### Đổi Table Name Thành Lowercase

**File:** `Backend/Backend/Data/ApplicationDbContext.cs`

```csharp
entity.ToTable("tasks"); // Use lowercase for PostgreSQL compatibility
```

**Lý do:**
- PostgreSQL tự động convert unquoted identifiers thành lowercase
- "Tasks" → tìm "tasks" (lowercase)
- Dùng "tasks" trực tiếp → tránh confusion

---

## 🔄 Cách Hoạt Động

### PostgreSQL Case Sensitivity:

1. **Unquoted identifiers** → Tự động lowercase
   - `Tasks` → tìm `tasks`
   - `TASKS` → tìm `tasks`

2. **Quoted identifiers** → Giữ nguyên case
   - `"Tasks"` → tìm `Tasks` (exact match)
   - `"TASKS"` → tìm `TASKS` (exact match)

3. **Best Practice:**
   - Dùng lowercase cho table names
   - Tránh quote nếu không cần thiết

---

## 🚀 Deploy và Verify

### 1. Push Code

```bash
git add .
git commit -m "Fix PostgreSQL table name to lowercase"
git push origin main
```

### 2. CI/CD Tự Động Deploy

- GitHub Actions sẽ build và deploy
- Render sẽ restart với code mới

### 3. Check Logs

Sau khi deploy, check Render logs:

**Mong đợi:**
```
Tables created successfully.
Tasks table verified and accessible after creation.
```

**Nếu vẫn lỗi:**
```
Table creation reported success but table is still not accessible.
```

---

## 🔍 Verify Table Creation

### Option 1: Check Render Logs

Vào Render Dashboard → Backend Service → Logs

Tìm:
- `Tables created successfully.`
- `Tasks table verified and accessible after creation.`

### Option 2: Test API

```
https://test-ci-cd-fus0.onrender.com/api/tasks
```

**Kết quả mong đợi:**
```json
[]
```

### Option 3: Connect to Database

Vào Render Dashboard → Database Service → Connect → psql

```sql
-- List all tables
\dt

-- Should see:
-- Schema | Name  | Type  | Owner
-- public | tasks | table | ...
```

---

## 📋 Checklist

- [ ] Code đã được update (table name = "tasks")
- [ ] Push code lên GitHub
- [ ] CI/CD deploy tự động
- [ ] Check logs → Verify "Tables created successfully"
- [ ] Check logs → Verify "Tasks table verified and accessible"
- [ ] Test API → `/api/tasks` returns `[]`

---

## 💡 Tips

1. **PostgreSQL convention:** Dùng lowercase cho table/column names
2. **Case sensitivity:** Unquoted identifiers → lowercase
3. **Verify creation:** Luôn verify table sau khi tạo
4. **Check logs:** Logs sẽ cho biết table có được tạo không

---

**Sau khi deploy với table name "tasks", vấn đề sẽ được fix!** 🚀



