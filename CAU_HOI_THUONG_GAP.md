# ❓ Câu hỏi thường gặp về CI/CD

## Q1: Sau khi deploy tự động, có cần chạy backend thủ công không?

### ✅ Trả lời: KHÔNG cần!

Khi CI/CD đã deploy thành công:
- ✅ Container Docker đang chạy trên server
- ✅ API đã accessible qua port 8080
- ✅ Container tự động restart nếu bị crash (vì có `--restart unless-stopped`)
- ✅ Không cần chạy backend thủ công nữa

### 🔍 Kiểm tra container đang chạy:

**Trên server `finalboss`:**

```bash
# Xem containers đang chạy
docker ps

# Kết quả sẽ hiển thị:
# CONTAINER ID   IMAGE                                    STATUS         PORTS                    NAMES
# xxxxx         ghcr.io/finallbossl/test_ci-cd:latest    Up 5 minutes   0.0.0.0:8080->8080/tcp   backend-api
```

### 🌐 Gọi API:

**Từ bất kỳ đâu (máy local, frontend, Postman, etc.):**

```bash
# Health check
curl http://172.24.180.191:8080/health

# Hoặc từ browser
http://172.24.180.191:8080/health
```

**→ API sẽ response ngay lập tức!**

---

## Q2: Container có tự động restart không?

### ✅ Có!

Trong workflow, container được chạy với flag `--restart unless-stopped`:

```bash
docker run -d \
  --name backend-api \
  --restart unless-stopped \  # ← Tự động restart
  ...
```

**Nghĩa là:**
- ✅ Tự động restart nếu container crash
- ✅ Tự động start khi server reboot
- ✅ Chỉ dừng khi bạn manually stop

---

## Q3: Khi nào cần chạy backend thủ công?

### Chỉ khi:

1. **Container bị stop:**
   ```bash
   # Kiểm tra
   docker ps -a
   
   # Nếu thấy container ở trạng thái "Exited"
   # Có thể start lại:
   docker start backend-api
   ```

2. **Development local:**
   - Khi develop trên máy local
   - Chạy: `dotnet run` hoặc `docker-compose up`

3. **Debug:**
   - Khi cần debug, có thể stop container và chạy thủ công

---

## Q4: Làm sao biết container đang chạy?

### Các cách kiểm tra:

#### 1. Kiểm tra trên server:

```bash
# Xem containers
docker ps

# Xem logs
docker logs backend-api

# Xem logs real-time
docker logs -f backend-api
```

#### 2. Test API:

```bash
# Health check
curl http://172.24.180.191:8080/health

# Hoặc test endpoint khác
curl http://172.24.180.191:8080/api/tasks
```

#### 3. Kiểm tra trên GitHub Actions:

- Vào: https://github.com/finallbossl/test_ci-cd/actions
- Xem workflow run mới nhất
- Step "Health check" phải pass

---

## Q5: Nếu muốn update code, làm gì?

### Chỉ cần push code:

```bash
# Từ máy local
git add .
git commit -m "Update code"
git push origin main
```

**→ CI/CD sẽ tự động:**
1. Build code mới
2. Build Docker image mới
3. Stop container cũ
4. Run container mới với code mới
5. Health check

**→ Không cần làm gì thêm!**

---

## Q6: Container có chạy khi server reboot không?

### ✅ Có!

Vì có flag `--restart unless-stopped`, container sẽ tự động start khi server reboot.

**Kiểm tra:**

```bash
# Reboot server
sudo reboot

# Sau khi server boot lại, kiểm tra
docker ps
# Container sẽ tự động chạy lại
```

---

## Q7: Làm sao stop/start container thủ công?

### Stop container:

```bash
docker stop backend-api
```

### Start container:

```bash
docker start backend-api
```

### Restart container:

```bash
docker restart backend-api
```

### Xóa container (cẩn thận!):

```bash
# Stop và xóa
docker stop backend-api
docker rm backend-api

# CI/CD sẽ tự động tạo lại khi deploy
```

---

## Q8: Làm sao xem logs của API?

### Xem logs container:

```bash
# Xem logs
docker logs backend-api

# Xem logs real-time
docker logs -f backend-api

# Xem logs với timestamp
docker logs -f --timestamps backend-api

# Xem logs từ dòng cuối
docker logs --tail 100 backend-api
```

---

## Q9: Nếu API không hoạt động, làm gì?

### Checklist:

1. **Kiểm tra container đang chạy:**
   ```bash
   docker ps
   ```

2. **Kiểm tra logs:**
   ```bash
   docker logs backend-api
   ```

3. **Kiểm tra port:**
   ```bash
   netstat -tuln | grep 8080
   # Hoặc
   ss -tuln | grep 8080
   ```

4. **Kiểm tra firewall:**
   ```bash
   sudo ufw status
   # Đảm bảo port 8080 đã mở
   ```

5. **Test từ server:**
   ```bash
   curl http://localhost:8080/health
   ```

6. **Kiểm tra database connection:**
   - Xem logs để kiểm tra connection string
   - Đảm bảo SQL Server đang chạy

---

## Q10: Có cần chạy migrations thủ công không?

### Tùy vào setup:

Nếu trong `Program.cs` đã có:
```csharp
context.Database.EnsureCreated();
```

→ Migrations sẽ tự động chạy khi container start.

Nếu cần chạy migrations thủ công:

```bash
# Vào trong container
docker exec -it backend-api bash

# Hoặc chạy từ local
dotnet ef database update --project Backend --connection "your-connection-string"
```

---

## 📝 Tóm tắt

### ✅ Sau khi deploy tự động:

- **KHÔNG cần** chạy backend thủ công
- **KHÔNG cần** start container thủ công
- **KHÔNG cần** làm gì thêm

### ✅ Container sẽ:

- Tự động chạy
- Tự động restart nếu crash
- Tự động start khi server reboot
- API accessible ngay lập tức

### ✅ Chỉ cần:

- Push code mới → Tự động deploy
- Gọi API → Hoạt động ngay

---

**🎉 Vậy là bạn chỉ cần push code, mọi thứ sẽ tự động!**

