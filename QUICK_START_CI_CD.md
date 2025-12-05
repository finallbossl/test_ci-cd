# ⚡ Quick Start: CI/CD trong 5 phút

Hướng dẫn nhanh để setup CI/CD.

## 🎯 3 Bước chính

### 1️⃣ Tạo SSH Key và thêm vào Server

```bash
# Tạo SSH key
ssh-keygen -t ed25519 -f ~/.ssh/github_actions_deploy -N ""

# Copy public key lên server
ssh-copy-id -i ~/.ssh/github_actions_deploy.pub user@your-server-ip

# Copy private key (sẽ dùng cho GitHub Secrets)
cat ~/.ssh/github_actions_deploy
```

### 2️⃣ Thêm GitHub Secrets

Vào: **Repository → Settings → Secrets and variables → Actions**

Thêm 6 secrets:

| Secret Name | Giá trị ví dụ |
|------------|---------------|
| `PRODUCTION_HOST` | `192.168.1.100` hoặc `api.example.com` |
| `PRODUCTION_USER` | `root` hoặc `ubuntu` |
| `PRODUCTION_SSH_KEY` | Nội dung private key (từ bước 1) |
| `PRODUCTION_PORT` | `22` |
| `PRODUCTION_URL` | `http://192.168.1.100:8080` |
| `PRODUCTION_DB_CONNECTION` | `Server=sql;Database=DataTest;User Id=sa;Password=xxx;TrustServerCertificate=True;` |

### 3️⃣ Push code và chờ CI/CD chạy

```bash
git add .
git commit -m "Setup CI/CD"
git push origin main
```

**→ Vào tab Actions trên GitHub để xem CI/CD chạy!**

---

## ✅ Kiểm tra

1. **GitHub Actions:** Vào tab **Actions** → Xem workflow đang chạy
2. **Docker Image:** Vào **Packages** → Xem image đã được push
3. **Server:** SSH vào server → `docker ps` → Xem container đang chạy
4. **API:** Mở browser → `http://your-server:8080/health`

---

## 🐛 Lỗi thường gặp

| Lỗi | Giải pháp |
|-----|-----------|
| Permission denied | Kiểm tra SSH key đã copy đúng vào server |
| Cannot connect Docker | Thêm user vào docker group: `sudo usermod -aG docker $USER` |
| Health check failed | Xem logs: `docker logs backend-api` |
| Database error | Kiểm tra connection string trong Secrets |

---

## 📚 Xem thêm

- **Hướng dẫn chi tiết:** [HUONG_DAN_CI_CD.md](./HUONG_DAN_CI_CD.md)
- **Deployment guide:** [README_DEPLOYMENT.md](./README_DEPLOYMENT.md)

---

**🎉 Xong! CI/CD đã sẵn sàng!**

