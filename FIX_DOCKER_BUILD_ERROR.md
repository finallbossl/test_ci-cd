# 🔧 Fix Lỗi Docker Build: "Backend.csproj not found"

## ❌ Lỗi:

```
error: failed to solve: failed to compute cache key: failed to calculate checksum of ref
"/Backend.csproj": not found
```

## 🔍 Nguyên Nhân:

**Docker build context không đúng!**

### Cấu Trúc Thư Mục:
```
Backend/
  Backend/              ← Dockerfile và Backend.csproj ở đây
    Backend.csproj
    Dockerfile
    Program.cs
    ...
  .github/workflows/
```

### Vấn Đề:

1. **GitHub Actions workflow** set:
   - `context: ./Backend` ❌
   - `file: ./Backend/Dockerfile` ❌

2. **Dockerfile** expect:
   - `Backend.csproj` ở root của context
   - Nhưng file thực tế ở `Backend/Backend/Backend.csproj`

3. **Kết quả**: Docker không tìm thấy file!

---

## ✅ Giải Pháp:

### Đã Fix Các Files:

1. ✅ **`.github/workflows/deploy-production-self-hosted.yml`**
   ```yaml
   context: ./Backend/Backend      # Sửa từ ./Backend
   file: ./Backend/Backend/Dockerfile  # Sửa từ ./Backend/Dockerfile
   ```

2. ✅ **`.github/workflows/deploy-production.yml`**
   ```yaml
   context: ./Backend/Backend      # Sửa từ ./Backend
   file: ./Backend/Backend/Dockerfile  # Sửa từ ./Backend/Dockerfile
   ```

3. ✅ **`render.yaml`**
   ```yaml
   dockerfilePath: ./Backend/Backend/Dockerfile  # Sửa từ ./Backend/Dockerfile
   dockerContext: ./Backend/Backend              # Sửa từ ./Backend
   ```

---

## 🚀 Tiếp Theo:

1. **Commit và push các thay đổi**:
   ```bash
   git add .github/workflows/*.yml render.yaml
   git commit -m "Fix Docker build context path"
   git push origin main
   ```

2. **GitHub Actions sẽ tự động trigger lại** và build thành công!

---

## 📝 Giải Thích:

### Docker Context là gì?

**Context** là thư mục gốc mà Docker dùng để build. Tất cả files trong Dockerfile (COPY, ADD) đều relative với context.

### Ví Dụ:

```yaml
# ❌ SAI - Context là ./Backend
context: ./Backend
# Docker sẽ tìm Backend.csproj ở ./Backend/Backend.csproj
# Nhưng file thực tế ở ./Backend/Backend/Backend.csproj

# ✅ ĐÚNG - Context là ./Backend/Backend  
context: ./Backend/Backend
# Docker sẽ tìm Backend.csproj ở ./Backend/Backend/Backend.csproj
# File có thực sự ở đó! ✅
```

---

## ✅ Kết Quả:

Sau khi fix, Docker build sẽ:
1. ✅ Tìm thấy `Backend.csproj`
2. ✅ Build thành công
3. ✅ Push image lên GHCR
4. ✅ Deploy thành công

---

**Lỗi đã được fix! Commit và push lại để test! 🚀**



