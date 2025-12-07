# 🗄️ Chạy Migration Trên Render

## 🐛 Vấn Đề

Table "tasks" chưa được tạo trong PostgreSQL database trên Render.

---

## ✅ Giải Pháp: Chạy Migration

### Cách 1: Qua Render Shell (Khuyến Nghị)

1. **Vào Render Dashboard:**
   - https://dashboard.render.com
   - Chọn **Backend Service** (backend-api)

2. **Vào tab "Shell":**
   - Click **"Shell"** tab ở trên cùng

3. **Chạy migration:**
   ```bash
   cd /opt/render/project/src/Backend
   dotnet ef database update
   ```

   **Nếu không tìm thấy `dotnet ef`:**
   ```bash
   # Install EF tools
   dotnet tool install --global dotnet-ef
   export PATH="$PATH:/root/.dotnet/tools"
   
   # Run migration
   dotnet ef database update
   ```

4. **Verify table được tạo:**
   ```bash
   # Connect to database và check
   psql $DATABASE_URL -c "\dt"
   ```

---

### Cách 2: Qua Database Shell

1. **Vào Render Dashboard:**
   - Chọn **Database Service** (my-database)

2. **Vào tab "Connect":**
   - Click **"Connect"** tab
   - Chọn **"psql"**

3. **Chạy SQL để tạo table:**
   ```sql
   CREATE TABLE IF NOT EXISTS tasks (
       "Id" VARCHAR(450) PRIMARY KEY,
       "Title" VARCHAR(500) NOT NULL,
       "Description" VARCHAR(2000) NOT NULL,
       "Tag" VARCHAR(50) NOT NULL,
       "Date" VARCHAR(10) NOT NULL,
       "Time" VARCHAR(10) NOT NULL,
       "Completed" BOOLEAN NOT NULL
   );
   
   -- Verify
   \dt
   ```

---

### Cách 3: Tự Động Qua Code (Đã Cập Nhật)

Code đã được update để tự động tạo tables nếu chưa có.

**Sau khi deploy lại:**
- Backend sẽ tự động detect table chưa có
- Tự động tạo table "tasks"
- Verify table sau khi tạo

---

## 🔍 Verify Migration

### Check Logs:

Sau khi chạy migration, check logs sẽ thấy:
```
Tables created successfully using EnsureCreated.
Tasks table verified and accessible after creation.
```

### Test API:

```
https://test-ci-cd-fus0.onrender.com/api/tasks
```

**Kết quả mong đợi:**
```json
[]
```

---

## 📋 Checklist

- [ ] Vào Render Shell hoặc Database Shell
- [ ] Chạy migration hoặc SQL
- [ ] Verify table được tạo
- [ ] Test API endpoint
- [ ] Check logs để confirm

---

## 💡 Tips

1. **Render Shell:** Có thể chạy commands như local
2. **Database Shell:** Có thể chạy SQL trực tiếp
3. **Auto-create:** Code sẽ tự động tạo nếu chưa có (sau khi deploy lại)

---

**Sau khi chạy migration, table sẽ được tạo và API sẽ hoạt động!** 🚀

