using Microsoft.EntityFrameworkCore;
using Backend.Models;
using TaskModel = Backend.Models.Task;

namespace Backend.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<TaskModel> Tasks { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<TaskModel>(entity =>
        {
            entity.ToTable("tasks"); // Use lowercase for PostgreSQL compatibility (case-sensitive)
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).IsRequired();
            entity.Property(e => e.Title).IsRequired().HasMaxLength(500);
            entity.Property(e => e.Description).HasMaxLength(2000);
            entity.Property(e => e.Tag).IsRequired().HasMaxLength(50);
            entity.Property(e => e.Date).IsRequired().HasMaxLength(10);
            entity.Property(e => e.Time).IsRequired().HasMaxLength(10);
            entity.Property(e => e.Completed).IsRequired();
        });
    }
}

