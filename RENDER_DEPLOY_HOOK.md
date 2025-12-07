# 🚀 Render Deploy Hook - Tự Động Deploy

## 📋 Deploy Hook URL

```
https://api.render.com/deploy/srv-d4qd2jre5dus73eljgt0?key=ibd9zEAJO4A
```

## 🎯 Cách Sử Dụng

### 1. Manual Trigger (Test)

```bash
curl -X POST "https://api.render.com/deploy/srv-d4qd2jre5dus73eljgt0?key=ibd9zEAJO4A"
```

**Response:**
```json
{"deploy":{"id":"dep-d4qdufkhg0os738858n0"}}
```

### 2. Tích Hợp Vào GitHub Actions

Đã được thêm vào `.github/workflows/deploy-render.yml`:

```yaml
- name: Trigger Render Deploy Hook
  run: |
    curl -X POST "https://api.render.com/deploy/srv-d4qd2jre5dus73eljgt0?key=ibd9zEAJO4A"
```

**Khi nào trigger:**
- ✅ Sau khi build Docker image thành công
- ✅ Chỉ trên branch `main` hoặc `master`
- ✅ Tự động khi push code

---

## 🔄 Workflow Hoàn Chỉnh

```
Push Code
    ↓
GitHub Actions:
  1. Build & Test ✅
  2. Build Docker Image ✅
  3. Push to GHCR ✅
  4. Trigger Render Deploy Hook ✅
    ↓
Render:
  5. Deploy từ latest code ✅
```

---

## ⚙️ Cấu Hình

### Trong GitHub Actions:

Workflow sẽ tự động:
1. Build và push Docker image
2. Gọi Render Deploy Hook
3. Render sẽ pull code mới và deploy

### Trong Render Dashboard:

1. **Vào Service Settings**
2. **Deploy Hook** section
3. **Copy Deploy Hook URL** (đã có ở trên)
4. ✅ Hook đã được tích hợp vào GitHub Actions

---

## 🔐 Bảo Mật

⚠️ **Lưu ý:**
- Deploy Hook key có trong code (public repo)
- Render có thể regenerate key nếu cần
- Hoặc dùng GitHub Secrets để lưu key

### Option: Dùng GitHub Secrets (Nâng Cao)

1. **Tạo Secret trong GitHub:**
   - Settings → Secrets → Actions
   - Name: `RENDER_DEPLOY_HOOK_URL`
   - Value: `https://api.render.com/deploy/srv-d4qd2jre5dus73eljgt0?key=ibd9zEAJO4A`

2. **Update workflow:**
   ```yaml
   curl -X POST "${{ secrets.RENDER_DEPLOY_HOOK_URL }}"
   ```

---

## ✅ Kết Quả

Sau khi push code:
1. ✅ GitHub Actions build Docker image
2. ✅ Push image lên GHCR
3. ✅ Trigger Render deploy hook
4. ✅ Render tự động deploy code mới

**Không cần vào Render dashboard để manual deploy!** 🎉

---

## 📋 Kiểm Tra Deployment

1. **Render Dashboard**: https://dashboard.render.com
2. **Service** → **Events** tab
3. Xem deployment status và logs

---

## 🔗 Tài Liệu

- Render Deploy Hooks: https://render.com/docs/deploy-hooks
- GitHub Actions: https://docs.github.com/en/actions

---

**Deploy Hook đã được tích hợp vào GitHub Actions workflow!** 🚀

