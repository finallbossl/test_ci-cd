using Microsoft.AspNetCore.Mvc;
using Backend.Models;
using Backend.DTOs;
using Backend.Services;
using TaskModel = Backend.Models.Task;

namespace Backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TasksController : ControllerBase
{
    private readonly ITaskService _taskService;
    private readonly ILogger<TasksController> _logger;

    public TasksController(ITaskService taskService, ILogger<TasksController> logger)
    {
        _taskService = taskService;
        _logger = logger;
    }

    // GET: api/tasks
    [HttpGet]
    public async System.Threading.Tasks.Task<ActionResult<List<TaskModel>>> GetTasks([FromQuery] string? category, [FromQuery] string? search)
    {
        try
        {
            var tasks = await _taskService.GetAllTasksAsync(category, search);
            return Ok(tasks);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting tasks");
            return StatusCode(500, new { message = "An error occurred while retrieving tasks" });
        }
    }

    // GET: api/tasks/{id}
    [HttpGet("{id}")]
    public async System.Threading.Tasks.Task<ActionResult<TaskModel>> GetTask(string id)
    {
        try
        {
            var task = await _taskService.GetTaskByIdAsync(id);
            if (task == null)
            {
                return NotFound(new { message = $"Task with ID {id} not found" });
            }
            return Ok(task);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting task {TaskId}", id);
            return StatusCode(500, new { message = "An error occurred while retrieving the task" });
        }
    }

    // POST: api/tasks
    [HttpPost]
    public async System.Threading.Tasks.Task<ActionResult<TaskModel>> CreateTask([FromBody] CreateTaskDto createTaskDto)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(createTaskDto.Title))
            {
                return BadRequest(new { message = "Title is required" });
            }

            var task = new TaskModel
            {
                Title = createTaskDto.Title,
                Description = createTaskDto.Description ?? string.Empty,
                Tag = createTaskDto.Tag ?? "Work",
                Date = createTaskDto.Date,
                Time = createTaskDto.Time ?? "10:00",
                Completed = false
            };

            var createdTask = await _taskService.CreateTaskAsync(task);
            return CreatedAtAction(nameof(GetTask), new { id = createdTask.Id }, createdTask);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating task");
            return StatusCode(500, new { message = "An error occurred while creating the task" });
        }
    }

    // PUT: api/tasks/{id}
    [HttpPut("{id}")]
    public async System.Threading.Tasks.Task<ActionResult<TaskModel>> UpdateTask(string id, [FromBody] UpdateTaskDto updateTaskDto)
    {
        try
        {
            var existingTask = await _taskService.GetTaskByIdAsync(id);
            if (existingTask == null)
            {
                return NotFound(new { message = $"Task with ID {id} not found" });
            }

            // Update only provided fields
            if (updateTaskDto.Title != null)
                existingTask.Title = updateTaskDto.Title;
            if (updateTaskDto.Description != null)
                existingTask.Description = updateTaskDto.Description;
            if (updateTaskDto.Tag != null)
                existingTask.Tag = updateTaskDto.Tag;
            if (updateTaskDto.Date != null)
                existingTask.Date = updateTaskDto.Date;
            if (updateTaskDto.Time != null)
                existingTask.Time = updateTaskDto.Time;
            if (updateTaskDto.Completed.HasValue)
                existingTask.Completed = updateTaskDto.Completed.Value;

            var updatedTask = await _taskService.UpdateTaskAsync(id, existingTask);
            return Ok(updatedTask);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating task {TaskId}", id);
            return StatusCode(500, new { message = "An error occurred while updating the task" });
        }
    }

    // PATCH: api/tasks/{id}/toggle
    [HttpPatch("{id}/toggle")]
    public async System.Threading.Tasks.Task<ActionResult<TaskModel>> ToggleTask(string id)
    {
        try
        {
            var task = await _taskService.GetTaskByIdAsync(id);
            if (task == null)
            {
                return NotFound(new { message = $"Task with ID {id} not found" });
            }

            task.Completed = !task.Completed;
            var updatedTask = await _taskService.UpdateTaskAsync(id, task);
            return Ok(updatedTask);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error toggling task {TaskId}", id);
            return StatusCode(500, new { message = "An error occurred while toggling the task" });
        }
    }

    // DELETE: api/tasks/{id}
    [HttpDelete("{id}")]
    public async System.Threading.Tasks.Task<IActionResult> DeleteTask(string id)
    {
        try
        {
            var deleted = await _taskService.DeleteTaskAsync(id);
            if (!deleted)
            {
                return NotFound(new { message = $"Task with ID {id} not found" });
            }
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting task {TaskId}", id);
            return StatusCode(500, new { message = "An error occurred while deleting the task" });
        }
    }
}



