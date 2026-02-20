param ()

function Clear-ZtRequiredModule {
    <#
    .SYNOPSIS
    Remove all modules downloaded into the ~/.cache/ZeroTrustAssessment/Modules or %APPDATA%\ZeroTrustAssessment\Modules folder
    by the Zero Trust Assessment module.

    .DESCRIPTION
    This cmdlet removes all modules that were downloaded and installed by the Zero Trust Assessment module into the user's
    cache or application data directories.
    Since these modules are imported into the global session when the Zero Trust Assessment module is imported,
    they cannot be removed until the session is closed.

    Since this command wouldn't work if running in a session where the Zero Trust Assessment module is currently loaded,
    it detects if it's being called during module loading and exits with a warning message and instructions on how to run it successfully.

    .EXAMPLE
    Clear-ZtRequiredModule

    # This won't remove the modules because it runs in the same session where ZeroTrustAssessment module is currently loaded
    # Instead, it will show a warning message with instructions on how to run it successfully.

    .EXAMPLE
    &'<path to module>\Clear-ZtRequiredModule.ps1'

    # If this is run in a clean session, and you closed all other sessions where ZeroTrustAssessment module was loaded,
    # it will remove all modules downloaded by the Zero Trust Assessment module.

    #>
    [CmdletBinding()]
    param (
    )

    # If CallStack from the Module file (psm1), the module is being loaded.
    if ((Get-PSCallStack).Position.File -like '*ZeroTrustAssessment.psm1')
    {
        Write-Verbose -Message 'Command is being called from module loading. Ignoring.'
        return
    }
    elseif ($MyInvocation.MyCommand.Module) # Called when module is loaded.
    {
        Write-Warning -Message 'This command cannot be run when the module is loaded.'
        Write-Warning -Message 'Please close all sessions where ZeroTrustAssessment module is loaded, then run the following...'
        Write-Warning -Message ('&''{0}''' -f $PSCommandPath)
        if ($IsWindows -and (Get-Command -Name Set-Clipboard -ErrorAction SilentlyContinue)) {
            Set-Clipboard -Value ('&''{0}''' -f $PSCommandPath)
            Write-Warning -Message '(The command has been copied to your clipboard.)'
        }
        return
    }
    else
    {
        Write-Verbose -Message 'Clearing ZTA required modules from the current session.'
    }

    # Remove all ZTA-related modules from the current session
    if ($IsWindows) {
        $ZTAModulesFolder = Join-Path -Path $Env:APPDATA -ChildPath 'ZeroTrustAssessment\Modules'
    }
    else {
        $ZTAModulesFolder = Join-Path -Path $Env:HOME -ChildPath '.cache/ZeroTrustAssessment/Modules'
    }

    if (Test-Path -Path $ZTAModulesFolder) {
        Remove-Item -Path $ZTAModulesFolder -Recurse -Force -ErrorAction Continue
    }
}

Clear-ZtRequiredModule @PSBoundParameters
