# Script tìm port của SQL Server instance SQL2025
# Chạy script này trên Windows host

Write-Host "🔍 Finding SQL Server SQL2025 port..." -ForegroundColor Cyan

# Method 1: Query SQL Server directly
Write-Host "`n📋 Method 1: Querying SQL Server..." -ForegroundColor Yellow
try {
    $query = @"
SELECT 
    local_net_address,
    local_tcp_port,
    state_desc
FROM sys.dm_exec_connections 
WHERE session_id = @@SPID
"@
    
    $connectionString = "Data Source=FINALBOSS\SQL2025;Initial Catalog=master;User ID=sa;Password=28122003;TrustServerCertificate=True;"
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    
    $connection.Open()
    $reader = $command.ExecuteReader()
    
    while ($reader.Read()) {
        $address = $reader["local_net_address"]
        $port = $reader["local_tcp_port"]
        $state = $reader["state_desc"]
        Write-Host "✅ Found: Address=$address, Port=$port, State=$state" -ForegroundColor Green
    }
    
    $reader.Close()
    $connection.Close()
} catch {
    Write-Host "❌ Error querying SQL Server: $_" -ForegroundColor Red
}

# Method 2: Check SQL Server Configuration Manager registry
Write-Host "`n📋 Method 2: Checking registry..." -ForegroundColor Yellow
try {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL*\MSSQLServer\SuperSocketNetLib\Tcp\IPAll"
    $regEntries = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
    
    if ($regEntries) {
        foreach ($entry in $regEntries) {
            $tcpPort = $entry.TcpPort
            $tcpDynamicPorts = $entry.TcpDynamicPorts
            Write-Host "Instance: $($entry.PSChildName)" -ForegroundColor Cyan
            if ($tcpPort) {
                Write-Host "  TCP Port: $tcpPort" -ForegroundColor Green
            }
            if ($tcpDynamicPorts) {
                Write-Host "  Dynamic Ports: $tcpDynamicPorts" -ForegroundColor Yellow
                Write-Host "  ⚠️  Using dynamic port - need to find actual port" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "⚠️  Could not find registry entries" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error checking registry: $_" -ForegroundColor Red
}

# Method 3: Check SQL Server Browser service
Write-Host "`n📋 Method 3: Checking SQL Server Browser service..." -ForegroundColor Yellow
$browserService = Get-Service -Name "SQLBrowser" -ErrorAction SilentlyContinue
if ($browserService) {
    Write-Host "SQL Server Browser service status: $($browserService.Status)" -ForegroundColor Cyan
    if ($browserService.Status -ne "Running") {
        Write-Host "⚠️  SQL Server Browser is not running. This is needed for named instances." -ForegroundColor Yellow
        Write-Host "   Start it with: Start-Service SQLBrowser" -ForegroundColor Gray
    }
} else {
    Write-Host "⚠️  SQL Server Browser service not found" -ForegroundColor Yellow
}

# Method 4: Test common ports
Write-Host "`n📋 Method 4: Testing common ports..." -ForegroundColor Yellow
$commonPorts = @(1433, 1434, 14330, 14331, 14332, 14333)
$serverIP = "172.24.180.191"

foreach ($port in $commonPorts) {
    $test = Test-NetConnection -ComputerName $serverIP -Port $port -WarningAction SilentlyContinue
    if ($test.TcpTestSucceeded) {
        Write-Host "✅ Port $port is open!" -ForegroundColor Green
    }
}

Write-Host "`n📋 Recommended connection strings:" -ForegroundColor Cyan
Write-Host "`nFor Production (from Linux container):" -ForegroundColor Yellow
Write-Host "Server=172.24.180.191,<PORT>;Database=DataTest;User Id=sa;Password=28122003;TrustServerCertificate=True;" -ForegroundColor White
Write-Host "`n(Replace <PORT> with the actual port found above)" -ForegroundColor Gray

Write-Host "`nFor Development (from Windows):" -ForegroundColor Yellow
Write-Host "Server=FINALBOSS\SQL2025;Database=DataTest;User Id=sa;Password=28122003;TrustServerCertificate=True;" -ForegroundColor White

