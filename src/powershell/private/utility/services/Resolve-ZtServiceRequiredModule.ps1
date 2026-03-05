function Resolve-ZtServiceRequiredModule {
    <#
    .SYNOPSIS
    Resolves the (available) required modules for the specified services.

    .DESCRIPTION
    This function checks the required modules for the specified services and
    resolves the available ones in the current environment.
    It returns an object with the list of available required modules for each service,
    as well as the list of services that are unavailable due to missing required modules.

    .PARAMETER Service
    The services for which to resolve required modules.

    .EXAMPLE
    Resolve-ZtServiceRequiredModule -Service 'Azure', 'Graph'
    # This command resolves the required modules for the specified services.

    #>
    [CmdletBinding()]
    [OutputType('ZeroTrustAssessment.Service.ModuleRequired')]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Azure', 'AipService', 'ExchangeOnline', 'Graph', 'SecurityCompliance', 'SharePointOnline')]
        [string[]] $Service
    )

    # Get the required module specifications for the specified service.
    $requiredModuleSpecsByService = Get-ZtRequiredModuleSpecByService -Service $Service
    # Create an ordered Dictionary to resolve the required module specifications by service name for faster lookup.
    # The order represents the order of connection, based on the order defined in the PSD1 file.
    $resolvedRequiredModuleByService = [ordered]@{
        PSTypeName = 'ZeroTrustAssessment.Service.ModuleRequired'
        Errors = @()
    }

    foreach ($serviceName in $requiredModuleSpecsByService.ServiceAvailable) {
        Write-Verbose -Message ("Resolving required modules for service '{0}'." -f $serviceName)
        $resolvedRequiredModuleByService[$serviceName] = @()
        foreach ($moduleSpecForService in $requiredModuleSpecsByService.($serviceName)) {
            Write-Verbose -Message ("Resolving required module '{0}' for service '{1}'." -f $moduleSpecForService, $serviceName)
            try {
                # Assert that the required modules are available in the current environment.
                $resolvedRequiredModuleByService[$serviceName] += Assert-RequiredModules -ModuleSpecification $moduleSpecForService -ErrorAction Stop -PassThru
            }
            catch {
                # If the required module is not available, add an error entry to the result object.
                # The service will be considered unavailable due to missing required modules.
                $resolvedRequiredModuleByService['Errors'] += @{
                    Service             = $serviceName
                    ModuleSpecification = $moduleSpecForService
                    ErrorMessage        = $_.Exception.Message
                }
            }
        }
    }

    $resolvedRequiredModuleByService['ServiceUnavailable'] = $requiredModuleSpecsByService.ServiceInvalidForOS + $resolvedRequiredModuleByService['Errors'].Service | Select-Object -Unique
    $resolvedRequiredModuleByService['ServiceAvailable'] = $Service.Where{ $_ -notin $resolvedRequiredModuleByService['ServiceUnavailable'] } |
        Sort-Object { [array]::IndexOf($requiredModuleSpecsByService.ServiceAvailable, $_) }
    $addModuleRequiredParams = @{
        Name  = 'ModuleRequired'
        Value = {
            $this.PSobject.Properties.Where({ $_.Name -notin 'ServiceUnavailable', 'ServiceAvailable', 'Errors' }).Value | Select-Object -Unique
        }
        MemberType = 'ScriptProperty'
    }

    [PSCustomObject]$resolvedRequiredModuleByService | Add-Member @addModuleRequiredParams -PassThru
}
