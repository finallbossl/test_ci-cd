# Script kiểm tra và cấu hình SQL Server để accept remote connections
Write-Host "🔍 Checking SQL Server configuration..." -ForegroundColor Cyan

# 1. Kiểm tra SQL Server services
Write-Host "`n📋 1. SQL Server Services:" -ForegroundColor Yellow
$sqlServices = Get-Service | Where-Object {$_.Name -like '*SQL*'}
foreach ($service in $sqlServices) {
    $status = if ($service.Status -eq 'Running') { "✅" } else { "❌" }
    Write-Host "  $status $($service.Name): $($service.Status)" -ForegroundColor $(if ($service.Status -eq 'Running') { 'Green' } else { 'Red' })
}

# 2. Kiểm tra port 14330
Write-Host "`n📋 2. Checking port 14330:" -ForegroundColor Yellow
$listening = netstat -an | Select-String "14330"
if ($listening) {
    Write-Host "✅ Port 14330 is listening:" -ForegroundColor Green
    $listening | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    
    # Kiểm tra xem có listen trên 0.0.0.0 hoặc IP cụ thể không
    $hasPublic = $listening | Where-Object { $_ -match "0\.0\.0\.0:14330|172\.24\.180\.191:14330" }
    if ($hasPublic) {
        Write-Host "✅ SQL Server is listening on public interface!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  SQL Server may only be listening on localhost (127.0.0.1)" -ForegroundColor Yellow
        Write-Host "   Need to configure SQL Server to listen on all interfaces" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Port 14330 is NOT listening!" -ForegroundColor Red
    Write-Host "   SQL Server may not be configured to use port 14330" -ForegroundColor Yellow
}

# 3. Kiểm tra firewall rules
Write-Host "`n📋 3. Firewall Rules for port 14330:" -ForegroundColor Yellow
$firewallRules = Get-NetFirewallRule | Where-Object {
    $_.DisplayName -like '*SQL*' -or 
    $_.DisplayName -like '*14330*' -or
    ($_.DisplayName -like '*1433*' -and $_.DisplayName -notlike '*14331*' -and $_.DisplayName -notlike '*14332*')
} | Select-Object DisplayName, Enabled, Direction, Action

if ($firewallRules) {
    foreach ($rule in $firewallRules) {
        $status = if ($rule.Enabled) { "✅" } else { "❌" }
        Write-Host "  $status $($rule.DisplayName): Enabled=$($rule.Enabled), Direction=$($rule.Direction), Action=$($rule.Action)" -ForegroundColor $(if ($rule.Enabled) { 'Green' } else { 'Yellow' })
    }
} else {
    Write-Host "⚠️  No firewall rules found for SQL Server port 14330" -ForegroundColor Yellow
    Write-Host "   Need to create firewall rule" -ForegroundColor Yellow
}

# 4. Hướng dẫn cấu hình
Write-Host "`n📋 4. Configuration Steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "To fix SQL Server remote connection:" -ForegroundColor White
Write-Host ""
Write-Host "A. Configure SQL Server to listen on all interfaces:" -ForegroundColor Yellow
Write-Host "   1. Open SQL Server Configuration Manager" -ForegroundColor Gray
Write-Host "   2. SQL Server Network Configuration > Protocols for SQL2025" -ForegroundColor Gray
Write-Host "   3. Right-click TCP/IP > Properties" -ForegroundColor Gray
Write-Host "   4. IP Addresses tab" -ForegroundColor Gray
Write-Host "   5. Scroll to IPAll section" -ForegroundColor Gray
Write-Host "   6. Set TCP Port = 14330" -ForegroundColor Gray
Write-Host "   7. Clear TCP Dynamic Ports (leave empty)" -ForegroundColor Gray
Write-Host "   8. For each IP (IP1, IP2, etc.):" -ForegroundColor Gray
Write-Host "      - Set Enabled = Yes" -ForegroundColor Gray
Write-Host "      - Set TCP Port = 14330" -ForegroundColor Gray
Write-Host "   9. OK and Restart SQL Server service" -ForegroundColor Gray
Write-Host ""
Write-Host "B. Create Firewall Rule:" -ForegroundColor Yellow
Write-Host "   Run this command as Administrator:" -ForegroundColor Gray
Write-Host "   New-NetFirewallRule -DisplayName 'SQL Server 2025 Port 14330' -Direction Inbound -LocalPort 14330 -Protocol TCP -Action Allow" -ForegroundColor White
Write-Host ""
Write-Host "C. Enable SQL Server Authentication:" -ForegroundColor Yellow
Write-Host "   1. Open SQL Server Management Studio" -ForegroundColor Gray
Write-Host "   2. Connect to server" -ForegroundColor Gray
Write-Host "   3. Right-click server > Properties > Security" -ForegroundColor Gray
Write-Host "   4. Select 'SQL Server and Windows Authentication mode'" -ForegroundColor Gray
Write-Host "   5. Restart SQL Server service" -ForegroundColor Gray

