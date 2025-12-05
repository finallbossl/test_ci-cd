using Backend.Services;
using Backend.Data;
using Microsoft.EntityFrameworkCore;

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
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString));

// Register TaskService
builder.Services.AddScoped<ITaskService, TaskService>();

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins(
                "http://localhost:5173", 
                "http://localhost:3000", 
                "http://localhost:5174", 
                "http://localhost:8080",
                "http://172.24.180.191:8080", // Production frontend
                "http://172.24.180.191:3000", // Production frontend (nếu dùng port khác)
                "http://172.24.180.191:5173"  // Production frontend (nếu dùng port khác)
              )
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

var app = builder.Build();

// Ensure database is created (non-blocking)
try
{
    using var scope = app.Services.CreateScope();
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    
    logger.LogInformation("Checking database connection...");
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    logger.LogInformation("Connection string: {ConnectionString}", 
        connectionString?.Replace("Password=.*;", "Password=***;", System.Text.RegularExpressions.RegexOptions.IgnoreCase));
    
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
    }
}
catch (Exception ex)
{
    var logger = app.Services.GetRequiredService<ILogger<Program>>();
    logger.LogError(ex, "An error occurred while connecting to the database. Application will continue but database operations may fail.");
    logger.LogError("Full error: {Error}", ex.ToString());
    // Don't stop the application
}

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
