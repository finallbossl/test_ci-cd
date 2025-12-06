# Script cấu hình SQL Server 2025 (17.0.1000.7) để accept remote connections
# Chạy với quyền Administrator

Write-Host "🔧 Configuring SQL Server 2025 (17.0.1000.7) for remote connections..." -ForegroundColor Cyan

# Kiểm tra quyền Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "   Please run PowerShell as Administrator" -ForegroundColor Yellow
    exit 1
}

# 1. Kiểm tra SQL Server version
Write-Host "`n📋 1. Checking SQL Server version..." -ForegroundColor Yellow
try {
    $sqlVersion = Invoke-Sqlcmd -ServerInstance "localhost\SQL2025" -Query "SELECT @@VERSION" -ErrorAction SilentlyContinue
    if ($sqlVersion) {
        Write-Host "✅ SQL Server is running" -ForegroundColor Green
        Write-Host "   Version info: $($sqlVersion.Column1)" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠️  Could not query SQL Server version" -ForegroundColor Yellow
}

# 2. Enable remote access via SQL query
Write-Host "`n📋 2. Enabling remote access..." -ForegroundColor Yellow
try {
    $enableRemote = @"
EXEC sp_configure 'remote access', 1;
RECONFIGURE;
EXEC sp_configure 'remote access';
"@
    Invoke-Sqlcmd -ServerInstance "localhost\SQL2025" -Query $enableRemote -ErrorAction Stop
    Write-Host "✅ Remote access enabled" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not enable remote access via SQL: $_" -ForegroundColor Yellow
    Write-Host "   You may need to enable it manually in SSMS" -ForegroundColor Gray
}

# 3. Tạo/enable firewall rule
Write-Host "`n📋 3. Configuring firewall..." -ForegroundColor Yellow
try {
    $existingRule = Get-NetFirewallRule -DisplayName "SQL Server 2025 Port 14330" -ErrorAction SilentlyContinue
    if ($existingRule) {
        if (-not $existingRule.Enabled) {
            Enable-NetFirewallRule -DisplayName "SQL Server 2025 Port 14330"
            Write-Host "✅ Firewall rule enabled" -ForegroundColor Green
        } else {
            Write-Host "✅ Firewall rule already enabled" -ForegroundColor Green
        }
    } else {
        New-NetFirewallRule -DisplayName "SQL Server 2025 Port 14330" -Direction Inbound -LocalPort 14330 -Protocol TCP -Action Allow -ErrorAction Stop
        Write-Host "✅ Firewall rule created" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Failed to configure firewall: $_" -ForegroundColor Red
}

# 4. Kiểm tra port listening
Write-Host "`n📋 4. Checking port status..." -ForegroundColor Yellow
$listening = netstat -an | Select-String "14330"
if ($listening) {
    Write-Host "✅ Port 14330 is listening:" -ForegroundColor Green
    $listening | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    
    $isPublic = $listening | Where-Object { $_ -match "0\.0\.0\.0:14330|172\.24\.180\.191:14330" }
    if ($isPublic) {
        Write-Host "✅ SQL Server is listening on public interface!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  SQL Server may only be listening on localhost" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Port 14330 is not listening!" -ForegroundColor Red
    Write-Host "   Please configure TCP/IP in SQL Server Configuration Manager" -ForegroundColor Yellow
}

# 5. Hướng dẫn cấu hình SQL Server Configuration Manager
Write-Host "`n📋 5. SQL Server Configuration Manager Steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  IMPORTANT: Configure SQL Server Configuration Manager manually:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Step 1: Open SQL Server Configuration Manager" -ForegroundColor White
Write-Host "   - Press Win+R, type: SQLServerManager17.msc" -ForegroundColor Gray
Write-Host "   - Or: C:\Windows\SysWOW64\SQLServerManager17.msc" -ForegroundColor Gray
Write-Host ""
Write-Host "Step 2: Enable TCP/IP Protocol" -ForegroundColor White
Write-Host "   - SQL Server Network Configuration > Protocols for SQL2025" -ForegroundColor Gray
Write-Host "   - Right-click 'TCP/IP' > Enable" -ForegroundColor Gray
Write-Host ""
Write-Host "Step 3: Configure TCP/IP Properties" -ForegroundColor White
Write-Host "   - Right-click 'TCP/IP' > Properties" -ForegroundColor Gray
Write-Host "   - Tab 'IP Addresses'" -ForegroundColor Gray
Write-Host "   - Scroll to 'IPAll' section:" -ForegroundColor Gray
Write-Host "     * TCP Port = 14330" -ForegroundColor Gray
Write-Host "     * TCP Dynamic Ports = (empty/blank)" -ForegroundColor Gray
Write-Host "   - For EACH IP address (IP1, IP2, IP3, etc.):" -ForegroundColor Gray
Write-Host "     * Enabled = Yes" -ForegroundColor Gray
Write-Host "     * TCP Port = 14330" -ForegroundColor Gray
Write-Host "   - Click OK" -ForegroundColor Gray
Write-Host ""
Write-Host "Step 4: Restart SQL Server Service" -ForegroundColor White
Write-Host "   - SQL Server Services > SQL Server (SQL2025)" -ForegroundColor Gray
Write-Host "   - Right-click > Restart" -ForegroundColor Gray
Write-Host ""

# 6. Enable remote connections in SSMS
Write-Host "📋 6. Enable Remote Connections in SSMS:" -ForegroundColor Cyan
Write-Host "   1. Open SQL Server Management Studio" -ForegroundColor Gray
Write-Host "   2. Connect to FINALBOSS\SQL2025" -ForegroundColor Gray
Write-Host "   3. Right-click server > Properties" -ForegroundColor Gray
Write-Host "   4. Tab 'Connections'" -ForegroundColor Gray
Write-Host "   5. Check 'Allow remote connections to this server'" -ForegroundColor Gray
Write-Host "   6. Click OK" -ForegroundColor Gray
Write-Host ""

# 7. Test commands
Write-Host "📋 7. After configuration, test with:" -ForegroundColor Cyan
Write-Host "   # From Windows:" -ForegroundColor Gray
Write-Host "   Test-NetConnection -ComputerName 172.24.180.191 -Port 14330" -ForegroundColor White
Write-Host "   sqlcmd -S 172.24.180.191,14330 -U sa -P '28122003' -Q 'SELECT @@VERSION'" -ForegroundColor White
Write-Host ""
Write-Host "   # From Linux server:" -ForegroundColor Gray
Write-Host "   nc -zv 172.24.180.191 14330" -ForegroundColor White
Write-Host ""

Write-Host "✨ Configuration script completed!" -ForegroundColor Green
Write-Host "   Please follow the manual steps above to complete configuration." -ForegroundColor Yellow

