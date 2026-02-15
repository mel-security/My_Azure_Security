using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Threading.Tasks;

namespace M365Toolbox.Desktop.Services;

public sealed class PowerShellRunner : IDisposable
{
    private readonly RunspacePool _runspacePool;

    public PowerShellRunner()
    {
        var state = InitialSessionState.CreateDefault();
        _runspacePool = RunspaceFactory.CreateRunspacePool(1, 4, state, null);
        _runspacePool.Open();
    }

    public Task<IReadOnlyList<PSObject>> InvokeAsync(string script, IDictionary<string, object?>? parameters = null)
    {
        return Task.Run(() =>
        {
            using var ps = PowerShell.Create();
            ps.RunspacePool = _runspacePool;
            ps.AddScript(script);
            if (parameters is not null)
            {
                foreach (var pair in parameters)
                {
                    ps.AddParameter(pair.Key, pair.Value);
                }
            }

            var results = ps.Invoke();
            if (ps.HadErrors)
            {
                throw new InvalidOperationException(ps.Streams.Error[0].ToString());
            }

            return (IReadOnlyList<PSObject>)results;
        });
    }

    public void Dispose()
    {
        _runspacePool.Close();
        _runspacePool.Dispose();
    }
}
