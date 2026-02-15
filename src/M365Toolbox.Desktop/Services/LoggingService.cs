using System;
using System.IO;
using System.Text.Json;

namespace M365Toolbox.Desktop.Services;

public sealed class LoggingService
{
    private readonly string _logPath;

    public LoggingService()
    {
        var root = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "M365Toolbox", "Logs");
        Directory.CreateDirectory(root);
        _logPath = Path.Combine(root, "desktop-audit.jsonl");
    }

    public void WriteUiEvent(string action, string actor, object payload)
    {
        var line = JsonSerializer.Serialize(new
        {
            TimestampUtc = DateTime.UtcNow,
            Action = action,
            Actor = MaskEmail(actor),
            Payload = payload
        });

        File.AppendAllLines(_logPath, new[] { line });
    }

    private static string MaskEmail(string value)
    {
        var at = value.IndexOf('@');
        if (at <= 0) return "***";
        return $"{value[0]}***{value.Substring(at)}";
    }
}
