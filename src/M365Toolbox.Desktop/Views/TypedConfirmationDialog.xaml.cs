using System.Windows;

namespace M365Toolbox.Desktop.Views;

public partial class TypedConfirmationDialog : Window
{
    public string SearchName { get; }
    public string ConfirmationText { get; set; } = string.Empty;

    public TypedConfirmationDialog(string searchName)
    {
        SearchName = searchName;
        InitializeComponent();
        DataContext = this;
    }

    private void Cancel_Click(object sender, RoutedEventArgs e) => DialogResult = false;

    private void Confirm_Click(object sender, RoutedEventArgs e) => DialogResult = true;
}
