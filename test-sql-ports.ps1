# Script test các port phổ biến của SQL Server
$serverIP = "172.24.180.191"
$username = "sa"
$password = "28122003"
$database = "DataTest"

# Test các port phổ biến
$ports = @(1433, 1434, 14330, 14331, 14332, 14333, 14334, 14335)

Write-Host "🔍 Testing SQL Server ports on $serverIP..." -ForegroundColor Cyan
Write-Host ""

$foundPorts = @()

foreach ($port in $ports) {
    Write-Host "Testing port $port..." -NoNewline
    $portTest = Test-NetConnection -ComputerName $serverIP -Port $port -WarningAction SilentlyContinue
    
    if ($portTest.TcpTestSucceeded) {
        Write-Host " ✅ OPEN" -ForegroundColor Green
        
        # Test SQL connection
        try {
            $connString = "Server=$serverIP,$port;Database=$database;User Id=$username;Password=$password;TrustServerCertificate=True;"
            $connection = New-Object System.Data.SqlClient.SqlConnection($connString)
            $connection.Open()
            $connection.Close()
            Write-Host "  ✅ SQL connection successful!" -ForegroundColor Green
            $foundPorts += $port
        } catch {
            Write-Host "  ⚠️  Port open but SQL connection failed: $_" -ForegroundColor Yellow
        }
    } else {
        Write-Host " ❌ CLOSED" -ForegroundColor Red
    }
}

Write-Host ""
if ($foundPorts.Count -gt 0) {
    Write-Host "✅ Found working ports: $($foundPorts -join ', ')" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Use this connection string:" -ForegroundColor Cyan
    $bestPort = $foundPorts[0]
    Write-Host "Server=$serverIP,$bestPort;Database=$database;User Id=$username;Password=$password;TrustServerCertificate=True;" -ForegroundColor White
} else {
    Write-Host "❌ No working ports found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 Next steps:" -ForegroundColor Yellow
    Write-Host "1. Check SQL Server Configuration Manager" -ForegroundColor White
    Write-Host "2. Enable TCP/IP protocol" -ForegroundColor White
    Write-Host "3. Set static port 1433 for SQL2025 instance" -ForegroundColor White
    Write-Host "4. Restart SQL Server service" -ForegroundColor White
}

