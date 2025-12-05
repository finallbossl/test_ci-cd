namespace Backend.DTOs;

public class CreateTaskDto
{
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Tag { get; set; } = "Work";
    public string Date { get; set; } = string.Empty;
    public string Time { get; set; } = string.Empty;
}



