using System.Windows;
using M365Toolbox.Desktop.Services;
using M365Toolbox.Desktop.ViewModels;

namespace M365Toolbox.Desktop;

public partial class MainWindow : Window
{
    private readonly PowerShellRunner _runner = new();

    public MainWindow()
    {
        InitializeComponent();

        var logging = new LoggingService();
        LoginViewHost.DataContext = new LoginViewModel(_runner, logging);
        PhishingViewHost.DataContext = new PhishingViewModel(_runner, logging, new ConfirmationDialogService());
    }

    protected override void OnClosed(System.EventArgs e)
    {
        _runner.Dispose();
        base.OnClosed(e);
    }
}
