# 🚫 Disable Self-Hosted Workflow

## ✅ Đã Disable

Workflow `deploy-production-self-hosted.yml` đã được disable tự động trigger.

**Thay đổi:**
- ❌ Không tự động chạy khi push code
- ✅ Chỉ chạy khi manual trigger (`workflow_dispatch`)

---

## 🎯 Lý Do

Nếu bạn chỉ muốn deploy lên **Render**:
- ✅ Workflow `deploy-render.yml` sẽ tự động deploy
- ❌ Không cần deploy lên self-hosted server

---

## 🔄 Nếu Muốn Enable Lại

Nếu sau này muốn deploy cả 2 nơi:

1. **Uncomment trigger** trong `.github/workflows/deploy-production-self-hosted.yml`:
   ```yaml
   on:
     push:
       branches:
         - main
         - master
     workflow_dispatch:
   ```

2. **Commit và push**

3. ✅ Workflow sẽ tự động chạy lại khi push code

---

## 📊 Workflows Hiện Tại

| Workflow | Trigger | Deploy To |
|---|---|---|
| `deploy-render.yml` | ✅ Auto (push) | Render |
| `deploy-production-self-hosted.yml` | ⚠️ Manual only | Self-hosted server |
| `ci.yml` | ✅ Auto (PR/push) | Test only |

---

**Workflow self-hosted đã được disable! Chỉ Render sẽ tự động deploy.** ✅

