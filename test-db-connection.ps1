# Script test kết nối SQL Server từ Windows host
# Chạy script này trên Windows host (không phải Linux server)

Write-Host "🔍 Testing SQL Server connection..." -ForegroundColor Cyan

$server = "172.24.180.191"
$port = "1433"
$database = "DataTest"
$username = "sa"
$password = "28122003"

# Test 1: Test với SQL Server Management Studio connection string format
Write-Host "`n📋 Test 1: Connection string format (SSMS style)" -ForegroundColor Yellow
$connectionString1 = "Data Source=$server,$port;Initial Catalog=$database;User ID=$username;Password=$password;TrustServerCertificate=True;"
Write-Host "Connection String: $($connectionString1 -replace "Password=[^;]+", "Password=***")"

# Test 2: Test với .NET format
Write-Host "`n📋 Test 2: Connection string format (.NET style)" -ForegroundColor Yellow
$connectionString2 = "Server=$server,$port;Database=$database;User Id=$username;Password=$password;TrustServerCertificate=True;"
Write-Host "Connection String: $($connectionString2 -replace "Password=[^;]+", "Password=***")"

# Test 3: Test với sqlcmd (nếu có)
Write-Host "`n📋 Test 3: Testing with sqlcmd..." -ForegroundColor Yellow
try {
    $result = sqlcmd -S "$server,$port" -U $username -P $password -d $database -Q "SELECT @@VERSION" -W
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ sqlcmd connection successful!" -ForegroundColor Green
        Write-Host $result
    } else {
        Write-Host "❌ sqlcmd connection failed!" -ForegroundColor Red
    }
} catch {
    Write-Host "⚠️  sqlcmd not found or error: $_" -ForegroundColor Yellow
}

# Test 4: Test với Test-NetConnection (kiểm tra port)
Write-Host "`n📋 Test 4: Testing port connectivity..." -ForegroundColor Yellow
$portTest = Test-NetConnection -ComputerName $server -Port $port -WarningAction SilentlyContinue
if ($portTest.TcpTestSucceeded) {
    Write-Host "✅ Port $port is open and accessible!" -ForegroundColor Green
} else {
    Write-Host "❌ Port $port is NOT accessible!" -ForegroundColor Red
    Write-Host "   This could mean:" -ForegroundColor Yellow
    Write-Host "   - SQL Server is not listening on port $port" -ForegroundColor Yellow
    Write-Host "   - Firewall is blocking port $port" -ForegroundColor Yellow
    Write-Host "   - SQL Server Browser service is not running" -ForegroundColor Yellow
}

# Test 5: Kiểm tra SQL Server instance
Write-Host "`n📋 Test 5: Checking SQL Server instances..." -ForegroundColor Yellow
Write-Host "   Run this command to check SQL Server instances:" -ForegroundColor Cyan
Write-Host "   Get-Service | Where-Object {`$_.Name -like '*SQL*'}" -ForegroundColor White

Write-Host "`n📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Check if SQL Server is running:" -ForegroundColor White
Write-Host "   Get-Service | Where-Object {`$_.Name -like '*SQL*'}" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Check SQL Server configuration:" -ForegroundColor White
Write-Host "   - Open SQL Server Configuration Manager" -ForegroundColor Gray
Write-Host "   - Check if TCP/IP is enabled" -ForegroundColor Gray
Write-Host "   - Check if port 1433 is configured" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Check SQL Server Authentication:" -ForegroundColor White
Write-Host "   - Open SQL Server Management Studio" -ForegroundColor Gray
Write-Host "   - Connect to server" -ForegroundColor Gray
Write-Host "   - Right-click server > Properties > Security" -ForegroundColor Gray
Write-Host "   - Ensure 'SQL Server and Windows Authentication mode' is selected" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Check sa user:" -ForegroundColor White
Write-Host "   - In SSMS: Security > Logins > sa" -ForegroundColor Gray
Write-Host "   - Right-click > Properties > General" -ForegroundColor Gray
Write-Host "   - Ensure password is set correctly" -ForegroundColor Gray
Write-Host "   - Go to Status > Ensure 'Login' is enabled" -ForegroundColor Gray

