# PowerShell script để deploy production manually
# Usage: .\deploy.ps1

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting deployment..." -ForegroundColor Cyan

# Configuration
$IMAGE_NAME = "backend-api"
$CONTAINER_NAME = "backend-api"
$PORT = "8080"

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "❌ Docker is not running. Please start Docker first." -ForegroundColor Red
    exit 1
}

# Build the image
Write-Host "📦 Building Docker image..." -ForegroundColor Yellow
docker build -t $IMAGE_NAME ./Backend

# Stop and remove old container if exists
$existingContainer = docker ps -aq -f name=$CONTAINER_NAME
if ($existingContainer) {
    Write-Host "🛑 Stopping old container..." -ForegroundColor Yellow
    docker stop $CONTAINER_NAME 2>$null
    docker rm $CONTAINER_NAME 2>$null
}

# Get database connection string from environment or use default
$dbConnection = if ($env:DB_CONNECTION_STRING) { 
    $env:DB_CONNECTION_STRING 
} else { 
    "Server=localhost;Database=DataTest;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;"
}

# Run new container
Write-Host "▶️  Starting new container..." -ForegroundColor Yellow
docker run -d `
  --name $CONTAINER_NAME `
  --restart unless-stopped `
  -p "${PORT}:8080" `
  -e ASPNETCORE_ENVIRONMENT=Production `
  -e "ConnectionStrings__DefaultConnection=$dbConnection" `
  $IMAGE_NAME

# Wait for container to be healthy
Write-Host "⏳ Waiting for container to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Health check
try {
    $response = Invoke-WebRequest -Uri "http://localhost:$PORT/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Deployment successful!" -ForegroundColor Green
        Write-Host "🌐 API is running at http://localhost:$PORT" -ForegroundColor Green
        Write-Host "🏥 Health check: http://localhost:$PORT/health" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Health check failed. Check logs with: docker logs $CONTAINER_NAME" -ForegroundColor Red
    exit 1
}

# Show container status
Write-Host "`n📊 Container status:" -ForegroundColor Yellow
docker ps -f name=$CONTAINER_NAME

Write-Host "`n✨ Done!" -ForegroundColor Green

