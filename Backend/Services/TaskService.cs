using System.Linq;
using Microsoft.EntityFrameworkCore;
using Backend.Models;
using Backend.Data;

namespace Backend.Services;

public class TaskService : ITaskService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<TaskService> _logger;

    public TaskService(ApplicationDbContext context, ILogger<TaskService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<List<Models.Task>> GetAllTasksAsync(string? category = null, string? searchQuery = null)
    {
        var tasks = _context.Tasks.AsQueryable();

        // Apply category filter
        if (!string.IsNullOrEmpty(category))
        {
            var today = DateTime.Now.ToString("yyyy-MM-dd");

            tasks = category switch
            {
                "today" => tasks.Where(t => t.Date == today && !t.Completed),
                "upcoming" => tasks.Where(t => DateTime.Parse(t.Date) > DateTime.Parse(today) && !t.Completed),
                "completed" => tasks.Where(t => t.Completed),
                "all" => tasks,
                _ => tasks
            };
        }

        // Apply search filter
        if (!string.IsNullOrEmpty(searchQuery))
        {
            var query = searchQuery.ToLower();
            tasks = tasks.Where(t =>
                t.Title.ToLower().Contains(query) ||
                t.Description.ToLower().Contains(query));
        }

        return await tasks.ToListAsync();
    }

    public async Task<Models.Task?> GetTaskByIdAsync(string id)
    {
        return await _context.Tasks.FirstOrDefaultAsync(t => t.Id == id);
    }

    public async Task<Models.Task> CreateTaskAsync(Models.Task task)
    {
        task.Id = Guid.NewGuid().ToString();
        _context.Tasks.Add(task);
        await _context.SaveChangesAsync();
        _logger.LogInformation("Created task with ID: {TaskId}", task.Id);
        return task;
    }

    public async Task<Models.Task?> UpdateTaskAsync(string id, Models.Task updatedTask)
    {
        var task = await _context.Tasks.FirstOrDefaultAsync(t => t.Id == id);
        if (task == null)
        {
            return null;
        }

        task.Title = updatedTask.Title;
        task.Description = updatedTask.Description;
        task.Tag = updatedTask.Tag;
        task.Date = updatedTask.Date;
        task.Time = updatedTask.Time;
        task.Completed = updatedTask.Completed;

        await _context.SaveChangesAsync();
        _logger.LogInformation("Updated task with ID: {TaskId}", id);
        return task;
    }

    public async Task<bool> DeleteTaskAsync(string id)
    {
        var task = await _context.Tasks.FirstOrDefaultAsync(t => t.Id == id);
        if (task == null)
        {
            return false;
        }

        _context.Tasks.Remove(task);
        await _context.SaveChangesAsync();
        _logger.LogInformation("Deleted task with ID: {TaskId}", id);
        return true;
    }
}

