using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using M365Toolbox.Desktop.Commands;
using M365Toolbox.Desktop.Services;

namespace M365Toolbox.Desktop.ViewModels;

public sealed class PhishingViewModel : ViewModelBase
{
    private readonly PowerShellRunner _runner;
    private readonly LoggingService _logging;
    private readonly ConfirmationDialogService _confirmation;
    private string _searchName = "Phishing-Incident";
    private string _mode = "SenderEmail";
    private string _value = string.Empty;
    private DateTime _dateStart = DateTime.UtcNow.Date.AddDays(-1);
    private DateTime _dateEnd = DateTime.UtcNow.Date;
    private string _status = "Idle";
    private bool _searchCompleted;
    private bool _previewExecuted;

    public PhishingViewModel(PowerShellRunner runner, LoggingService logging, ConfirmationDialogService confirmation)
    {
        _runner = runner;
        _logging = logging;
        _confirmation = confirmation;

        RunSearchCommand = new AsyncRelayCommand(RunSearchAsync, CanRunSearch);
        RefreshStatusCommand = new AsyncRelayCommand(RefreshStatusAsync, () => !string.IsNullOrWhiteSpace(SearchName));
        PreviewCommand = new AsyncRelayCommand(PreviewAsync, () => SearchCompleted);
        SoftDeleteCommand = new AsyncRelayCommand(SoftDeleteAsync, () => SearchCompleted);
        HardDeleteCommand = new AsyncRelayCommand(HardDeleteAsync, () => SearchCompleted && PreviewExecuted);
    }

    public string SearchName { get => _searchName; set { _searchName = value; OnPropertyChanged(); Raise(); } }
    public bool IsSenderEmail { get => _mode == "SenderEmail"; set { if (value) { _mode = "SenderEmail"; OnPropertyChanged(); OnPropertyChanged(nameof(IsDomain)); } } }
    public bool IsDomain { get => _mode == "Domain"; set { if (value) { _mode = "Domain"; OnPropertyChanged(); OnPropertyChanged(nameof(IsSenderEmail)); } } }
    public string Mode => _mode;
    public string Value { get => _value; set { _value = value; OnPropertyChanged(); Raise(); } }
    public DateTime DateStart { get => _dateStart; set { _dateStart = value; OnPropertyChanged(); } }
    public DateTime DateEnd { get => _dateEnd; set { _dateEnd = value; OnPropertyChanged(); } }
    public string StatusMessage { get => _status; set { _status = value; OnPropertyChanged(); } }
    public bool SearchCompleted { get => _searchCompleted; set { _searchCompleted = value; OnPropertyChanged(); Raise(); } }
    public bool PreviewExecuted { get => _previewExecuted; set { _previewExecuted = value; OnPropertyChanged(); Raise(); } }

    public AsyncRelayCommand RunSearchCommand { get; }
    public AsyncRelayCommand RefreshStatusCommand { get; }
    public AsyncRelayCommand PreviewCommand { get; }
    public AsyncRelayCommand SoftDeleteCommand { get; }
    public AsyncRelayCommand HardDeleteCommand { get; }

    private bool CanRunSearch() => !string.IsNullOrWhiteSpace(SearchName) && !string.IsNullOrWhiteSpace(Value);

    private async Task RunSearchAsync()
    {
        PreviewExecuted = false;
        SearchCompleted = false;
        await _runner.InvokeAsync(
            "Import-Module ./src/M365Toolbox.PowerShell/M365Toolbox.psd1 -Force; New-PhishingComplianceSearch",
            new Dictionary<string, object?>
            {
                ["SearchName"] = SearchName,
                ["Mode"] = Mode,
                ["Value"] = Value,
                ["StartUtc"] = DateStart.ToUniversalTime(),
                ["EndUtc"] = DateEnd.ToUniversalTime(),
                ["Operator"] = "operator@local"
            });

        StatusMessage = "Search started. No sensitive data is displayed.";
        _logging.WriteUiEvent("SearchStart", "operator@local", new { SearchName, Mode });
    }

    private async Task RefreshStatusAsync()
    {
        var status = await _runner.InvokeAsync(
            "Import-Module ./src/M365Toolbox.PowerShell/M365Toolbox.psd1 -Force; Get-ComplianceSearchStatus",
            new Dictionary<string, object?> { ["SearchName"] = SearchName });

        var current = status.Count > 0 ? status[0].Properties["Status"]?.Value?.ToString() : "Unknown";
        SearchCompleted = string.Equals(current, "Completed", StringComparison.OrdinalIgnoreCase);
        StatusMessage = $"Search status: {current}. No sensitive data is displayed.";
    }

    private async Task PreviewAsync()
    {
        await _runner.InvokeAsync(
            "Import-Module ./src/M365Toolbox.PowerShell/M365Toolbox.psd1 -Force; New-PhishingPreview",
            new Dictionary<string, object?> { ["SearchName"] = SearchName, ["Operator"] = "operator@local" });
        PreviewExecuted = true;
        StatusMessage = "Preview requested. No sensitive data is displayed.";
        _logging.WriteUiEvent("Preview", "operator@local", new { SearchName });
    }

    private async Task SoftDeleteAsync()
    {
        await _runner.InvokeAsync(
            "Import-Module ./src/M365Toolbox.PowerShell/M365Toolbox.psd1 -Force; Invoke-PhishingPurge -Confirm:$false",
            new Dictionary<string, object?> { ["SearchName"] = SearchName, ["PurgeType"] = "SoftDelete", ["Operator"] = "operator@local" });
        StatusMessage = "SoftDelete requested.";
        _logging.WriteUiEvent("SoftDelete", "operator@local", new { SearchName });
    }

    private async Task HardDeleteAsync()
    {
        var typed = await _confirmation.PromptHardDeleteConfirmationAsync(SearchName);
        if (typed is null)
        {
            StatusMessage = "HardDelete cancelled.";
            return;
        }

        await _runner.InvokeAsync(
            "Import-Module ./src/M365Toolbox.PowerShell/M365Toolbox.psd1 -Force; Invoke-PhishingPurge -Confirm:$false",
            new Dictionary<string, object?>
            {
                ["SearchName"] = SearchName,
                ["PurgeType"] = "HardDelete",
                ["PreviewExecuted"] = true,
                ["TypedConfirmation"] = typed,
                ["Operator"] = "operator@local"
            });

        StatusMessage = "HardDelete requested.";
        _logging.WriteUiEvent("HardDelete", "operator@local", new { SearchName });
    }

    private void Raise()
    {
        RunSearchCommand.RaiseCanExecuteChanged();
        RefreshStatusCommand.RaiseCanExecuteChanged();
        PreviewCommand.RaiseCanExecuteChanged();
        SoftDeleteCommand.RaiseCanExecuteChanged();
        HardDeleteCommand.RaiseCanExecuteChanged();
    }
}
