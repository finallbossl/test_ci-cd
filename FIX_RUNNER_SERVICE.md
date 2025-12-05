# 🔧 Sửa lỗi Runner Service - Inactive

## ❌ Vấn đề

Service đã được cài đặt nhưng đang **inactive (dead)** - cần start service.

## ✅ Giải pháp

### Bước 1: Start Service

**Trên server `finalboss`, chạy:**

```bash
# Start service
sudo ./svc.sh start

# Kiểm tra lại status
sudo ./svc.sh status
```

### Bước 2: Kiểm tra Logs nếu vẫn không start

```bash
# Xem logs chi tiết
sudo journalctl -u actions.runner.finallbossl-test_ci-cd.finalboss.service -f

# Hoặc xem logs runner
cd ~/actions-runner
tail -f _diag/Runner_*.log
```

### Bước 3: Kiểm tra Permissions

```bash
# Đảm bảo có quyền execute
chmod +x run.sh config.sh svc.sh

# Kiểm tra ownership
ls -la ~/actions-runner
```

### Bước 4: Restart Service (nếu cần)

```bash
# Restart service
sudo ./svc.sh stop
sudo ./svc.sh start

# Hoặc
sudo systemctl restart actions.runner.finallbossl-test_ci-cd.finalboss.service
```

---

## 🔍 Kiểm tra Service Status

Sau khi start, status phải là:

```
Active: active (running)
```

Thay vì:
```
Active: inactive (dead)
```

---

## ✅ Sau khi start thành công

1. **Kiểm tra trên GitHub:**
   - Vào: https://github.com/finallbossl/test_ci-cd/settings/actions/runners
   - Runner sẽ hiển thị với status **Idle** (màu xanh)

2. **Test workflow:**
   ```bash
   # Từ máy local
   git commit --allow-empty -m "Test runner"
   git push origin main
   ```

---

## 🐛 Troubleshooting

### Service không start được

```bash
# Xem logs chi tiết
sudo journalctl -u actions.runner.*.service -n 50

# Kiểm tra config
cat ~/actions-runner/.runner
```

### Permission denied

```bash
# Fix permissions
sudo chown -R $USER:$USER ~/actions-runner
chmod +x ~/actions-runner/*.sh
```

### Service bị disable

```bash
# Enable và start
sudo systemctl enable actions.runner.finallbossl-test_ci-cd.finalboss.service
sudo systemctl start actions.runner.finallbossl-test_ci-cd.finalboss.service
```

---

**Chạy `sudo ./svc.sh start` để start runner! 🚀**

