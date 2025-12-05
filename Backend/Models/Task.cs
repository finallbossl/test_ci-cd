namespace Backend.Models;

public class Task
{
    public string Id { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Tag { get; set; } = "Work"; // Work, Study, Personal
    public string Date { get; set; } = string.Empty; // ISO date string (YYYY-MM-DD)
    public string Time { get; set; } = string.Empty; // HH:mm format
    public bool Completed { get; set; } = false;
}



