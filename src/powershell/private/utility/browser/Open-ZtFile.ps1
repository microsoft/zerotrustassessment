function Open-ZtFile {
    <#
    .SYNOPSIS
        Opens a file or URL in the default application, with container-aware fallback.
    .DESCRIPTION
        On Linux, uses xdg-open. On macOS, uses open. On Windows, uses Invoke-Item.
        Returns $true if the open command ran without error.
    .PARAMETER Path
        The file path or URL to open.
    .OUTPUTS
        [bool] True if the open command ran successfully.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [string] $Path
    )

    if ($IsLinux -or $IsMacOS) {
        $openCmd = if ($IsLinux) { 'xdg-open' } else { 'open' }
        if (Get-Command -Name $openCmd -ErrorAction Ignore) {
            try {
                & $openCmd $Path 2>&1 | Out-Null
                return $true
            }
            catch {
                Write-PSFMessage -Message "Failed to open with ${openCmd}: $_" -Level Debug
            }
        }
    }
    else {
        try {
            Invoke-Item $Path | Out-Null
            return $true
        }
        catch {
            Write-PSFMessage -Message "Failed to open with Invoke-Item: $_" -Level Debug
        }
    }

    return $false
}
