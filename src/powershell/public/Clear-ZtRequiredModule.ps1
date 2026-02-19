param ()

function Clear-ZtRequiredModule {
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
        Set-Clipboard -Value ('&''{0}''' -f $PSCommandPath)
        Write-Warning -Message ('(The command has been copied to your clipboard.)')
        return
    }
    else
    {
        Write-Verbose -Message 'Clearing ZTA required modules from the current session.'
    }

    # Remove all ZTA-related modules from the current session
    if ($isWindows) {
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
