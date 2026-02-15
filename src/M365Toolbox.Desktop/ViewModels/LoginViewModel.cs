using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using M365Toolbox.Desktop.Commands;
using M365Toolbox.Desktop.Services;

namespace M365Toolbox.Desktop.ViewModels;

public sealed class LoginViewModel : ViewModelBase
{
    private readonly PowerShellRunner _runner;
    private readonly LoggingService _loggingService;
    private string _upn = string.Empty;
    private string _status = "Not connected";

    public LoginViewModel(PowerShellRunner runner, LoggingService loggingService)
    {
        _runner = runner;
        _loggingService = loggingService;
        ConnectCommand = new AsyncRelayCommand(ConnectAsync, () => !string.IsNullOrWhiteSpace(UserPrincipalName));
    }

    public string UserPrincipalName
    {
        get => _upn;
        set
        {
            _upn = value;
            OnPropertyChanged();
            ConnectCommand.RaiseCanExecuteChanged();
        }
    }

    public string StatusMessage
    {
        get => _status;
        private set
        {
            _status = value;
            OnPropertyChanged();
        }
    }

    public AsyncRelayCommand ConnectCommand { get; }

    private async Task ConnectAsync()
    {
        try
        {
            await _runner.InvokeAsync(
                "Import-Module ./src/M365Toolbox.PowerShell/M365Toolbox.psd1 -Force; Connect-M365Toolbox",
                new Dictionary<string, object?> { ["UserPrincipalName"] = UserPrincipalName });

            StatusMessage = "Connected";
            _loggingService.WriteUiEvent("Connect", UserPrincipalName, new { Result = "Success" });
        }
        catch (Exception ex)
        {
            StatusMessage = $"Connection error: {ex.Message}";
            _loggingService.WriteUiEvent("Connect", UserPrincipalName, new { Result = "Failure" });
        }
    }
}
