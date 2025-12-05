# 🚀 Setup Self-Hosted Runner - Hướng dẫn từng bước

Hướng dẫn setup GitHub Actions Self-Hosted Runner trên server `finalboss`.

## 📋 Yêu cầu

- Server `finalboss` đã có:
  - ✅ Docker đã cài đặt
  - ✅ SSH access
  - ✅ Internet connection

## 🔧 Bước 1: Lấy Token từ GitHub

1. **Vào GitHub Repository:**
   https://github.com/finallbossl/test_ci-cd

2. **Vào Settings → Actions → Runners:**
   https://github.com/finallbossl/test_ci-cd/settings/actions/runners

3. **Click "New self-hosted runner"**

4. **Chọn:**
   - OS: **Linux**
   - Architecture: **x64**

5. **Copy các lệnh hiển thị** (sẽ có dạng):
   ```bash
   # Create a folder
   mkdir actions-runner && cd actions-runner
   
   # Download the latest runner package
   curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
   
   # Extract the installer
   tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
   
   # Create the runner and start the configuration
   ./config.sh --url https://github.com/finallbossl/test_ci-cd --token AXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```

6. **Lưu token lại** (token chỉ hiển thị 1 lần!)

---

## 🔧 Bước 2: Setup Runner trên Server

**SSH vào server `finalboss` và chạy các lệnh sau:**

### 2.1. Tạo thư mục và download runner

```bash
# Tạo thư mục
mkdir -p ~/actions-runner && cd ~/actions-runner

# Download runner (version mới nhất)
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

# Giải nén
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
```

### 2.2. Cấu hình runner

```bash
# Chạy config (thay YOUR_TOKEN bằng token từ GitHub)
./config.sh --url https://github.com/finallbossl/test_ci-cd --token YOUR_TOKEN
```

**Khi được hỏi, chọn:**
- **Enter name for this runner:** `finalboss` (hoặc tên bạn muốn)
- **Enter name of work folder:** `_work` (mặc định, Enter)
- **Configure runner as service?** `Y` (Yes) - để tự động start khi server reboot

### 2.3. Cài đặt như service (tự động start)

```bash
# Cài đặt service
sudo ./svc.sh install

# Start service
sudo ./svc.sh start

# Kiểm tra status
sudo ./svc.sh status
```

---

## 🔧 Bước 3: Cập nhật Workflow

Workflow đã được tạo sẵn tại: `.github/workflows/deploy-production-self-hosted.yml`

**Hoặc cập nhật workflow hiện tại:**

Đổi dòng này trong `.github/workflows/deploy-production.yml`:
```yaml
runs-on: ubuntu-latest
```

Thành:
```yaml
runs-on: self-hosted
```

Và xóa bước SSH, thay bằng các bước chạy trực tiếp trên server.

---

## ✅ Bước 4: Kiểm tra

1. **Kiểm tra runner đã online:**
   - Vào: https://github.com/finallbossl/test_ci-cd/settings/actions/runners
   - Bạn sẽ thấy runner `finalboss` với status **Idle** (màu xanh)

2. **Test workflow:**
   ```bash
   # Từ máy local
   git commit --allow-empty -m "Test self-hosted runner"
   git push origin main
   ```

3. **Xem workflow chạy:**
   - Vào: https://github.com/finallbossl/test_ci-cd/actions
   - Workflow sẽ chạy trên runner `finalboss`

---

## 🔍 Troubleshooting

### Runner không hiển thị online

```bash
# Kiểm tra service
sudo ./svc.sh status

# Xem logs
sudo journalctl -u actions.runner.finallbossl-test_ci-cd.finalboss.service -f

# Restart service
sudo ./svc.sh restart
```

### Runner không nhận job

- Kiểm tra runner có label `self-hosted`
- Kiểm tra workflow có `runs-on: self-hosted`
- Kiểm tra runner status trên GitHub

### Permission denied khi chạy Docker

```bash
# Thêm user runner vào docker group
sudo usermod -aG docker $USER
# Hoặc
sudo usermod -aG docker runner-user

# Restart runner
sudo ./svc.sh restart
```

### Xem logs chi tiết

```bash
# Logs của runner
cd ~/actions-runner
tail -f _diag/Runner_*.log
```

---

## 🛠️ Quản lý Runner

### Dừng runner
```bash
sudo ./svc.sh stop
```

### Start runner
```bash
sudo ./svc.sh start
```

### Restart runner
```bash
sudo ./svc.sh restart
```

### Uninstall runner
```bash
# Dừng service
sudo ./svc.sh stop
sudo ./svc.sh uninstall

# Xóa runner khỏi GitHub
./config.sh remove --token YOUR_TOKEN

# Xóa thư mục
cd ~
rm -rf actions-runner
```

---

## 📝 Lưu ý

1. **Security:**
   - Runner có quyền truy cập toàn bộ server
   - Chỉ chạy code từ repository bạn tin tưởng
   - Không chạy code từ fork hoặc PR từ người lạ

2. **Performance:**
   - Runner chạy trên server của bạn
   - Đảm bảo server có đủ resources (CPU, RAM, Disk)

3. **Maintenance:**
   - Update runner định kỳ
   - Monitor logs để phát hiện vấn đề

---

## 🎉 Hoàn thành!

Sau khi setup xong:
- ✅ Runner sẽ tự động nhận jobs từ GitHub
- ✅ Workflow sẽ chạy trực tiếp trên server
- ✅ Không cần SSH hay public IP
- ✅ Deploy nhanh hơn và an toàn hơn

---

**Bắt đầu từ Bước 1 để lấy token từ GitHub! 🚀**

