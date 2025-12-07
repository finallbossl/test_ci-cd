# 🔧 Fix Lỗi Docker Build Trên Render

## ❌ Lỗi:

```
failed to solve: failed to compute cache key: failed to calculate checksum of ref
"/Backend.csproj": not found
```

## 🔍 Nguyên Nhân:

Render đang build Docker nhưng không tìm thấy `Backend.csproj` vì **dockerContext path không đúng**.

### Cấu Trúc Repo Trên Render:

Render clone repo và cấu trúc có thể là:

**Option 1: Repo root = `Backend/`**
```
Backend/                    ← Repo root
  Backend/                  ← Code ở đây
    Backend.csproj
    Dockerfile
    Program.cs
  .github/
  render.yaml
```

**Option 2: Repo root = `test/`**
```
test/                       ← Repo root
  Backend/
    Backend/
      Backend.csproj
      Dockerfile
  Frontend/
  render.yaml
```

---

## ✅ Giải Pháp:

### Nếu Deploy Qua Dashboard (Manual):

1. **Vào Render Dashboard** → Backend Service → **Settings**

2. **Check cấu trúc repo:**
   - Xem **Repository** → Branch
   - Render sẽ clone toàn bộ repo

3. **Set Docker Paths:**

   **Nếu repo root là `Backend/`:**
   - **Dockerfile Path**: `Backend/Dockerfile`
   - **Docker Context**: `Backend`

   **Nếu repo root là `test/`:**
   - **Dockerfile Path**: `Backend/Backend/Dockerfile`
   - **Docker Context**: `Backend/Backend`

### Nếu Deploy Qua render.yaml:

Đã update `render.yaml` với path phù hợp nhất:

```yaml
dockerfilePath: ./Backend/Dockerfile
dockerContext: ./Backend
```

Nếu vẫn lỗi, thử:

```yaml
dockerfilePath: ./Backend/Backend/Dockerfile
dockerContext: ./Backend/Backend
```

---

## 🔍 Cách Kiểm Tra Cấu Trúc Repo:

### Trên Render Dashboard:

1. Vào **Backend Service** → **Events** tab
2. Xem build logs đầu tiên
3. Tìm dòng: `Cloning repository...`
4. Check xem Render clone từ đâu

### Hoặc:

1. Vào **Backend Service** → **Shell** tab
2. Run:
   ```bash
   pwd
   ls -la
   find . -name "Dockerfile" -type f
   find . -name "Backend.csproj" -type f
   ```

---

## ✅ Fix Trong Dashboard:

1. **Vào Render Dashboard**: https://dashboard.render.com
2. **Chọn Backend Service**
3. **Settings** → Scroll xuống **Docker**
4. **Dockerfile Path**: 
   - Thử: `Backend/Dockerfile`
   - Hoặc: `Backend/Backend/Dockerfile`
5. **Docker Context**: 
   - Thử: `Backend`
   - Hoặc: `Backend/Backend`
6. **Save Changes**
7. **Manual Deploy** để test

---

## 📝 Lưu Ý:

### Root Directory:

Nếu bạn đã set **Root Directory** trong Render:
- Root Directory: `Backend`
- Dockerfile Path: `Dockerfile` (relative to root)
- Docker Context: `.` (current directory = Backend)

### Không Có Root Directory:

- Dockerfile Path: `Backend/Dockerfile` hoặc `Backend/Backend/Dockerfile`
- Docker Context: `Backend` hoặc `Backend/Backend`

---

## 🎯 Quick Fix:

**Thử các combination sau (theo thứ tự):**

1. **Config 1** (Nếu repo root = `Backend/`):
   ```
   Root Directory: (để trống)
   Dockerfile Path: Backend/Dockerfile
   Docker Context: Backend
   ```

2. **Config 2** (Nếu repo root = `test/`):
   ```
   Root Directory: (để trống)
   Dockerfile Path: Backend/Backend/Dockerfile
   Docker Context: Backend/Backend
   ```

3. **Config 3** (Nếu set Root Directory):
   ```
   Root Directory: Backend
   Dockerfile Path: Dockerfile
   Docker Context: .
   ```

4. **Config 4** (Nếu set Root Directory nested):
   ```
   Root Directory: Backend/Backend
   Dockerfile Path: Dockerfile
   Docker Context: .
   ```

---

## ✅ Sau Khi Fix:

1. **Save Changes** trong Render
2. **Manual Deploy** để test
3. **Check logs** để xem build thành công
4. **Nếu thành công**: Enable **Auto-Deploy**

---

**Thử Config 1 trước (phổ biến nhất)! Nếu không được, thử các config khác.** 🚀

