using System.Threading.Tasks;
using M365Toolbox.Desktop.Views;

namespace M365Toolbox.Desktop.Services;

public sealed class ConfirmationDialogService
{
    public Task<string?> PromptHardDeleteConfirmationAsync(string searchName)
    {
        var dialog = new TypedConfirmationDialog(searchName);
        var result = dialog.ShowDialog();
        return Task.FromResult(result == true ? dialog.ConfirmationText : null);
    }
}
