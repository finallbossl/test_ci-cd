# 🔧 Sửa lỗi "i/o timeout" - Network Connection

## ❌ Vấn đề

Lỗi `dial tcp ***:***: i/o timeout` xảy ra vì:
- IP `172.24.180.191` là **private IP** (mạng nội bộ)
- GitHub Actions runners chạy trên **cloud của GitHub** (internet)
- Không thể truy cập private network từ internet

## ✅ Giải pháp

### Giải pháp 1: Sử dụng Public IP (Khuyến nghị nếu có)

Nếu server có public IP:

1. **Tìm public IP của server:**
   ```bash
   # Trên server, chạy:
   curl ifconfig.me
   # hoặc
   curl ipinfo.io/ip
   ```

2. **Cập nhật GitHub Secret `PRODUCTION_HOST`** với public IP

3. **Mở port 22 trên firewall:**
   ```bash
   # Ubuntu/Debian
   sudo ufw allow 22/tcp
   
   # CentOS/RHEL
   sudo firewall-cmd --permanent --add-port=22/tcp
   sudo firewall-cmd --reload
   ```

4. **Cấu hình SSH để chấp nhận kết nối từ internet:**
   - Đảm bảo `/etc/ssh/sshd_config` cho phép kết nối từ bên ngoài
   - Restart SSH: `sudo systemctl restart sshd`

---

### Giải pháp 2: Self-Hosted Runner (Khuyến nghị cho private network)

Chạy GitHub Actions runner trực tiếp trên server của bạn.

#### Bước 1: Tạo Personal Access Token

1. Vào: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Chọn scopes:
   - `repo` (full control)
   - `workflow`
4. Generate và copy token

#### Bước 2: Cài đặt Runner trên Server

**Trên server `finalboss`:**

```bash
# Tạo thư mục
mkdir actions-runner && cd actions-runner

# Download runner (Linux x64)
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

# Giải nén
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# Cấu hình runner
./config.sh --url https://github.com/finallbossl/test_ci-cd --token YOUR_TOKEN

# Chạy runner
./run.sh
```

#### Bước 3: Cài đặt như service (tùy chọn)

```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

#### Bước 4: Cập nhật Workflow để dùng self-hosted runner

Cập nhật `.github/workflows/deploy-production.yml`:

```yaml
deploy:
  name: Deploy to Production
  runs-on: self-hosted  # Thay vì ubuntu-latest
  # ... rest of config
```

**Ưu điểm:**
- ✅ Không cần public IP
- ✅ Chạy trực tiếp trên server
- ✅ Không cần SSH
- ✅ Nhanh hơn

**Nhược điểm:**
- ⚠️ Cần maintain runner
- ⚠️ Cần server luôn online

---

### Giải pháp 3: SSH Tunnel qua Public Server

Nếu có một server public khác làm jump host:

1. **Setup SSH tunnel trên server public**
2. **Cập nhật workflow để connect qua tunnel**

---

### Giải pháp 4: VPN hoặc Cloudflare Tunnel

1. **Setup VPN** để GitHub Actions có thể truy cập private network
2. **Hoặc dùng Cloudflare Tunnel** để expose server qua internet an toàn

---

## 🎯 Khuyến nghị

**Cho môi trường production:**
- **Option 1:** Nếu server có public IP → Dùng public IP + firewall rules
- **Option 2:** Nếu chỉ có private IP → Dùng **Self-Hosted Runner** (tốt nhất)

---

## 📝 Cập nhật Workflow cho Self-Hosted Runner

Nếu chọn Self-Hosted Runner, cập nhật workflow:

```yaml
deploy:
  name: Deploy to Production
  runs-on: self-hosted  # Thay đổi từ ubuntu-latest
  needs: build-and-push-docker
  if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master'
  
  steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Login to GitHub Container Registry
      run: |
        echo ${{ secrets.GITHUB_TOKEN }} | docker login ghcr.io -u ${{ github.actor }} --password-stdin
    
    - name: Pull latest image
      run: docker pull ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
    
    - name: Stop and remove old container
      run: |
        docker stop backend-api || true
        docker rm backend-api || true
    
    - name: Run new container
      run: |
        docker run -d \
          --name backend-api \
          --restart unless-stopped \
          -p 8080:8080 \
          -e ASPNETCORE_ENVIRONMENT=Production \
          -e ConnectionStrings__DefaultConnection="${{ secrets.PRODUCTION_DB_CONNECTION }}" \
          ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
    
    - name: Clean up old images
      run: docker image prune -af --filter "until=24h"
    
    - name: Health check
      run: |
        sleep 10
        curl -f http://localhost:8080/health || exit 1
```

**Lưu ý:** Với self-hosted runner, không cần SSH action nữa vì runner chạy trực tiếp trên server!

---

## 🔍 Kiểm tra Public IP

Nếu muốn thử public IP, kiểm tra:

```bash
# Trên server
curl ifconfig.me
```

Nếu có public IP, update `PRODUCTION_HOST` và mở firewall.

---

**Chọn giải pháp phù hợp với infrastructure của bạn! 🚀**

