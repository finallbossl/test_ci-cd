# Database Setup

## Connection String
Database đã được cấu hình với connection string:
```
Server=FINALBOSS\SQLEXPRESS;Database=DataTest;Trusted_Connection=True;TrustServerCertificate=True;
```

## Tự động tạo Database
Ứng dụng sẽ tự động tạo database và tables khi chạy lần đầu (sử dụng `EnsureCreated()`).

## Chạy Migration (Tùy chọn - nếu muốn sử dụng migrations thay vì EnsureCreated)

Nếu bạn muốn sử dụng migrations thay vì `EnsureCreated()`, hãy làm theo các bước sau:

1. Tạo migration:
```bash
cd Backend/Backend
dotnet ef migrations add InitialCreate
```

2. Cập nhật database:
```bash
dotnet ef database update
```

## Kiểm tra kết nối
Đảm bảo SQL Server đang chạy và có thể truy cập với connection string đã cấu hình.

