namespace Backend.DTOs;

public class UpdateTaskDto
{
    public string? Title { get; set; }
    public string? Description { get; set; }
    public string? Tag { get; set; }
    public string? Date { get; set; }
    public string? Time { get; set; }
    public bool? Completed { get; set; }
}



