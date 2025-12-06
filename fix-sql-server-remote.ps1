# Script tự động cấu hình SQL Server để accept remote connections
# Chạy script này với quyền Administrator

Write-Host "🔧 Configuring SQL Server for remote connections..." -ForegroundColor Cyan

# Kiểm tra quyền Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "   Please run PowerShell as Administrator" -ForegroundColor Yellow
    exit 1
}

# 1. Kiểm tra port hiện tại
Write-Host "`n📋 1. Checking current port configuration..." -ForegroundColor Yellow
$currentPort = netstat -an | Select-String "14330"
if ($currentPort) {
    Write-Host "✅ Port 14330 is in use:" -ForegroundColor Green
    $currentPort | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    
    $isPublic = $currentPort | Where-Object { $_ -match "0\.0\.0\.0:14330|172\.24\.180\.191:14330" }
    if (-not $isPublic) {
        Write-Host "⚠️  Port is only listening on localhost" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Port 14330 is not listening" -ForegroundColor Yellow
}

# 2. Tạo firewall rule
Write-Host "`n📋 2. Creating firewall rule..." -ForegroundColor Yellow
try {
    $existingRule = Get-NetFirewallRule -DisplayName "SQL Server 2025 Port 14330" -ErrorAction SilentlyContinue
    if ($existingRule) {
        Write-Host "✅ Firewall rule already exists" -ForegroundColor Green
        if (-not $existingRule.Enabled) {
            Enable-NetFirewallRule -DisplayName "SQL Server 2025 Port 14330"
            Write-Host "✅ Firewall rule enabled" -ForegroundColor Green
        }
    } else {
        New-NetFirewallRule -DisplayName "SQL Server 2025 Port 14330" -Direction Inbound -LocalPort 14330 -Protocol TCP -Action Allow -ErrorAction Stop
        Write-Host "✅ Firewall rule created successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Failed to create firewall rule: $_" -ForegroundColor Red
    Write-Host "   Please create manually:" -ForegroundColor Yellow
    Write-Host "   New-NetFirewallRule -DisplayName 'SQL Server 2025 Port 14330' -Direction Inbound -LocalPort 14330 -Protocol TCP -Action Allow" -ForegroundColor Gray
}

# 3. Hướng dẫn cấu hình SQL Server
Write-Host "`n📋 3. SQL Server Configuration (Manual Steps):" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  You need to configure SQL Server manually:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Step 1: Open SQL Server Configuration Manager" -ForegroundColor Cyan
Write-Host "   - Press Win+R, type: SQLServerManager17.msc" -ForegroundColor Gray
Write-Host "   - Or search 'SQL Server Configuration Manager' in Start Menu" -ForegroundColor Gray
Write-Host ""
Write-Host "Step 2: Enable TCP/IP Protocol" -ForegroundColor Cyan
Write-Host "   - SQL Server Network Configuration > Protocols for SQL2025" -ForegroundColor Gray
Write-Host "   - Right-click 'TCP/IP' > Enable (if disabled)" -ForegroundColor Gray
Write-Host ""
Write-Host "Step 3: Configure TCP/IP Properties" -ForegroundColor Cyan
Write-Host "   - Right-click 'TCP/IP' > Properties" -ForegroundColor Gray
Write-Host "   - Go to 'IP Addresses' tab" -ForegroundColor Gray
Write-Host "   - Scroll down to 'IPAll' section" -ForegroundColor Gray
Write-Host "   - Set 'TCP Port' = 14330" -ForegroundColor Gray
Write-Host "   - Clear 'TCP Dynamic Ports' (leave empty)" -ForegroundColor Gray
Write-Host "   - For each IP address (IP1, IP2, IP3, etc.):" -ForegroundColor Gray
Write-Host "     * Set 'Enabled' = Yes" -ForegroundColor Gray
Write-Host "     * Set 'TCP Port' = 14330" -ForegroundColor Gray
Write-Host "   - Click OK" -ForegroundColor Gray
Write-Host ""
Write-Host "Step 4: Restart SQL Server Service" -ForegroundColor Cyan
Write-Host "   - SQL Server Services > SQL Server (SQL2025)" -ForegroundColor Gray
Write-Host "   - Right-click > Restart" -ForegroundColor Gray
Write-Host ""

# 4. Kiểm tra sau khi cấu hình
Write-Host "📋 4. After configuration, run this to verify:" -ForegroundColor Yellow
Write-Host "   netstat -an | findstr '14330'" -ForegroundColor White
Write-Host "   You should see: 0.0.0.0:14330" -ForegroundColor Gray
Write-Host ""

# 5. Test connection
Write-Host "📋 5. Test from Linux server:" -ForegroundColor Yellow
Write-Host "   nc -zv 172.24.180.191 14330" -ForegroundColor White
Write-Host ""

Write-Host "✨ Configuration steps completed!" -ForegroundColor Green
Write-Host "   Please follow the manual steps above to configure SQL Server." -ForegroundColor Yellow

