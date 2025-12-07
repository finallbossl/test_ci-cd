# 🧪 Test PostgreSQL Connection String

Hướng dẫn test connection string PostgreSQL của bạn trước khi deploy.

## Connection String của bạn:

```
postgresql://db_test_ip24_user:JdETR5HQymycpyM7qHay0vxQcpFnBhtl@dpg-d4qcvm8gjchc73ba1m9g-a.singapore-postgres.render.com/db_test_ip24
```

---

## Cách 1: Test bằng psql (Command Line)

### Windows:

1. **Download PostgreSQL Client**:
   - https://www.postgresql.org/download/windows/
   - Hoặc dùng psql trong Docker

2. **Test connection**:
   ```powershell
   # Nếu đã install PostgreSQL
   psql "postgresql://db_test_ip24_user:JdETR5HQymycpyM7qHay0vxQcpFnBhtl@dpg-d4qcvm8gjchc73ba1m9g-a.singapore-postgres.render.com/db_test_ip24"
   ```

3. **Test query**:
   ```sql
   SELECT version();
   SELECT current_database();
   ```

### Linux/Mac:

```bash
# Install psql nếu chưa có
sudo apt install postgresql-client  # Linux
brew install postgresql              # Mac

# Test connection
psql "postgresql://db_test_ip24_user:JdETR5HQymycpyM7qHay0vxQcpFnBhtl@dpg-d4qcvm8gjchc73ba1m9g-a.singapore-postgres.render.com/db_test_ip24"

# Test query
SELECT version();
SELECT current_database();
\q  # Exit
```

---

## Cách 2: Test bằng Docker

```bash
# Run PostgreSQL client trong Docker
docker run -it --rm postgres:15 psql "postgresql://db_test_ip24_user:JdETR5HQymycpyM7qHay0vxQcpFnBhtl@dpg-d4qcvm8gjchc73ba1m9g-a.singapore-postgres.render.com/db_test_ip24"

# Test query
SELECT version();
\q
```

---

## Cách 3: Test bằng .NET Application

### Tạo test script:

Tạo file `Backend/TestConnection.cs`:

```csharp
using Npgsql;

var connectionString = "postgresql://db_test_ip24_user:JdETR5HQymycpyM7qHay0vxQcpFnBhtl@dpg-d4qcvm8gjchc73ba1m9g-a.singapore-postgres.render.com/db_test_ip24";

try
{
    using var connection = new NpgsqlConnection(connectionString);
    connection.Open();
    Console.WriteLine("✅ Connection successful!");
    
    using var cmd = new NpgsqlCommand("SELECT version(), current_database()", connection);
    using var reader = cmd.ExecuteReader();
    
    while (reader.Read())
    {
        Console.WriteLine($"Version: {reader[0]}");
        Console.WriteLine($"Database: {reader[1]}");
    }
}
catch (Exception ex)
{
    Console.WriteLine($"❌ Connection failed: {ex.Message}");
}
```

### Run test:

```bash
cd Backend
dotnet run --project TestConnection.csproj
```

---

## Cách 4: Test qua Render Dashboard

1. Vào **Database Service** trên Render
2. Click **"Connections"** tab
3. Có thể test connection từ đây

---

## ✅ Kết Quả Mong Đợi

Nếu connection thành công, bạn sẽ thấy:
- ✅ Connected to database
- ✅ Database name: `db_test_ip24`
- ✅ PostgreSQL version

---

## ❌ Nếu Connection Failed

### Kiểm tra:

1. **Connection string đúng chưa?**
   - Copy chính xác từ Render dashboard
   - Không có khoảng trắng thừa

2. **Database service đang running?**
   - Vào Render dashboard → Database service
   - Kiểm tra status: "Available"

3. **Firewall/Network?**
   - Render PostgreSQL cho phép connection từ bất kỳ đâu
   - Không cần whitelist IP

4. **SSL Mode?**
   - Render yêu cầu SSL
   - Connection string đã có SSL mode tự động

---

## 🔐 Lưu Ý Bảo Mật

⚠️ **KHÔNG commit connection string vào Git!**

- Connection string chứa password
- Chỉ set trong Render Environment Variables
- Hoặc dùng Render Secrets (nếu có)

---

## 📝 Connection String Format

Connection string của bạn:
```
postgresql://[user]:[password]@[host]:[port]/[database]
```

Breakdown:
- **User**: `db_test_ip24_user`
- **Password**: `JdETR5HQymycpyM7qHay0vxQcpFnBhtl`
- **Host**: `dpg-d4qcvm8gjchc73ba1m9g-a.singapore-postgres.render.com`
- **Port**: `5432` (default, không cần specify)
- **Database**: `db_test_ip24`

---

**Sau khi test thành công, bạn có thể deploy với confidence! 🚀**



