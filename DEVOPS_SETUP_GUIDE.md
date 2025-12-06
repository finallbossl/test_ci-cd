# 🚀 Hướng dẫn Setup DevOps & CI/CD - Từ đầu đến cuối

Hướng dẫn chi tiết setup DevOps và CI/CD cho project, bao gồm tất cả các bước từ cài đặt Ubuntu, setup GitHub Actions, cấu hình database, và fix các lỗi thường gặp.

---

## 📋 Mục lục

1. [Chuẩn bị Server Ubuntu](#1-chuẩn-bị-server-ubuntu)
2. [Setup GitHub Actions Self-Hosted Runner](#2-setup-github-actions-self-hosted-runner)
3. [Cấu hình SQL Server trên Windows Host](#3-cấu-hình-sql-server-trên-windows-host)
4. [Lấy IP và Test Kết nối Database](#4-lấy-ip-và-test-kết-nối-database)
5. [Cấu hình Backend và Frontend](#5-cấu-hình-backend-và-frontend)
6. [Fix Các Lỗi Thường Gặp](#6-fix-các-lỗi-thường-gặp)
7. [Quy trình CI/CD](#7-quy-trình-cicd)

---

## 1. Chuẩn bị Server Ubuntu

### 1.1. Cài đặt Docker

```bash
# Update system
sudo apt update
sudo apt upgrade -y

# Cài đặt Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Thêm user vào docker group (thay 'your-user' bằng username của bạn)
sudo usermod -aG docker your-user

# Logout và login lại để áp dụng thay đổi
# Hoặc chạy:
newgrp docker

# Kiểm tra Docker
docker --version
docker ps
```

### 1.2. Cài đặt Git

```bash
sudo apt install git -y
git --version
```

### 1.3. Lấy IP Server

```bash
# Xem tất cả IP addresses
hostname -I
# hoặc
ip addr show | grep "inet " | grep -v "127.0.0.1"

# IP chính thường là IP đầu tiên (ví dụ: 172.24.180.191)
```

### 1.4. Mở Port cho Backend

```bash
# Mở port 8080 với iptables
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT

# Kiểm tra
sudo iptables -L -n | grep 8080

# Lưu iptables rules (nếu cần)
sudo iptables-save | sudo tee /etc/iptables/rules.v4
```

---

## 2. Setup GitHub Actions Self-Hosted Runner

### 2.1. Lấy Token từ GitHub

1. **Vào GitHub Repository:**
   - https://github.com/finallbossl/test_ci-cd

2. **Vào Settings → Actions → Runners:**
   - https://github.com/finallbossl/test_ci-cd/settings/actions/runners

3. **Click "New self-hosted runner"**

4. **Chọn:**
   - OS: **Linux**
   - Architecture: **x64**

5. **Copy các lệnh hiển thị** (sẽ có dạng):
   ```bash
   mkdir actions-runner && cd actions-runner
   curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
   tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
   ./config.sh --url https://github.com/finallbossl/test_ci-cd --token YOUR_TOKEN
   ```

### 2.2. Setup Runner trên Server

**SSH vào server và chạy:**

```bash
# Tạo thư mục
mkdir -p ~/actions-runner && cd ~/actions-runner

# Download runner (thay version mới nhất)
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

# Extract
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# Config (thay YOUR_TOKEN bằng token từ GitHub)
./config.sh --url https://github.com/finallbossl/test_ci-cd --token YOUR_TOKEN

# Khi được hỏi:
# - Runner name: finalboss (hoặc tên bạn muốn)
# - Work folder: ~/actions-runner/_work (mặc định)
# - Run as service: Yes
# - User: root (hoặc user của bạn)

# Start runner service
sudo ./svc.sh install
sudo ./svc.sh start

# Kiểm tra status
sudo ./svc.sh status
```

### 2.3. Kiểm tra Runner

- Vào GitHub → Settings → Actions → Runners
- Bạn sẽ thấy runner với status "Idle" (sẵn sàng nhận jobs)

---

## 3. Cấu hình SQL Server trên Windows Host

### 3.1. Cài đặt SQL Server 2025

1. Download và cài đặt SQL Server 2025 từ Microsoft
2. Trong quá trình cài đặt:
   - Chọn **Mixed Mode Authentication** (SQL Server và Windows Authentication)
   - Đặt password cho user `sa`
   - Ghi nhớ instance name (ví dụ: `SQL2025`)

### 3.2. Cấu hình SQL Server để Accept Remote Connections

#### Bước 1: Enable TCP/IP Protocol

1. Mở **SQL Server Configuration Manager**
   - Nhấn `Win+R`, gõ: `SQLServerManager17.msc`
   - Hoặc tìm trong Start Menu

2. **SQL Server Network Configuration → Protocols for SQL2025**
   - Right-click **TCP/IP** → **Enable**

#### Bước 2: Cấu hình TCP/IP Properties

1. Right-click **TCP/IP** → **Properties**
2. Tab **IP Addresses**:
   - Cuộn xuống **IPAll**:
     - **TCP Port** = `14330` (hoặc port bạn muốn)
     - **TCP Dynamic Ports** = (để trống)
   - Với **mỗi IP** (IP1, IP2, IP3, ...):
     - **Enabled** = Yes
     - **TCP Port** = `14330`
3. Click **OK**

#### Bước 3: Enable Remote Connections

1. Mở **SQL Server Management Studio**
2. Connect to `FINALBOSS\SQL2025` (hoặc instance của bạn)
3. Right-click server → **Properties**
4. Tab **Connections**:
   - Check **"Allow remote connections to this server"**
5. Click **OK**

#### Bước 4: Restart SQL Server Service

1. Trong **SQL Server Configuration Manager**
2. **SQL Server Services → SQL Server (SQL2025)**
3. Right-click → **Restart**

### 3.3. Tạo Firewall Rule

**Chạy PowerShell as Administrator:**

```powershell
New-NetFirewallRule -DisplayName "SQL Server 2025 Port 14330" -Direction Inbound -LocalPort 14330 -Protocol TCP -Action Allow
```

### 3.4. Kiểm tra SQL Server

```powershell
# Kiểm tra port có listen không
netstat -an | findstr "14330"
# Phải thấy: 0.0.0.0:14330 hoặc IP cụ thể:14330

# Test kết nối
sqlcmd -S localhost,14330 -U sa -P 'YourPassword' -Q "SELECT @@VERSION"
```

---

## 4. Lấy IP và Test Kết nối Database

### 4.1. Lấy IP Windows Host

**Trên Windows (PowerShell):**

```powershell
# Xem tất cả IP addresses
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*"} | Select-Object IPAddress, InterfaceAlias

# IP thường là: 192.168.102.8 (hoặc IP khác tùy network)
```

### 4.2. Tìm Port SQL Server

**Trên Windows (PowerShell):**

```powershell
# Kiểm tra port SQL Server đang listen
netstat -an | findstr "14330"
# Hoặc test các port phổ biến: 1433, 14330, 14331, etc.

# Test kết nối với các port
Test-NetConnection -ComputerName 192.168.102.8 -Port 14330
```

### 4.3. Test Kết nối từ Linux Server

**Trên Linux server:**

```bash
# Test port có mở không
nc -zv 192.168.102.8 14330
# Hoặc
telnet 192.168.102.8 14330

# Nếu kết nối thành công, bạn sẽ thấy: "Connection succeeded"
```

### 4.4. Tạo Database và User (nếu cần)

**Trên Windows (SQL Server Management Studio):**

```sql
-- Tạo database
CREATE DATABASE DataTest;

-- Tạo user (nếu cần)
USE DataTest;
CREATE LOGIN app_user WITH PASSWORD = 'AppUser@123';
CREATE USER app_user FOR LOGIN app_user;
ALTER ROLE db_owner ADD MEMBER app_user;
```

---

## 5. Cấu hình Backend và Frontend

### 5.1. Cấu hình Backend Connection String

**File: `Backend/appsettings.Production.json`**

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=192.168.102.8,14330;Database=DataTest;User Id=sa;Password=YourPassword;TrustServerCertificate=True;"
  }
}
```

**Lưu ý:**
- Thay `192.168.102.8` bằng IP Windows host của bạn
- Thay `14330` bằng port SQL Server của bạn
- Thay `YourPassword` bằng password thực tế

### 5.2. Cấu hình CORS trong Backend

**File: `Backend/Program.cs`**

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins(
                "http://localhost:5173",
                "http://localhost:3000",
                "http://localhost:8080",
                "http://172.24.180.191:8080",  // Linux server IP
                "http://192.168.102.8:8080",   // Windows host IP
                "http://172.24.176.1:8080"     // Network IP
              )
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});
```

### 5.3. Cấu hình Frontend API URL

**File: `Frontend/shared/api.ts`**

```typescript
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 
  'http://172.24.180.191:8080'; // Production backend URL
```

**Lưu ý:** Thay `172.24.180.191` bằng IP Linux server của bạn

### 5.4. Cấu hình GitHub Actions Workflow

**File: `.github/workflows/deploy-production-self-hosted.yml`**

```yaml
- name: Run new container
  run: |
    docker run -d \
      --name backend-api \
      --restart unless-stopped \
      -p 8080:8080 \
      -e ASPNETCORE_ENVIRONMENT=Production \
      -e ConnectionStrings__DefaultConnection="Server=192.168.102.8,14330;Database=DataTest;User Id=sa;Password=YourPassword;TrustServerCertificate=True;" \
      ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
```

---

## 6. Fix Các Lỗi Thường Gặp

### 6.1. Lỗi: "Cannot connect to SQL Server"

**Nguyên nhân:**
- SQL Server chưa được cấu hình để accept remote connections
- Firewall chặn port
- Connection string sai

**Giải pháp:**

1. **Kiểm tra SQL Server có listen trên public interface:**
   ```powershell
   netstat -an | findstr "14330"
   # Phải thấy: 0.0.0.0:14330
   ```

2. **Kiểm tra firewall:**
   ```powershell
   Get-NetFirewallRule -DisplayName "SQL Server*" | Select-Object DisplayName, Enabled
   ```

3. **Test kết nối từ Linux server:**
   ```bash
   nc -zv 192.168.102.8 14330
   ```

### 6.2. Lỗi: "Login failed for user 'sa'"

**Nguyên nhân:**
- User `sa` bị disabled
- Password sai
- SQL Server chưa enable SQL Authentication

**Giải pháp:**

1. **Enable SQL Authentication:**
   - SQL Server Management Studio → Server Properties → Security
   - Chọn "SQL Server and Windows Authentication mode"
   - Restart SQL Server service

2. **Enable user sa:**
   - Security → Logins → sa
   - Right-click → Properties → General: Set password
   - Status → Enable "Login"

### 6.3. Lỗi: "Network is unreachable" hoặc "Connection refused"

**Nguyên nhân:**
- Container không thể kết nối đến SQL Server trên host
- IP hoặc port sai

**Giải pháp:**

1. **Dùng IP trực tiếp thay vì `host.docker.internal`:**
   ```bash
   # Connection string phải dùng IP thực tế
   Server=192.168.102.8,14330
   # Không dùng: Server=host.docker.internal,14330
   ```

2. **Kiểm tra network routing:**
   ```bash
   # Từ container, test kết nối
   docker exec backend-api ping 192.168.102.8
   ```

### 6.4. Lỗi: "CORS policy" trong Frontend

**Nguyên nhân:**
- Backend CORS chưa cho phép origin của frontend

**Giải pháp:**

1. **Thêm origin vào CORS policy trong `Backend/Program.cs`**
2. **Rebuild và redeploy backend**

### 6.5. Lỗi: "Port 8080 is not accessible"

**Nguyên nhân:**
- Firewall trên Linux server chặn port 8080

**Giải pháp:**

```bash
# Mở port 8080
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT

# Kiểm tra
sudo iptables -L -n | grep 8080
```

### 6.6. Lỗi: "Database does not exist"

**Nguyên nhân:**
- Database chưa được tạo
- Migration chưa chạy

**Giải pháp:**

1. **Tạo database thủ công:**
   ```sql
   CREATE DATABASE DataTest;
   ```

2. **Hoặc để backend tự tạo (nếu dùng `EnsureCreated()`)**

### 6.7. Lỗi: Runner không nhận jobs

**Nguyên nhân:**
- Runner service không chạy
- Runner chưa được config đúng

**Giải pháp:**

```bash
# Kiểm tra runner service
cd ~/actions-runner
sudo ./svc.sh status

# Restart nếu cần
sudo ./svc.sh stop
sudo ./svc.sh start

# Xem logs
./run.sh  # Chạy manual để xem logs
```

---

## 7. Quy trình CI/CD

### 7.1. Khi Push Code lên GitHub

```
1. Push code lên branch main/master
   ↓
2. GitHub Actions tự động trigger workflow
   ↓
3. Job 1: Build and Test
   - Chạy trên: ubuntu-latest (GitHub cloud)
   - Restore dependencies
   - Build .NET project
   - Run tests
   ↓
4. Job 2: Build and Push Docker Image
   - Chạy trên: ubuntu-latest (GitHub cloud)
   - Build Docker image
   - Push image lên GitHub Container Registry (ghcr.io)
   ↓
5. Job 3: Deploy to Production
   - Chạy trên: self-hosted (server finalboss)
   - Login to GitHub Container Registry
   - Pull Docker image mới nhất
   - Stop container cũ (backend-api)
   - Run container mới với image mới
   - Health check
   ↓
✅ Deploy thành công!
```

### 7.2. Manual Restart Backend

**Nếu cần restart backend thủ công:**

```bash
# Trên Linux server
cd ~/actions-runner/_work/test_ci-cd/test_ci-cd/Backend
./restart-backend.sh

# Hoặc manual:
docker stop backend-api && docker rm backend-api && \
docker run -d \
  --name backend-api \
  --restart unless-stopped \
  -p 8080:8080 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e ConnectionStrings__DefaultConnection="Server=192.168.102.8,14330;Database=DataTest;User Id=sa;Password=YourPassword;TrustServerCertificate=True;" \
  ghcr.io/finallbossl/test_ci-cd:latest
```

### 7.3. Kiểm tra Deployment

```bash
# Kiểm tra container
docker ps | grep backend-api

# Xem logs
docker logs backend-api --tail 50

# Test health endpoint
curl http://localhost:8080/health

# Test API endpoint
curl http://localhost:8080/api/tasks
```

---

## 📝 Checklist Setup Hoàn Chỉnh

- [ ] Docker đã cài đặt trên Linux server
- [ ] GitHub Actions Self-Hosted Runner đã setup và running
- [ ] SQL Server đã cấu hình để accept remote connections
- [ ] Firewall rules đã được tạo (port 14330 cho SQL, port 8080 cho backend)
- [ ] Connection string đã được cấu hình đúng (IP và port)
- [ ] CORS đã được cấu hình để cho phép frontend
- [ ] Frontend API URL đã được cấu hình đúng
- [ ] Test kết nối từ Linux server đến SQL Server thành công
- [ ] Test backend API từ frontend thành công
- [ ] CI/CD workflow đã chạy thành công

---

## 🔗 Links Hữu Ích

- **GitHub Repository:** https://github.com/finallbossl/test_ci-cd
- **GitHub Actions:** https://github.com/finallbossl/test_ci-cd/actions
- **Runners:** https://github.com/finallbossl/test_ci-cd/settings/actions/runners
- **Container Registry:** https://github.com/finallbossl/test_ci-cd/pkgs/container/test_ci-cd

---

## 📞 Troubleshooting

Nếu gặp lỗi, kiểm tra:

1. **Backend logs:**
   ```bash
   docker logs backend-api --tail 100
   ```

2. **Runner logs:**
   ```bash
   cd ~/actions-runner
   ./run.sh  # Xem logs real-time
   ```

3. **GitHub Actions logs:**
   - Vào GitHub → Actions → Chọn workflow run → Xem logs từng step

4. **Network connectivity:**
   ```bash
   # Từ Linux server
   ping 192.168.102.8
   nc -zv 192.168.102.8 14330
   ```

---

**Chúc bạn setup thành công! 🎉**

