# 🔧 Sửa lỗi SSH Key và Host

## ❌ Lỗi 1: "ssh: no key found"

**Nguyên nhân:** SSH private key không đúng format hoặc có ký tự thừa.

### Giải pháp:

#### Bước 1: Lấy lại Private Key đúng format

**Trên server `finalboss`, chạy:**

```bash
# Xem private key
cat ~/.ssh/github_actions_deploy
```

**Output phải có dạng:**
```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
NhAAAAAwEAAQAAAFgAAAAdzc2gtcnNhAAACBAG... (nhiều dòng)
...
-----END OPENSSH PRIVATE KEY-----
```

#### Bước 2: Copy Private Key vào GitHub Secrets

1. **Copy TOÀN BỘ** nội dung từ lệnh trên (bao gồm cả `-----BEGIN...` và `-----END...`)
2. Vào: https://github.com/finallbossl/test_ci-cd/settings/secrets/actions
3. Tìm secret `PRODUCTION_SSH_KEY`
4. Click **Update** (hoặc xóa và tạo lại)
5. **QUAN TRỌNG:** 
   - Paste key vào textarea
   - **KHÔNG** có khoảng trắng thừa ở đầu/cuối
   - **KHÔNG** có dòng trống thừa
   - Phải có đầy đủ `-----BEGIN...` và `-----END...`

#### Bước 3: Kiểm tra format

Private key phải:
- Bắt đầu bằng: `-----BEGIN OPENSSH PRIVATE KEY-----`
- Kết thúc bằng: `-----END OPENSSH PRIVATE KEY-----`
- Không có ký tự lạ hoặc dòng trống thừa

---

## ❌ Lỗi 2: "no such host"

**Nguyên nhân:** Hostname không thể resolve được từ GitHub Actions runner.

### Giải pháp:

#### Option 1: Sử dụng IP Address (Khuyến nghị)

1. Tìm IP của server `finalboss`:
   ```bash
   # Trên server, chạy:
   hostname -I
   # Hoặc
   ip addr show
   ```

2. Cập nhật GitHub Secret `PRODUCTION_HOST`:
   - Vào: https://github.com/finallbossl/test_ci-cd/settings/secrets/actions
   - Tìm `PRODUCTION_HOST`
   - Update với IP address (ví dụ: `192.168.1.100`)

#### Option 2: Sử dụng FQDN (Fully Qualified Domain Name)

Nếu server có domain name đầy đủ:
- Ví dụ: `finalboss.example.com` thay vì `finalboss`

#### Option 3: Kiểm tra DNS

Nếu muốn dùng hostname, đảm bảo:
- Hostname có thể resolve từ internet
- Hoặc thêm vào `/etc/hosts` (không khả thi với GitHub Actions)

---

## ✅ Checklist sửa lỗi

- [ ] Private key đã copy đúng format (có BEGIN và END)
- [ ] Private key không có khoảng trắng thừa
- [ ] `PRODUCTION_HOST` đã đổi thành IP address
- [ ] `PRODUCTION_USER` đúng (ví dụ: `boss`)
- [ ] `PRODUCTION_PORT` đúng (mặc định: `22`)
- [ ] Đã test SSH từ local: `ssh -i ~/.ssh/github_actions_deploy boss@IP_ADDRESS`

---

## 🧪 Test lại

Sau khi sửa, test lại bằng cách:

1. Push code mới:
   ```bash
   git commit --allow-empty -m "Test CI/CD after SSH fix"
   git push origin main
   ```

2. Xem workflow: https://github.com/finallbossl/test_ci-cd/actions

3. Kiểm tra logs trong step "Deploy to server"

---

## 📝 Lưu ý

1. **SSH Key format:** 
   - Phải là OpenSSH format (ed25519 hoặc RSA)
   - Không phải PEM format cũ
   - Không có passphrase (để CI/CD tự động)

2. **Host resolution:**
   - GitHub Actions runner không thể resolve hostname local
   - Phải dùng IP address hoặc public domain

3. **Security:**
   - Không commit private key vào git
   - Chỉ lưu trong GitHub Secrets

---

**Sau khi sửa xong, workflow sẽ chạy thành công! 🎉**

