function Get-ZtRequiredModuleSpecByService {
    <#
    .SYNOPSIS
    Gets the Module Specification of the modules the desired services depends on.

    .DESCRIPTION
    Different modules may be required based on the services the user wants to connect to.
    This function retrieves the module specifications, defined in the module manifest,
    for the required modules based on the service selection.

    .PARAMETER Service
    The services for which to retrieve the required module specifications.

    .EXAMPLE
    Get-ZtRequiredModuleSpecByService -Service 'Azure', 'Graph'
    # This command retrieves the module specifications
    # for the modules required to connect to Azure and Graph.

    .NOTES
    Different pillars use different combinations of modules. For example:
    - Identity: uses graph, 1 or 2 use azure, one needs teams module
    - Devices: (intune), all based on Graph
    - Network: (25xxx 27xxx, but don't rely on number) most based on Graph, some based on Azure (i.e. application gateway) Invoke-AzRestMethod/Invoke-AzMGGraph/Invoke-ZtAzureRessourceGraphRequest/Invoke-ZtAzureRequestCache
    - Data: at least 2 using pure Graph, using SecurityCompliance (exo), Exchange (exo), SharePoint (spo), AipService (aip), maybe some using those with a mix of Graph
    #TODO: clean up notes here

    #>
    [CmdletBinding()]
    [OutputType('ZeroTrustAssessment.Service.ModuleRequirement')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateSet('Azure', 'AipService', 'ExchangeOnline', 'Graph', 'SecurityCompliance', 'SharePointOnline')]
        [string[]] $Service
    )

    begin {
        $Service = $Service | Select-Object -Unique
        $ztModule = Get-ZtModule
        $moduleManifestFileName = '{0}.psd1' -f $ztModule.Name
        $moduleManifestPath = Join-Path -Path $ztModule.ModuleBase -ChildPath $moduleManifestFileName -Resolve -ErrorAction Stop
        $moduleManifest = Import-PowerShellDataFile -Path $moduleManifestPath -ErrorAction Stop
        $serviceToRequiredModuleMap = $moduleManifest.PrivateData.ServiceToRequiredModuleMap
        [Microsoft.PowerShell.Commands.ModuleSpecification[]]$requiredModules = $moduleManifest.RequiredModules
        [Microsoft.PowerShell.Commands.ModuleSpecification[]]$XPlatPowerShellRequiredModules = $moduleManifest.PrivateData.XPlatPowerShellRequiredModules
        [Microsoft.PowerShell.Commands.ModuleSpecification[]]$windowsPowerShellRequiredModules = $moduleManifest.PrivateData.WindowsPowerShellRequiredModules
        # Order the selected services based on the order of the keys in the ServiceToRequiredModuleMap to ensure the module load and connection is done in the correct order.
        $Service = $Service | Sort-Object { [array]::IndexOf($moduleManifest.PrivateData.serviceConnectionOrder, $_) }
        $requiredModuleSpecsByService = [ordered]@{
            PSTypeName = 'ZeroTrustAssessment.Service.ModuleRequirement'
            ServiceInvalidForOS = @()
        }
    }

    process {
        foreach ($serviceToCheck in $Service) {
            foreach ($moduleName in $serviceToRequiredModuleMap[$serviceToCheck]) {
                Write-Debug -Message ("Service '{0}' depends on module '{1}'." -f $serviceToCheck, $moduleName)

                if ($moduleName -in $requiredModules.Name) {
                    Write-Debug -Message ("Module '{0}' is listed in RequiredModules." -f $moduleName)
                    $requiredModuleSpecsByService[$serviceToCheck] += $requiredModules.Where({
                        $_.Name -eq $moduleName -and $requiredModuleSpecsByService[$serviceToCheck] -notcontains $_
                    })
                }
                elseif ($moduleName -in $XPlatPowerShellRequiredModules.Name) {
                    Write-Debug -Message ("Module '{0}' is listed in XPlatPowerShellRequiredModules." -f $moduleName)
                    $requiredModuleSpecsByService[$serviceToCheck] += $XPlatPowerShellRequiredModules.Where({
                        $_.Name -eq $moduleName -and $requiredModuleSpecsByService[$serviceToCheck] -notcontains $_
                    })
                }
                elseif ($isWindows -and $moduleName -in $windowsPowerShellRequiredModules.Name) {
                    Write-Debug -Message ("Module '{0}' is listed in WindowsPowerShellRequiredModules." -f $moduleName)
                    $requiredModuleSpecsByService[$serviceToCheck] += $windowsPowerShellRequiredModules.Where({
                        $_.Name -eq $moduleName -and $requiredModuleSpecsByService[$serviceToCheck] -notcontains $_
                    })
                }
                elseif (-not $IsWindows -and $moduleName -in $windowsPowerShellRequiredModules.Name) {
                    Write-Debug -Message ("Module '{0}' is listed in WindowsPowerShellRequiredModules but the current platform is not Windows." -f $moduleName)
                    # The module that this service depends on is not available. The service won't be available.
                    $requiredModuleSpecsByService['ServiceInvalidForOS'] += $serviceToCheck
                }
                else {
                    Write-Verbose -Message ("Module '{0}' required for service '{1}' does not have a defined module specification in the module manifest." -f $moduleName, $serviceToCheck)
                }
            }
        }
    }

    end {
        # if a service depends on 2 modules, and 1 of them is not available on the current OS,
        # then we consider the service not available, even if the other module is available.
        # So we need to remove services that are invalid for the OS from the list of services with available modules.
        $invalidServices = $requiredModuleSpecsByService['ServiceInvalidForOS']
        $invalidServices.ForEach({
            if ($requiredModuleSpecsByService.keys -contains $_) {
                $requiredModuleSpecsByService.Remove($_)
            }
        })

        # Add a script property to get the services that are available based on the module availability and OS compatibility.
        $addMemberParams = @{
            Name = 'ServiceAvailable'
            Value = {
                $this.PSObject.Properties.Name.Where{$_ -notin @('ServiceInvalidForOS','ServiceAvailable','AllRequiredModuleSpecs') -and $_ -notin $this.ServiceInvalidForOS}
            }

            MemberType = 'ScriptProperty'
        }


        $result = [PSCustomObject]$requiredModuleSpecsByService | Add-Member @addMemberParams -PassThru

        # Add a script property to get all the required module specifications for the selected services.
        $addGetAllRequiredModuleSpecsParams = @{
            Name = 'AllRequiredModuleSpecs'
            Value = {
                $this.PSObject.Properties.Where{
                    $_.Name -notin @('ServiceInvalidForOS','ServiceAvailable','AllRequiredModuleSpecs') -and $_.Name -notin $this.ServiceInvalidForOS
                }.Value | Select-Object -Unique
            }

            MemberType = 'ScriptProperty'
        }

        $result | Add-Member @addGetAllRequiredModuleSpecsParams -PassThru
    }
}
