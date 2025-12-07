# ⏳ GitHub Actions - CI/CD Pipeline

## 📋 Kiến Trúc CI/CD

**GitHub Actions = CI/CD Pipeline (Build, Test, Deploy)**  
**Render = Runtime Environment (Môi trường chạy)**

GitHub Actions xử lý CI/CD (build, test, push images), Render là nơi ứng dụng chạy.

---

# ⏳ GitHub Actions Đang Chờ Self-Hosted Runner

## 🔍 Tình Huống

Khi bạn vừa push code lên GitHub, workflow `deploy-production-self-hosted.yml` tự động trigger và đang chờ self-hosted runner nhận job.

### Workflow có 3 Jobs:

1. ✅ **build-and-test** - Đã chạy xong (trên GitHub cloud)
2. ✅ **build-and-push-docker** - Đã chạy xong (trên GitHub cloud)
3. ⏳ **deploy** - **ĐANG CHỜ** self-hosted runner

---

## 🎯 Bạn Muốn Làm Gì?

### Option 1: Cancel Job (Nếu không muốn deploy lên self-hosted runner)

Nếu bạn muốn deploy lên **Render** thay vì self-hosted runner:

1. **Vào GitHub**: https://github.com/finallbossl/test_ci-cd/actions
2. **Click vào workflow run** đang chạy
3. **Click "Cancel workflow"** ở góc trên bên phải
4. ✅ Job sẽ bị hủy, không deploy lên self-hosted runner

### Option 2: Để Runner Nhận Job (Nếu muốn deploy lên server cũ)

Nếu bạn vẫn muốn deploy lên server Linux (self-hosted runner):

1. **SSH vào Linux server** (finalboss):
   ```bash
   ssh boss@172.24.180.191
   ```

2. **Kiểm tra runner service**:
   ```bash
   cd ~/actions-runner
   sudo ./svc.sh status
   ```

3. **Nếu runner không chạy, start nó**:
   ```bash
   sudo ./svc.sh start
   ```

4. **Hoặc chạy manual để xem logs**:
   ```bash
   ./run.sh
   ```

5. ✅ Runner sẽ tự động nhận job và deploy

### Option 3: Disable Workflow Tạm Thời

Nếu bạn không muốn workflow này trigger nữa (chỉ deploy lên Render):

1. **Vào file**: `.github/workflows/deploy-production-self-hosted.yml`
2. **Comment hoặc xóa trigger**:
   ```yaml
   on:
     # push:
     #   branches:
     #     - main
     #     - master
     workflow_dispatch:  # Chỉ chạy khi manual trigger
   ```
3. **Commit và push**

---

## 📊 So Sánh

| | Self-Hosted Runner | Render |
|---|---|---|
| **Tự động deploy** | ✅ Có (khi push code) | ✅ Có (khi push code) |
| **Server** | Linux server của bạn | Render cloud |
| **Database** | SQL Server trên Windows host | PostgreSQL trên Render |
| **Chi phí** | $0 (server riêng) | $0-7/tháng |
| **Control** | Toàn quyền | Render quản lý |

---

## 💡 Khuyến Nghị

### Nếu Bạn Muốn Deploy Lên Render:
→ **Cancel job này** và deploy manual lên Render

### Nếu Bạn Vẫn Muốn Cả Hai (Deploy Cả 2 Nơi):

**Có thể deploy cả 2 nơi cùng lúc:**

1. **Để GitHub Actions deploy lên self-hosted runner** (server Linux của bạn):
   - ✅ Tự động khi push code
   - ✅ Deploy lên server cũ (192.168.102.8:8080)
   - ✅ Database: SQL Server trên Windows host

2. **Deploy lên Render** (parallel):
   - ✅ Có thể deploy cùng lúc hoặc sau đó
   - ✅ Deploy lên Render cloud
   - ✅ Database: PostgreSQL trên Render
   - ✅ URL: `https://backend-api-xxxx.onrender.com`

**Kết quả:**
- 🟢 Backend chạy ở 2 nơi:
  - Server Linux (self-hosted): `http://172.24.180.191:8080`
  - Render: `https://backend-api-xxxx.onrender.com`
  
- 🟢 Frontend có thể point tới bất kỳ backend nào

**Lợi ích:**
- ✅ Redundancy (backup nếu một nơi down)
- ✅ Test cả 2 environments
- ✅ Flexibility (switch giữa 2 backends)

### Nếu Chỉ Muốn Render:
→ **Cancel job** + **Disable workflow** tạm thời

---

## ⚡ Hành Động Nhanh

**Nếu muốn cancel ngay:**
1. Vào: https://github.com/finallbossl/test_ci-cd/actions
2. Click workflow run đang pending
3. Click "Cancel workflow"
4. ✅ Done!

**Nếu muốn để runner nhận job:**
1. SSH vào Linux server
2. Start runner service: `sudo ./svc.sh start`
3. ✅ Runner sẽ nhận job

---

## 🔧 Kiểm Tra Runner Status

Trên Linux server (finalboss):

```bash
# Check status
cd ~/actions-runner
sudo ./svc.sh status

# Nếu không chạy, start
sudo ./svc.sh start

# Xem logs
./run.sh
```

---

## ✅ Kết Luận

**Job đang chờ là bình thường** - đó là do workflow tự động trigger khi push code.

**Bạn có thể:**
- ✅ Cancel nếu không muốn deploy
- ✅ Để runner nhận job nếu muốn deploy
- ✅ Disable workflow nếu không dùng nữa

**Không ảnh hưởng đến việc deploy lên Render!** Bạn vẫn có thể deploy lên Render bình thường.

