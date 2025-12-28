function Get-ModuleImportOrder {
    <#
    .SYNOPSIS
    Evaluates the import order of specified modules based on their versions and the location in PSModulePath.

    .DESCRIPTION
    This function evaluates the import order of specified modules based on their versions and the location in PSModulePath.
    It uses Get-ModuleImportCandidate to determine which version of each module would be imported by Import-Module,
    and then sorts them by the version of 'Microsoft.Identity.Client.dll' that is packaged with each module.

    .PARAMETER Name
    A list of module names to evaluate for proper import order. Wildcards are allowed.

    .EXAMPLE
    Get-ModuleImportOrder -Name 'Az.Accounts','ExchangeOnlineManagement'

    Returns a list of modules ordered by the version of 'Microsoft.Identity.Client.dll' they contain.

    #>
    [CmdletBinding()]
    param(
        # A list of module names to evaluate for proper import order.
        [Parameter(
            Position = 0,
            ValueFromPipelineByPropertyName,
            HelpMessage = 'Enter a list of names to evaluate. Wildcards are allowed.'
        )]
        [string[]]$Name = @(
            'Az.Accounts',
            'ExchangeOnlineManagement',
            'Microsoft.Graph.Authentication',
            'MicrosoftTeams'
        ),

        # A hashtable of module names and their required versions.
        [Parameter(
            ValueFromPipelineByPropertyName,
            HelpMessage = 'Enter a hashtable of module names and their required versions.'
        )]
        [hashtable]$RequiredVersions = @{},

        # If specified, sorts the modules by DLL version in ascending order (oldest first).
        [switch]$Ascending
    )

    process {
        $ModulesWithVersionSortedIdentityClient = Get-ModulesWithVersionSortedIdentityClient -Name $Name -RequiredVersions $RequiredVersions -Ascending:$Ascending
        $ModulesWithVersionSortedIdentityClient
    } # end process block

    begin {

        #region EmbeddedFunctions
        function Get-ModuleImportCandidate {
            <#
            .SYNOPSIS
            Returns module information for the specific instance of a module that Import-Module would load.

            .DESCRIPTION
            Get-ModuleImportCandidate is a cross-platform function that reliably determines which module version would be
            selected by Import-Module when multiple versions of the same module are available in multiple installation scopes.

            When importing modules, PSModulePath is the primary factor in determining which module version is loaded,
            and the order of the paths in PSModulePath is important. The CurrentUser paths generally appear first in PSModulePath,
            followed by the AllUsers scope paths. The function takes into account the following rules:

            Location takes precedence over version:
            - A lower version in a higher-priority location will be loaded before a higher version in a lower-priority location.
            - Within a location, higher versions are loaded first.

            .PARAMETER Name
            The name of the module[s] to check. This can be a single module name or an array of module names.

            .EXAMPLE
            Get-ModuleImportCandidate -Name 'Az.Accounts'

            Returns a PSModuleInfo object for the version of the 'Az.Accounts' module that would be imported by Import-Module.

            .EXAMPLE
            Get-ModuleImportCandidate -Name 'Pester','Maester'

            Returns PSModuleInfo objects for the versions of the 'Pester' and 'Maester' modules that would be imported by Import-Module.

            .EXAMPLE
            'Az.Accounts','ExchangeOnlineManagement','Microsoft.Graph.Authentication','MicrosoftTeams' | Get-ModuleImportCandidate

            Returns PSModuleInfo objects for the specified modules that would be imported by Import-Module.

            .NOTES
            Author: Sam Erde
            Version: 1.0.0
            Date: 2025-06-05
            #>

            [CmdletBinding()]
            param(
                # The name of the module[s] to check. This can be a single module name or an array of module names.
                [Parameter(
                    Position = 0,
                    ValueFromPipeline,
                    ValueFromPipelineByPropertyName,
                    HelpMessage = 'Enter a module name or a list of names. Wildcards are allowed.'
                )]
                [string[]]$Name = @(
                    'Az.Accounts',
                    'ExchangeOnlineManagement',
                    'Microsoft.Graph.Authentication'
                ),

                [hashtable]$RequiredVersions = @{}
            )

            begin {
                # Get PSModulePath entries in order (defaults to the 'Process' environment variable target which includes users and computer values, in that order).
                $PSModulePathEntries = $env:PSModulePath -split [System.IO.Path]::PathSeparator |
                    # Filter out empty entries and resolve the full path to account for symbolic links or variables.
                    Where-Object { $_ } | ForEach-Object { [System.IO.Path]::GetFullPath($_) }
            } # end begin block

            process {
                # Process each module name (handles both array input and pipeline input)
                foreach ($ModuleName in $Name) {
                    # Get all available modules with this name
                    if ($RequiredVersions.ContainsKey($ModuleName)) {
                        $reqVer = $RequiredVersions[$ModuleName]
                        $AllModules = Get-Module -Name $ModuleName -ListAvailable | Where-Object Version -eq $reqVer
                    }
                    else {
                        $AllModules = Get-Module -Name $ModuleName -ListAvailable
                    }

                    # Skip and warn if no modules were found for this name.
                    if (-not $AllModules) {
                        if ($RequiredVersions.ContainsKey($ModuleName)) {
                            Write-Warning "No module named '$ModuleName' with version '$($RequiredVersions[$ModuleName])' found in PSModulePath."
                        }
                        else {
                            Write-Warning "No module named '$ModuleName' found in PSModulePath."
                        }
                        continue
                    }

                    # Use a script block to group modules by their base path and find the highest version in each grouped location.
                    $ModulesByLocation = $AllModules | Group-Object {

                        # Get the module's root directory (usually Modules folder)
                        $ModulePath = [System.IO.Path]::GetFullPath($_.ModuleBase)

                        # Find which PSModulePath entry this module's path begins with.
                        foreach ($PathEntry in $PSModulePathEntries) {
                            # Normalize the path to account for symbolic links or variables within the environment variable.
                            $NormalizedPathEntry = [System.IO.Path]::GetFullPath($PathEntry)
                            if ($ModulePath.StartsWith($NormalizedPathEntry, [System.StringComparison]::OrdinalIgnoreCase)) {
                                # If the module path starts with this PSModulePath entry, return it as the grouping key.
                                return $NormalizedPathEntry
                            }
                        }

                    } # end of Group-Object script block

                    # Find the highest version module from the first location in PSModulePath order.
                    # Initialize the variable at its max value to ensure it is always greater than any valid index.
                    $BestLocationIndex = [int]::MaxValue
                    $CandidateModule = $null

                    foreach ($LocationGroup in $ModulesByLocation) {
                        # Get the highest version module from this location
                        $HighestVersionInLocation = $LocationGroup.Group | Sort-Object Version -Descending | Select-Object -First 1

                        # Find this location's index in PSModulePath (initialize at max value as best practice).
                        $LocationIndex = [int]::MaxValue
                        $LocationPath = $LocationGroup.Name

                        for ($i = 0; $i -lt $PSModulePathEntries.Count; $i++) {
                            # Perform a case-insensitive comparison to find the index of this location in PSModulePath.
                            if ($LocationPath.StartsWith($PSModulePathEntries[$i], [System.StringComparison]::OrdinalIgnoreCase)) {
                                $LocationIndex = $i
                                break
                            }
                        }

                        # Use this module if it's from an earlier location in PSModulePath.
                        if ($LocationIndex -lt $BestLocationIndex) {
                            $BestLocationIndex = $LocationIndex
                            $CandidateModule = $HighestVersionInLocation
                        }
                    }

                    # Output the candidate module for this module name
                    $CandidateModule
                }
            } # end process block
        } # end Get-ModuleImportCandidate function

        function Get-ModulesWithVersionSortedIdentityClient {
            [CmdletBinding()]
            param(
                # A list of module names to evaluate for proper import order.
                [Parameter(
                    Position = 0,
                    ValueFromPipelineByPropertyName,
                    HelpMessage = 'Enter a list of names to evaluate. Wildcards are allowed.'
                )]
                [string[]]$Name,

                [hashtable]$RequiredVersions = @{},

                [switch]$Ascending
            )

            begin {
                $ModulesWithVersionSortedIdentityClient = [System.Collections.Generic.List[PSCustomobject]]::new()
            } # end begin block

            process {

                # Call the function to determine the path and version of each module.
                $ModuleInfo = Get-ModuleImportCandidate -Name $Name -RequiredVersions $RequiredVersions

                # Find the version of 'Microsoft.Identity.Client.dll' that is packaged with each module.
                foreach ($Module in $ModuleInfo) {
                    $DllFile = Get-ChildItem -Path $Module.ModuleBase -File -Include 'Microsoft.Identity.Client.dll' -Recurse -Force |
                        Sort-Object -Property { $_.VersionInfo.FileVersion } -Descending |
                            Select-Object -First 1

                    if (-not $DllFile) {
                        Write-Verbose "No 'Microsoft.Identity.Client.dll' found in $($Module.ModuleBase)."
                        continue
                    }

                    # Store the module and DLL information in a custom object.
                    $ThisModule = [PSCustomObject]@{
                        Name          = $Module.Name
                        ModuleBase    = $Module.ModuleBase
                        ModuleVersion = $Module.Version
                        DLLVersion    = [version]($DllFile.VersionInfo.FileVersion)
                        DLLPath       = $DllFile.FullName
                    }

                    # Add the module information to the ordered list.
                    $ModulesWithVersionSortedIdentityClient.Add($ThisModule)
                }

                # Sort the modules by DLL version.
                if ($Ascending) {
                    $ModulesWithVersionSortedIdentityClient = $ModulesWithVersionSortedIdentityClient | Sort-Object -Property DLLVersion
                }
                else {
                    $ModulesWithVersionSortedIdentityClient = $ModulesWithVersionSortedIdentityClient | Sort-Object -Property DLLVersion -Descending
                }
                $ModulesWithVersionSortedIdentityClient
            } # end process block
        } # end Get-ModulesWithVersionSortedIdentityClient function
        #endregion EmbeddedFunctions

    } # end begin block

} # end function
