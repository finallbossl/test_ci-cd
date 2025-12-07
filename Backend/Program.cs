using Backend.Services;
using Backend.Data;
using Backend.Models;
using Microsoft.EntityFrameworkCore;
using System.Text.RegularExpressions;
using TaskModel = Backend.Models.Task;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        // Configure JSON serialization to use camelCase
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
        options.JsonSerializerOptions.WriteIndented = true;
    });
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure Entity Framework
// Support both SQL Server and PostgreSQL (for Render.com)
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

// Normalize PostgreSQL connection string from URI format if needed
if (!string.IsNullOrEmpty(connectionString) && connectionString.StartsWith("postgresql://"))
{
    // Convert PostgreSQL URI to Npgsql connection string format
    try
    {
        var uri = new Uri(connectionString);
        var connBuilder = new System.Text.StringBuilder();
        connBuilder.Append($"Host={uri.Host}");
        if (uri.Port > 0 && uri.Port != 5432) connBuilder.Append($";Port={uri.Port}");
        
        var dbName = uri.AbsolutePath.TrimStart('/');
        if (!string.IsNullOrEmpty(dbName)) connBuilder.Append($";Database={dbName}");
        
        if (!string.IsNullOrEmpty(uri.UserInfo))
        {
            var userInfo = uri.UserInfo.Split(':');
            if (userInfo.Length > 0) connBuilder.Append($";Username={Uri.UnescapeDataString(userInfo[0])}");
            if (userInfo.Length > 1) connBuilder.Append($";Password={Uri.UnescapeDataString(userInfo[1])}");
        }
        
        // Parse query string manually (System.Web not available in .NET Core)
        if (!string.IsNullOrEmpty(uri.Query))
        {
            var query = uri.Query.TrimStart('?');
            var pairs = query.Split('&');
            foreach (var pair in pairs)
            {
                var keyValue = pair.Split('=');
                if (keyValue.Length == 2)
                {
                    var key = Uri.UnescapeDataString(keyValue[0]);
                    var value = Uri.UnescapeDataString(keyValue[1]);
                    connBuilder.Append($";{key}={value}");
                }
            }
        }
        
        // Add SSL mode if not present
        if (!connBuilder.ToString().Contains("SSL Mode", StringComparison.OrdinalIgnoreCase))
        {
            connBuilder.Append(";SSL Mode=Require");
        }
        
        connectionString = connBuilder.ToString();
    }
    catch
    {
        // If URI parsing fails, use original connection string
        // Npgsql may be able to parse it directly
    }
}

builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    if (string.IsNullOrEmpty(connectionString))
    {
        throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
    }
    
    // Detect database type from connection string
    if (connectionString.ToLower().Contains("postgresql") || 
        connectionString.ToLower().Contains("postgres") ||
        connectionString.StartsWith("postgresql://") ||
        connectionString.Contains("Host=", StringComparison.OrdinalIgnoreCase))
    {
        // PostgreSQL connection
        options.UseNpgsql(connectionString);
    }
    else
    {
        // SQL Server connection (default)
        options.UseSqlServer(connectionString);
    }
});

// Register TaskService
builder.Services.AddScoped<ITaskService, TaskService>();

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        var origins = new List<string>
        {
            "http://localhost:5173", 
            "http://localhost:3000", 
            "http://localhost:5174", 
            "http://localhost:8080",
            "http://172.24.180.191:8080", // Production frontend
            "http://172.24.180.191:3000", // Production frontend (nếu dùng port khác)
            "http://172.24.180.191:5173",  // Production frontend (nếu dùng port khác)
            "http://192.168.102.8:8080",   // Windows host IP
            "http://192.168.102.8:3000",   // Windows host IP (nếu dùng port khác)
            "http://192.168.102.8:5173",   // Windows host IP (nếu dùng port khác)
            "http://172.24.176.1:8080",    // Network IP
            "https://test-ci-cd-fus0.onrender.com" // Render frontend (nếu có)
        };
        
        // Add Render.com frontend URLs from environment variable (comma-separated)
        var frontendUrls = Environment.GetEnvironmentVariable("FRONTEND_URLS");
        if (!string.IsNullOrEmpty(frontendUrls))
        {
            origins.AddRange(frontendUrls.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries));
        }
        
        policy.WithOrigins(origins.ToArray())
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

