# Script test kết nối SQL Server từ Windows host
Write-Host "🔍 Testing SQL Server connection..." -ForegroundColor Cyan

$serverIP = "172.24.180.191"
$port = 14330

# 1. Test port connectivity
Write-Host "`n📋 1. Testing port connectivity..." -ForegroundColor Yellow
$portTest = Test-NetConnection -ComputerName $serverIP -Port $port -WarningAction SilentlyContinue
if ($portTest.TcpTestSucceeded) {
    Write-Host "✅ Port $port is accessible from Windows host!" -ForegroundColor Green
} else {
    Write-Host "❌ Port $port is NOT accessible from Windows host!" -ForegroundColor Red
    Write-Host "   This means firewall is blocking or SQL Server is not configured correctly" -ForegroundColor Yellow
}

# 2. Check firewall rules
Write-Host "`n📋 2. Checking firewall rules..." -ForegroundColor Yellow
$firewallRules = Get-NetFirewallRule | Where-Object {
    $_.DisplayName -like '*SQL*' -or 
    $_.DisplayName -like '*14330*' -or
    ($_.LocalPort -eq 14330)
} | Select-Object DisplayName, Enabled, Direction, Action, LocalPort

if ($firewallRules) {
    foreach ($rule in $firewallRules) {
        $status = if ($rule.Enabled) { "✅" } else { "❌" }
        Write-Host "  $status $($rule.DisplayName): Enabled=$($rule.Enabled), Direction=$($rule.Direction), Action=$($rule.Action)" -ForegroundColor $(if ($rule.Enabled) { 'Green' } else { 'Yellow' })
    }
} else {
    Write-Host "⚠️  No firewall rules found for port 14330" -ForegroundColor Yellow
}

# 3. Check if SQL Server is listening on all interfaces
Write-Host "`n📋 3. Checking SQL Server listening addresses..." -ForegroundColor Yellow
$listening = netstat -an | Select-String "14330"
if ($listening) {
    Write-Host "SQL Server is listening on:" -ForegroundColor Cyan
    $listening | ForEach-Object { 
        Write-Host "  $_" -ForegroundColor Gray
        if ($_ -match "0\.0\.0\.0:14330") {
            Write-Host "    ✅ Listening on all interfaces (0.0.0.0)" -ForegroundColor Green
        } elseif ($_ -match "127\.0\.0\.1:14330") {
            Write-Host "    ⚠️  Only listening on localhost (127.0.0.1)" -ForegroundColor Yellow
        } elseif ($_ -match "172\.24\.180\.191:14330") {
            Write-Host "    ✅ Listening on specific IP (172.24.180.191)" -ForegroundColor Green
        }
    }
} else {
    Write-Host "❌ Port 14330 is not listening!" -ForegroundColor Red
}

# 4. Test SQL connection
Write-Host "`n📋 4. Testing SQL connection..." -ForegroundColor Yellow
try {
    $connectionString = "Server=$serverIP,$port;Database=master;User Id=sa;Password=28122003;TrustServerCertificate=True;Connect Timeout=5;"
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    Write-Host "✅ SQL connection successful!" -ForegroundColor Green
    $connection.Close()
} catch {
    Write-Host "❌ SQL connection failed: $_" -ForegroundColor Red
    Write-Host "   Error details: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 5. Recommendations
Write-Host "`n📋 5. Recommendations:" -ForegroundColor Cyan
if (-not $portTest.TcpTestSucceeded) {
    Write-Host ""
    Write-Host "⚠️  Port is not accessible. Try these steps:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "A. Check Windows Firewall:" -ForegroundColor White
    Write-Host "   1. Open Windows Defender Firewall with Advanced Security" -ForegroundColor Gray
    Write-Host "   2. Check Inbound Rules for port 14330" -ForegroundColor Gray
    Write-Host "   3. If rule exists but disabled, enable it" -ForegroundColor Gray
    Write-Host "   4. If rule doesn't exist, create it:" -ForegroundColor Gray
    Write-Host "      New-NetFirewallRule -DisplayName 'SQL Server 2025 Port 14330' -Direction Inbound -LocalPort 14330 -Protocol TCP -Action Allow" -ForegroundColor White
    Write-Host ""
    Write-Host "B. Check SQL Server Configuration:" -ForegroundColor White
    Write-Host "   1. Open SQL Server Configuration Manager" -ForegroundColor Gray
    Write-Host "   2. SQL Server Network Configuration > Protocols for SQL2025" -ForegroundColor Gray
    Write-Host "   3. TCP/IP > Properties > IP Addresses" -ForegroundColor Gray
    Write-Host "   4. Ensure all IP addresses have Enabled=Yes and TCP Port=14330" -ForegroundColor Gray
    Write-Host "   5. Restart SQL Server service" -ForegroundColor Gray
    Write-Host ""
    Write-Host "C. Check if SQL Server accepts remote connections:" -ForegroundColor White
    Write-Host "   1. Open SQL Server Management Studio" -ForegroundColor Gray
    Write-Host "   2. Connect to server" -ForegroundColor Gray
    Write-Host "   3. Right-click server > Properties > Connections" -ForegroundColor Gray
    Write-Host "   4. Check 'Allow remote connections to this server'" -ForegroundColor Gray
}

