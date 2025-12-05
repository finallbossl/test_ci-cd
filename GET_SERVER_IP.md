# 🔍 Cách lấy IP Address của Server

Để sửa lỗi "no such host", bạn cần dùng **IP address** thay vì hostname.

## 📋 Cách 1: Trên Server (Khuyến nghị)

**SSH vào server `finalboss` và chạy các lệnh sau:**

```bash
# Cách 1: Lấy IP address
hostname -I

# Cách 2: Xem chi tiết
ip addr show

# Cách 3: Chỉ xem IP
ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}'

# Cách 4: Xem IP của interface cụ thể (thường là eth0 hoặc ens33)
ip addr show eth0
# hoặc
ip addr show ens33
```

**Output sẽ có dạng:**
```
192.168.1.100
```
hoặc
```
inet 192.168.1.100/24
```

**Copy IP address này** (ví dụ: `192.168.1.100`)

---

## 📋 Cách 2: Từ máy local

Nếu bạn đã biết hostname và có thể ping được:

```bash
# Windows PowerShell
ping finalboss

# Hoặc
nslookup finalboss

# Linux/Mac
ping -c 1 finalboss | grep -oP '(\d+\.){3}\d+'
```

---

## 📋 Cách 3: Kiểm tra từ router/network

Nếu server trong mạng local:
- Vào router admin panel
- Xem danh sách devices
- Tìm hostname `finalboss` và xem IP

---

## ✅ Sau khi có IP, cập nhật GitHub Secret

1. **Vào GitHub Secrets:**
   https://github.com/finallbossl/test_ci-cd/settings/secrets/actions

2. **Tìm secret `PRODUCTION_HOST`**

3. **Click "Update"**

4. **Thay đổi giá trị:**
   - ❌ Cũ: `finalboss` (hostname)
   - ✅ Mới: `192.168.1.100` (IP address - thay bằng IP thực của bạn)

5. **Click "Update secret"**

---

## 🧪 Test kết nối

Sau khi update, test từ máy local:

```bash
# Test SSH với IP
ssh -i ~/.ssh/github_actions_deploy boss@192.168.1.100

# Hoặc test ping
ping 192.168.1.100
```

---

## ⚠️ Lưu ý

1. **IP có thể thay đổi:**
   - Nếu server dùng DHCP, IP có thể thay đổi
   - Khuyến nghị: Set static IP cho server

2. **Firewall:**
   - Đảm bảo port 22 (SSH) và 8080 (API) đã mở
   - Kiểm tra: `sudo ufw status` hoặc `sudo firewall-cmd --list-all`

3. **Nếu server có public IP:**
   - Có thể dùng public IP nếu server accessible từ internet
   - Đảm bảo security (chỉ cho phép IP GitHub Actions)

---

## 🔧 Set Static IP (Tùy chọn)

Nếu muốn IP không đổi, set static IP:

### Ubuntu/Debian:
```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Thêm:
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

Sau đó:
```bash
sudo netplan apply
```

---

**Sau khi update `PRODUCTION_HOST` với IP address, workflow sẽ chạy thành công! 🎉**