var app = builder.Build();

// Ensure database is created (non-blocking, run in background)
_ = System.Threading.Tasks.Task.Run(async () =>
{
    await System.Threading.Tasks.Task.Delay(2000); // Wait for app to start
    
try
{
    using var scope = app.Services.CreateScope();
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    
    logger.LogInformation("Checking database connection...");
        var connString = builder.Configuration.GetConnectionString("DefaultConnection");
        var maskedConnectionString = connString != null 
            ? Regex.Replace(connString, @"Password=[^;]+;", "Password=***;", RegexOptions.IgnoreCase)
            : "Not configured";
        logger.LogInformation("Connection string: {ConnectionString}", maskedConnectionString);
        
        // Try to connect with timeout
        var canConnect = false;
        try
        {
            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(10));
            canConnect = await context.Database.CanConnectAsync(cts.Token);
        }
        catch (Exception connectEx)
        {
            logger.LogWarning(connectEx, "Cannot connect to database. Will attempt to create it.");
        }
        
    if (!canConnect)
    {
        logger.LogInformation("Database does not exist. Creating database...");
            try
            {
                using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(30));
                await context.Database.EnsureCreatedAsync(cts.Token);
                logger.LogInformation("Database created successfully.");
                
                // Verify tables were created
                var tablesCreated = await context.Database.CanConnectAsync();
                if (tablesCreated)
                {
                    logger.LogInformation("Database and tables verified successfully.");
                }
            }
            catch (Exception createEx)
            {
                logger.LogError(createEx, "Failed to create database. Application will continue but database operations may fail.");
                logger.LogError("Full error: {Error}", createEx.ToString());
            }
    }
    else
    {
        logger.LogInformation("Database connection successful.");
        
        // Check if tables exist, if not create them
        try
        {
            // Try to query tasks table to see if it exists
            try
            {
                using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(5));
                var testQuery = await context.Set<TaskModel>().Take(1).ToListAsync(cts.Token);
                logger.LogInformation("Tasks table exists and is accessible.");
            }
            catch (Exception tableEx)
            {
                logger.LogWarning(tableEx, "Tasks table may not exist. Attempting to create tables...");
                try
                {
                    using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(30));
                    await context.Database.EnsureCreatedAsync(cts.Token);
                    logger.LogInformation("Tables created successfully.");
                    
                    // Verify table was actually created
                    try
                    {
                        using var verifyCts = new CancellationTokenSource(TimeSpan.FromSeconds(5));
                        var verifyQuery = await context.Set<TaskModel>().Take(1).ToListAsync(verifyCts.Token);
                        logger.LogInformation("Tasks table verified and accessible after creation.");
                    }
                    catch (Exception verifyEx)
                    {
                        logger.LogError(verifyEx, "Table creation reported success but table is still not accessible. Error: {Error}", verifyEx.Message);
                    }
                }
                catch (Exception ensureEx)
                {
                    logger.LogError(ensureEx, "Failed to create tables. Error: {Error}", ensureEx.Message);
                    logger.LogError("Full error details: {FullError}", ensureEx.ToString());
                }
            }
        }
        catch (Exception checkEx)
        {
            logger.LogWarning(checkEx, "Could not verify table existence. Will attempt to create if needed.");
        }
    }
}
catch (Exception ex)
{
    var logger = app.Services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while connecting to the database. Application will continue but database operations may fail.");
        logger.LogError("Full error: {Error}", ex.ToString());
}
});

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Only redirect to HTTPS in production
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

// Use CORS
app.UseCors("AllowFrontend");

app.UseAuthorization();

// Health check endpoint
app.MapGet("/health", () => Results.Ok(new { status = "healthy", timestamp = DateTime.UtcNow }))
    .WithName("HealthCheck")
    .WithTags("Health");

app.MapControllers();

app.Run();
