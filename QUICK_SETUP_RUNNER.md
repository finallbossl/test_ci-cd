# ⚡ Quick Setup Self-Hosted Runner

## 📍 Chạy lệnh ở đâu?

**Tất cả lệnh chạy trên SERVER `finalboss` qua SSH!**

## 🔧 Các bước thực hiện:

### Bước 1: SSH vào server

**Từ máy Windows của bạn, mở PowerShell hoặc CMD và chạy:**

```powershell
# SSH vào server (thay bằng IP hoặc hostname của bạn)
ssh boss@finalboss
# hoặc
ssh boss@172.24.180.191
```

Sau khi SSH thành công, bạn sẽ thấy prompt:
```
boss@finalboss:~$
```

### Bước 2: Chạy các lệnh setup runner

**Trên server `finalboss`, chạy từng lệnh một:**

```bash
# 1. Tạo thư mục và vào thư mục đó
mkdir actions-runner && cd actions-runner

# 2. Download runner
curl -o actions-runner-linux-x64-2.329.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-linux-x64-2.329.0.tar.gz

# 3. (Optional) Validate hash
echo "194f1e1e4bd02f80b7e9633fc546084d8d4e19f3928a324d512ea53430102e1d  actions-runner-linux-x64-2.329.0.tar.gz" | shasum -a 256 -c

# 4. Giải nén
tar xzf ./actions-runner-linux-x64-2.329.0.tar.gz
```

### Bước 3: Cấu hình runner

**Sau khi giải nén xong, chạy lệnh config:**

```bash
# Thay YOUR_TOKEN bằng token từ GitHub
./config.sh --url https://github.com/finallbossl/test_ci-cd --token YOUR_TOKEN
```

**Khi được hỏi:**
- **Enter name for this runner:** Nhấn `Enter` (dùng tên mặc định) hoặc gõ `finalboss`
- **Enter name of work folder:** Nhấn `Enter` (dùng `_work`)
- **Configure runner as service?** Gõ `Y` và nhấn `Enter` (để tự động start)

### Bước 4: Cài đặt service

```bash
# Cài đặt như service
sudo ./svc.sh install

# Start service
sudo ./svc.sh start

# Kiểm tra status
sudo ./svc.sh status
```

---

## 📋 Tóm tắt - Copy & Paste toàn bộ:

**SSH vào server, sau đó copy và chạy:**

```bash
# Tạo thư mục
mkdir actions-runner && cd actions-runner

# Download
curl -o actions-runner-linux-x64-2.329.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-linux-x64-2.329.0.tar.gz

# Giải nén
tar xzf ./actions-runner-linux-x64-2.329.0.tar.gz

# Config (THAY YOUR_TOKEN bằng token thật từ GitHub)
./config.sh --url https://github.com/finallbossl/test_ci-cd --token YOUR_TOKEN

# Cài service
sudo ./svc.sh install
sudo ./svc.sh start

# Kiểm tra
sudo ./svc.sh status
```

---

## 🔑 Lấy Token từ GitHub:

1. Vào: https://github.com/finallbossl/test_ci-cd/settings/actions/runners
2. Click **"New self-hosted runner"**
3. Chọn **Linux** và **x64**
4. Copy token hiển thị (chỉ hiện 1 lần!)

---

## ✅ Kiểm tra sau khi setup:

1. **Kiểm tra runner online:**
   - Vào: https://github.com/finallbossl/test_ci-cd/settings/actions/runners
   - Sẽ thấy runner với status **Idle** (màu xanh)

2. **Test workflow:**
   ```bash
   # Từ máy Windows, push code
   git commit --allow-empty -m "Test self-hosted runner"
   git push origin main
   ```

---

## 🐛 Nếu gặp lỗi:

### Lỗi permission denied
```bash
# Thêm quyền execute
chmod +x config.sh svc.sh run.sh
```

### Lỗi Docker permission
```bash
# Thêm user vào docker group
sudo usermod -aG docker $USER
# Logout và login lại
```

### Xem logs
```bash
# Logs service
sudo journalctl -u actions.runner.*.service -f

# Logs runner
cd ~/actions-runner
tail -f _diag/Runner_*.log
```

---

**🎯 Tóm lại: TẤT CẢ lệnh chạy trên SERVER `finalboss` qua SSH!**

