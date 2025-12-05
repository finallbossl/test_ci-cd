using Backend.Models;

namespace Backend.Services;

public interface ITaskService
{
    Task<List<Models.Task>> GetAllTasksAsync(string? category = null, string? searchQuery = null);
    Task<Models.Task?> GetTaskByIdAsync(string id);
    Task<Models.Task> CreateTaskAsync(Models.Task task);
    Task<Models.Task?> UpdateTaskAsync(string id, Models.Task task);
    Task<bool> DeleteTaskAsync(string id);
}



