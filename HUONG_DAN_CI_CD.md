# 🚀 Hướng dẫn chi tiết: Cách để CI/CD chạy

Hướng dẫn từng bước để setup và chạy CI/CD với GitHub Actions.

## 📋 Mục lục

1. [Chuẩn bị](#chuẩn-bị)
2. [Setup GitHub Repository](#setup-github-repository)
3. [Tạo SSH Key cho Server](#tạo-ssh-key-cho-server)
4. [Setup GitHub Secrets](#setup-github-secrets)
5. [Test CI/CD Local](#test-cicd-local)
6. [Trigger CI/CD](#trigger-cicd)
7. [Xem kết quả và Debug](#xem-kết-quả-và-debug)
8. [Troubleshooting](#troubleshooting)

---

## 1. Chuẩn bị

### Yêu cầu cần có:

- ✅ GitHub account
- ✅ GitHub repository (public hoặc private)
- ✅ Server production với:
  - Docker đã cài đặt
  - SSH access
  - Port 8080 mở (hoặc port bạn muốn dùng)

### Kiểm tra Docker trên server:

```bash
# SSH vào server
ssh user@your-server-ip

# Kiểm tra Docker
docker --version
docker-compose --version
```

---

## 2. Setup GitHub Repository

### Bước 1: Push code lên GitHub

```bash
# Nếu chưa có git repo
git init
git add .
git commit -m "Initial commit with CI/CD setup"

# Thêm remote (thay YOUR_USERNAME và YOUR_REPO)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Push code
git branch -M main
git push -u origin main
```

### Bước 2: Kiểm tra workflows đã được commit

Đảm bảo các file sau đã có trong repo:
- `.github/workflows/ci.yml`
- `.github/workflows/deploy-production.yml`

```bash
# Kiểm tra
ls -la .github/workflows/
```

---

## 3. Tạo SSH Key cho Server

### Bước 1: Tạo SSH Key Pair

**Trên máy local của bạn:**

```bash
# Tạo SSH key (không cần passphrase để CI/CD tự động)
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_actions_deploy

# Hoặc nếu không hỗ trợ ed25519
ssh-keygen -t rsa -b 4096 -C "github-actions" -f ~/.ssh/github_actions_deploy
```

### Bước 2: Copy Public Key lên Server

```bash
# Xem public key
cat ~/.ssh/github_actions_deploy.pub

# Copy public key lên server
ssh-copy-id -i ~/.ssh/github_actions_deploy.pub user@your-server-ip

# Hoặc copy thủ công:
# 1. Copy nội dung file ~/.ssh/github_actions_deploy.pub
# 2. SSH vào server: ssh user@your-server-ip
# 3. Chạy: mkdir -p ~/.ssh && echo "PASTE_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
# 4. Chạy: chmod 600 ~/.ssh/authorized_keys && chmod 700 ~/.ssh
```

### Bước 3: Test SSH Connection

```bash
# Test kết nối
ssh -i ~/.ssh/github_actions_deploy user@your-server-ip

# Nếu thành công, bạn sẽ vào được server
```

### Bước 4: Lấy Private Key cho GitHub Secrets

```bash
# Xem private key (sẽ dùng cho GitHub Secrets)
cat ~/.ssh/github_actions_deploy

# Copy toàn bộ nội dung, bao gồm:
# -----BEGIN OPENSSH PRIVATE KEY-----
# ...
# -----END OPENSSH PRIVATE KEY-----
```

**⚠️ LƯU Ý:** Private key này rất quan trọng, không chia sẻ công khai!

---

## 4. Setup GitHub Secrets

### Bước 1: Vào GitHub Repository Settings

1. Mở repository trên GitHub
2. Click **Settings** (ở menu trên cùng)
3. Click **Secrets and variables** → **Actions** (ở menu bên trái)
4. Click **New repository secret**

### Bước 2: Thêm các Secrets sau

Thêm từng secret một với tên và giá trị:

#### 1. `PRODUCTION_HOST`
- **Name:** `PRODUCTION_HOST`
- **Value:** Địa chỉ IP hoặc domain của server (ví dụ: `192.168.1.100` hoặc `api.example.com`)

#### 2. `PRODUCTION_USER`
- **Name:** `PRODUCTION_USER`
- **Value:** Username SSH (ví dụ: `root`, `ubuntu`, `admin`)

#### 3. `PRODUCTION_SSH_KEY`
- **Name:** `PRODUCTION_SSH_KEY`
- **Value:** Toàn bộ nội dung private key (từ bước 3.4)
  ```
  -----BEGIN OPENSSH PRIVATE KEY-----
  b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
  ...
  -----END OPENSSH PRIVATE KEY-----
  ```

#### 4. `PRODUCTION_PORT` (Optional)
- **Name:** `PRODUCTION_PORT`
- **Value:** Port SSH (mặc định: `22`)

#### 5. `PRODUCTION_URL`
- **Name:** `PRODUCTION_URL`
- **Value:** URL đầy đủ của API (ví dụ: `http://192.168.1.100:8080` hoặc `https://api.example.com`)

#### 6. `PRODUCTION_DB_CONNECTION`
- **Name:** `PRODUCTION_DB_CONNECTION`
- **Value:** Connection string cho SQL Server production
  ```
  Server=your-sql-server;Database=DataTest;User Id=sa;Password=YourPassword;TrustServerCertificate=True;
  ```

### Bước 3: Kiểm tra Secrets đã được thêm

Bạn sẽ thấy danh sách các secrets (chỉ thấy tên, không thấy giá trị - đây là bình thường).

---

## 5. Test CI/CD Local

### Test Docker Build Local

Trước khi chạy CI/CD, test build Docker image:

```bash
# Build image
docker build -t backend-api ./Backend

# Test chạy container
docker run -d \
  --name backend-test \
  -p 8080:8080 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  backend-api

# Kiểm tra health
curl http://localhost:8080/health

# Dọn dẹp
docker stop backend-test
docker rm backend-test
```

---

## 6. Trigger CI/CD

### Cách 1: Push code lên branch main/master (Auto Deploy)

```bash
# Tạo thay đổi nhỏ
echo "# Test CI/CD" >> README.md

# Commit và push
git add .
git commit -m "Test CI/CD pipeline"
git push origin main
```

**→ GitHub Actions sẽ tự động chạy!**

### Cách 2: Manual Trigger (Workflow Dispatch)

1. Vào GitHub repository
2. Click tab **Actions**
3. Chọn workflow **Deploy to Production** (bên trái)
4. Click **Run workflow** (bên phải)
5. Chọn branch và click **Run workflow**

### Cách 3: Tạo Pull Request (CI Only)

```bash
# Tạo branch mới
git checkout -b feature/test-ci

# Push branch
git push origin feature/test-ci

# Tạo Pull Request trên GitHub
```

**→ Chỉ chạy CI pipeline, không deploy production**

---

## 7. Xem kết quả và Debug

### Xem Workflow Runs

1. Vào GitHub repository
2. Click tab **Actions**
3. Bạn sẽ thấy danh sách các workflow runs
4. Click vào run mới nhất để xem chi tiết

### Xem Logs từng Step

1. Trong workflow run, click vào job (ví dụ: "Build and Test")
2. Click vào từng step để xem logs chi tiết
3. Nếu có lỗi, logs sẽ hiển thị màu đỏ

### Các Job trong Workflow

#### Job 1: Build and Test
- ✅ Checkout code
- ✅ Setup .NET
- ✅ Restore dependencies
- ✅ Build project
- ✅ Run tests

#### Job 2: Build and Push Docker Image
- ✅ Checkout code
- ✅ Setup Docker Buildx
- ✅ Login to GitHub Container Registry
- ✅ Build Docker image
- ✅ Push image to registry

#### Job 3: Deploy to Production
- ✅ Checkout code
- ✅ SSH vào server
- ✅ Pull Docker image
- ✅ Stop old container
- ✅ Run new container
- ✅ Health check

### Xem Docker Image trên GitHub

1. Vào repository
2. Click **Packages** (bên phải)
3. Bạn sẽ thấy Docker image đã được push

---

## 8. Troubleshooting

### ❌ Lỗi: "Permission denied (publickey)"

**Nguyên nhân:** SSH key không đúng hoặc chưa được thêm vào server.

**Giải pháp:**
```bash
# Kiểm tra public key đã có trên server
ssh user@your-server-ip "cat ~/.ssh/authorized_keys"

# Đảm bảo permissions đúng
ssh user@your-server-ip "chmod 600 ~/.ssh/authorized_keys && chmod 700 ~/.ssh"
```

### ❌ Lỗi: "Cannot connect to Docker daemon"

**Nguyên nhân:** Docker chưa được cài hoặc user không có quyền.

**Giải pháp:**
```bash
# Trên server, thêm user vào docker group
sudo usermod -aG docker $USER

# Hoặc chạy docker với sudo (cần cập nhật workflow)
```

### ❌ Lỗi: "Failed to pull image"

**Nguyên nhân:** Không thể login vào GitHub Container Registry.

**Giải pháp:**
- Kiểm tra `GITHUB_TOKEN` secret (tự động có sẵn)
- Đảm bảo repository có quyền Packages: write

### ❌ Lỗi: "Health check failed"

**Nguyên nhân:** Container không start hoặc API không response.

**Giải pháp:**
```bash
# SSH vào server và kiểm tra
ssh user@your-server-ip

# Xem logs container
docker logs backend-api

# Kiểm tra container đang chạy
docker ps -a

# Test health endpoint
curl http://localhost:8080/health
```

### ❌ Lỗi: "Database connection failed"

**Nguyên nhân:** Connection string sai hoặc SQL Server không accessible.

**Giải pháp:**
- Kiểm tra `PRODUCTION_DB_CONNECTION` secret
- Test connection string trên server:
  ```bash
  docker run --rm mcr.microsoft.com/mssql-tools \
    /opt/mssql-tools/bin/sqlcmd \
    -S your-sql-server \
    -U sa \
    -P YourPassword \
    -Q "SELECT 1"
  ```

### ❌ Workflow không chạy

**Nguyên nhân:** File workflow không đúng format hoặc không ở đúng vị trí.

**Giải pháp:**
- Kiểm tra file ở: `.github/workflows/deploy-production.yml`
- Kiểm tra YAML syntax: https://www.yamllint.com/
- Đảm bảo branch trigger đúng (main hoặc master)

---

## 📊 Monitoring CI/CD

### GitHub Actions Status Badge

Thêm badge vào README để hiển thị status:

```markdown
![CI/CD](https://github.com/YOUR_USERNAME/YOUR_REPO/workflows/Deploy%20to%20Production/badge.svg)
```

### Email Notifications

GitHub sẽ tự động gửi email khi:
- Workflow fail
- Workflow thành công (nếu bạn bật trong Settings)

---

## ✅ Checklist trước khi Deploy Production

- [ ] Code đã được push lên GitHub
- [ ] Workflow files đã có trong repo
- [ ] SSH key đã được setup và test
- [ ] Tất cả GitHub Secrets đã được thêm
- [ ] Docker build thành công local
- [ ] Server production đã có Docker
- [ ] SQL Server đã được setup trên production
- [ ] Connection string đã được test
- [ ] Port 8080 đã được mở trên firewall
- [ ] Health endpoint `/health` hoạt động

---

## 🎉 Kết quả mong đợi

Sau khi setup xong và push code:

1. ✅ GitHub Actions tự động chạy
2. ✅ Code được build và test
3. ✅ Docker image được build và push lên GitHub Container Registry
4. ✅ Container mới được deploy lên server production
5. ✅ Health check pass
6. ✅ API accessible tại `PRODUCTION_URL`

---

## 📞 Cần hỗ trợ?

Nếu gặp vấn đề, kiểm tra:
1. Logs trong GitHub Actions
2. Logs container trên server: `docker logs backend-api`
3. Server logs: `journalctl -u docker` (nếu dùng systemd)

---

**Chúc bạn deploy thành công! 🚀**

