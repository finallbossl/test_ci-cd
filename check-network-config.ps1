# Script kiểm tra cấu hình network của Windows host
Write-Host "🔍 Checking network configuration..." -ForegroundColor Cyan

# 1. Kiểm tra tất cả IP addresses
Write-Host "`n📋 1. All IP addresses on this machine:" -ForegroundColor Yellow
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*"} | Select-Object IPAddress, InterfaceAlias, PrefixLength
foreach ($ip in $ipAddresses) {
    Write-Host "  ✅ $($ip.IPAddress)/$($ip.PrefixLength) - $($ip.InterfaceAlias)" -ForegroundColor Green
}

# 2. Kiểm tra default gateway
Write-Host "`n📋 2. Default Gateway:" -ForegroundColor Yellow
$gateway = Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object -First 1
if ($gateway) {
    Write-Host "  Gateway: $($gateway.NextHop)" -ForegroundColor Cyan
    Write-Host "  Interface: $($gateway.InterfaceAlias)" -ForegroundColor Cyan
}

# 3. Kiểm tra IP 172.24.180.191
Write-Host "`n📋 3. Checking IP 172.24.180.191:" -ForegroundColor Yellow
$targetIP = "172.24.180.191"
$isLocal = $ipAddresses | Where-Object {$_.IPAddress -eq $targetIP}
if ($isLocal) {
    Write-Host "  ✅ $targetIP is a local IP on this machine" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  $targetIP is NOT a local IP on this machine" -ForegroundColor Yellow
    Write-Host "  Current local IPs:" -ForegroundColor Gray
    $ipAddresses | ForEach-Object { Write-Host "    - $($_.IPAddress)" -ForegroundColor Gray }
}

# 4. Test connectivity
Write-Host "`n📋 4. Testing connectivity:" -ForegroundColor Yellow
$testIPs = @("172.24.180.191", "192.168.102.8", "localhost")
foreach ($testIP in $testIPs) {
    $test = Test-NetConnection -ComputerName $testIP -Port 14330 -WarningAction SilentlyContinue
    if ($test.TcpTestSucceeded) {
        Write-Host "  ✅ Port 14330 is accessible via $testIP" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Port 14330 is NOT accessible via $testIP" -ForegroundColor Red
    }
}

# 5. Recommendations
Write-Host "`n📋 5. Recommendations:" -ForegroundColor Cyan
Write-Host ""
Write-Host "For Linux server connection, use one of these IPs:" -ForegroundColor White
$ipAddresses | ForEach-Object { 
    Write-Host "  - $($_.IPAddress)" -ForegroundColor Green
}
Write-Host ""
Write-Host "Update connection string in:" -ForegroundColor White
Write-Host "  - Backend/appsettings.Production.json" -ForegroundColor Gray
Write-Host "  - .github/workflows/deploy-production*.yml" -ForegroundColor Gray
Write-Host "  - restart-backend.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "Or if 172.24.180.191 is the correct IP, ensure:" -ForegroundColor Yellow
Write-Host "  1. Windows host has this IP assigned" -ForegroundColor Gray
Write-Host "  2. Linux server can route to this IP" -ForegroundColor Gray
Write-Host "  3. No firewall blocking between networks" -ForegroundColor Gray

