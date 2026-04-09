function Test-ZtContainerEnvironment {
    <#
    .SYNOPSIS
        Detects whether the current session is running inside a container.

    .DESCRIPTION
        Checks for common container indicators:
        - REMOTE_CONTAINERS or CODESPACES environment variables (VS Code)
        - /.dockerenv file
        - Container runtime in /proc/1/cgroup

    .OUTPUTS
        [bool] True if running in a container environment.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    # VS Code dev containers / Codespaces
    if ($env:REMOTE_CONTAINERS -or $env:CODESPACES -or $env:REMOTE_CONTAINERS_IPC) {
        return $true
    }

    # VS Code server running inside container
    if ($env:VSCODE_AGENT_FOLDER -or $env:VSCODE_IPC_HOOK_CLI) {
        return $true
    }

    # Docker container indicator
    if (Test-Path '/.dockerenv') {
        return $true
    }

    # Check cgroup for container runtimes
    if (Test-Path '/proc/1/cgroup') {
        $cgroup = Get-Content '/proc/1/cgroup' -Raw -ErrorAction Ignore
        if ($cgroup -match 'docker|containerd|kubepods|lxc') {
            return $true
        }
    }

    return $false
}
