# 🔐 Hướng dẫn Setup SSH Key cho CI/CD

Bạn đã tạo SSH key thành công! Bây giờ làm theo các bước sau:

## ✅ Bước 1: Copy Public Key vào authorized_keys

Trên server, chạy các lệnh sau:

```bash
# Tạo thư mục .ssh nếu chưa có
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Copy public key vào authorized_keys
cat ~/.ssh/github_actions_deploy.pub >> ~/.ssh/authorized_keys

# Set permissions đúng (rất quan trọng!)
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh

# Xem nội dung để xác nhận
cat ~/.ssh/authorized_keys
```

## ✅ Bước 2: Lấy Private Key cho GitHub Secrets

**Trên server, chạy lệnh sau để xem private key:**

```bash
cat ~/.ssh/github_actions_deploy
```

**Bạn sẽ thấy output như sau:**
```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
NhAAAAAwEAAQAAAFgAAAAdzc2gtcnNhAAACBAG... (nhiều dòng)
...
-----END OPENSSH PRIVATE KEY-----
```

**⚠️ QUAN TRỌNG:** Copy TOÀN BỘ nội dung, bao gồm cả dòng `-----BEGIN...` và `-----END...`

## ✅ Bước 3: Test SSH Connection

**Từ máy local hoặc từ chính server, test kết nối:**

```bash
# Test từ chính server
ssh -i ~/.ssh/github_actions_deploy localhost

# Hoặc test từ máy khác (nếu đã copy key)
ssh -i ~/.ssh/github_actions_deploy boss@finalboss
```

Nếu thành công, bạn sẽ vào được shell mà không cần nhập password.

## ✅ Bước 4: Thêm Private Key vào GitHub Secrets

1. Vào: https://github.com/finallbossl/test_ci-cd/settings/secrets/actions
2. Click **"New repository secret"**
3. Thêm secret với:
   - **Name:** `PRODUCTION_SSH_KEY`
   - **Value:** Paste toàn bộ private key (từ bước 2)
4. Click **"Add secret"**

## ✅ Bước 5: Thêm các Secrets khác

Thêm tiếp các secrets sau:

### PRODUCTION_HOST
- **Name:** `PRODUCTION_HOST`
- **Value:** Địa chỉ IP hoặc hostname của server
  - Ví dụ: `finalboss` hoặc `192.168.1.100` hoặc `your-domain.com`

### PRODUCTION_USER
- **Name:** `PRODUCTION_USER`
- **Value:** `boss` (username của bạn trên server)

### PRODUCTION_PORT (Optional)
- **Name:** `PRODUCTION_PORT`
- **Value:** `22` (mặc định, hoặc port SSH của bạn)

### PRODUCTION_URL
- **Name:** `PRODUCTION_URL`
- **Value:** URL đầy đủ của API
  - Ví dụ: `http://finalboss:8080` hoặc `http://192.168.1.100:8080`

### PRODUCTION_DB_CONNECTION
- **Name:** `PRODUCTION_DB_CONNECTION`
- **Value:** Connection string cho SQL Server
  - Ví dụ: `Server=localhost;Database=DataTest;User Id=sa;Password=YourPassword;TrustServerCertificate=True;`

## ✅ Bước 6: Kiểm tra lại

Sau khi thêm tất cả secrets, kiểm tra:

1. Vào: https://github.com/finallbossl/test_ci-cd/settings/secrets/actions
2. Bạn sẽ thấy 6 secrets (hoặc 5 nếu không thêm PORT):
   - ✅ PRODUCTION_HOST
   - ✅ PRODUCTION_USER
   - ✅ PRODUCTION_SSH_KEY
   - ✅ PRODUCTION_PORT (optional)
   - ✅ PRODUCTION_URL
   - ✅ PRODUCTION_DB_CONNECTION

## 🧪 Test CI/CD

Sau khi setup xong, test bằng cách:

```bash
# Tạo một thay đổi nhỏ
echo "# Test CI/CD" >> README.md

# Commit và push
git add README.md
git commit -m "Test CI/CD deployment"
git push origin main
```

Sau đó vào: https://github.com/finallbossl/test_ci-cd/actions để xem workflow chạy!

## 🐛 Troubleshooting

### Lỗi: "Permission denied (publickey)"

**Nguyên nhân:** Public key chưa được thêm đúng hoặc permissions sai.

**Giải pháp:**
```bash
# Kiểm tra permissions
ls -la ~/.ssh/
# Phải thấy:
# -rw------- authorized_keys (600)
# drwx------ .ssh (700)

# Kiểm tra public key đã có trong authorized_keys
grep "github-actions" ~/.ssh/authorized_keys
```

### Lỗi: "Host key verification failed"

**Giải pháp:**
```bash
# Thêm vào ~/.ssh/config
Host finalboss
    HostName finalboss
    User boss
    IdentityFile ~/.ssh/github_actions_deploy
    StrictHostKeyChecking no
```

## 📝 Lưu ý bảo mật

1. ⚠️ **KHÔNG** commit private key vào git
2. ⚠️ **KHÔNG** chia sẻ private key công khai
3. ✅ Chỉ thêm private key vào GitHub Secrets
4. ✅ Giữ private key an toàn trên server

---

**🎉 Xong! Bây giờ CI/CD đã sẵn sàng deploy tự động!**

