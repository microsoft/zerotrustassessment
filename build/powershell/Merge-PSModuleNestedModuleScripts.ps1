param
(
    # Path to Module Manifest
    [Parameter(Mandatory = $false)]
    [string] $ModuleManifestPath = ".\release\*\*.*.*",
    #
    [Parameter(Mandatory = $false)]
    [string] $OutputModulePath,
    #
    [Parameter(Mandatory = $false)]
    [switch] $MergeWithRootModule,
    #
    [Parameter(Mandatory = $false)]
    [switch] $RemoveNestedModuleScriptFiles
)

## Initialize
Import-Module "$PSScriptRoot\CommonFunctions.psm1" -Force -WarningAction SilentlyContinue -ErrorAction Stop

[System.IO.FileInfo] $ModuleManifestFileInfo = Get-PathInfo $ModuleManifestPath -DefaultFilename "*.psd1" -ErrorAction Stop
#[System.IO.DirectoryInfo] $ModuleSourceDirectoryInfo = $ModuleManifestFileInfo.Directory
#[System.IO.DirectoryInfo] $ModuleOutputDirectoryInfo = $OutputModuleFileInfo.Directory

## Read Module Manifest
$ModuleManifest = Import-PowerShellDataFile $ModuleManifestFileInfo.FullName

if ($OutputModulePath) {
    [System.IO.FileInfo] $OutputModuleFileInfo = Get-PathInfo $OutputModulePath -InputPathType File -DefaultFilename "$($ModuleManifestFileInfo.BaseName).psm1" -ErrorAction SilentlyContinue
}
else {
    [System.IO.FileInfo] $OutputModuleFileInfo = Get-PathInfo $ModuleManifest['RootModule'] -InputPathType File -DefaultDirectory $ModuleManifestFileInfo.DirectoryName -ErrorAction SilentlyContinue
    if (!$PSBoundParameters.ContainsKey('MergeWithRootModule')) { $MergeWithRootModule = $true }
}

if ($OutputModuleFileInfo.Extension -eq ".psm1") {

    [System.IO.FileInfo] $RootModuleFileInfo = Get-PathInfo $ModuleManifest['RootModule'] -InputPathType File -DefaultDirectory $ModuleManifestFileInfo.DirectoryName -ErrorAction SilentlyContinue
    [System.IO.FileInfo[]] $NestedModulesFileInfo = $ModuleManifest['NestedModules'] | Get-PathInfo -InputPathType File -DefaultDirectory $ModuleManifestFileInfo.DirectoryName -ErrorAction SilentlyContinue
    [System.IO.FileInfo[]] $ScriptsToProcessFileInfo = $ModuleManifest['ScriptsToProcess'] | Get-PathInfo -InputPathType File -DefaultDirectory $ModuleManifestFileInfo.DirectoryName -ErrorAction SilentlyContinue

    if ($MergeWithRootModule) {
        ## Split module parameters from the rest of the module content
        [string] $RootModuleParameters = $null
        [string] $RootModuleContent = $null
        if ($RootModuleFileInfo.Extension -eq ".psm1" -and (Get-Content $RootModuleFileInfo.FullName -Raw) -match "(?s)^(.*\n?\s*param\s*[(](?:[^()]|(?'Nested'[(])|(?'-Nested'[)]))*[)]\s*)?(.*)$") {
            $RootModuleParameters = $Matches[1]
            $RootModuleContent = $Matches[2]
        }

        $NestedModuleRegion = "#region NestedModules Script(s)`r`n"

        $RootModuleParameters, $NestedModuleRegion | Set-Content $OutputModuleFileInfo.FullName -Encoding utf8BOM
    }

    ## Add Nested Module Scripts
    $NestedModulesFileInfo | Where-Object Extension -EQ '.ps1' | ForEach-Object { "#region $($_.Name)`r`n`r`n$(Get-Content $_ -Raw)`r`n#endregion`r`n" } | Add-Content $OutputModuleFileInfo.FullName -Encoding utf8BOM

    if ($MergeWithRootModule) {
        ## Add remainder of root module content
        ## NOTE: We intentionally do NOT add Export-ModuleMember here because:
        ## 1. The PSD1's FunctionsToExport already controls what gets exported when imported normally
        ## 2. Adding Export-ModuleMember breaks runspace workers that need access to private functions
        ##    (e.g., PSFramework runspace workflows that load the PSM1 directly)
        $NestedModuleEndRegion = "#endregion`r`n"
        
        $NestedModuleEndRegion, $RootModuleContent | Add-Content $OutputModuleFileInfo.FullName -Encoding utf8BOM
    }

    if ($RemoveNestedModuleScriptFiles) {
        ## Remove Nested Module Scripts
        $NestedModulesFileInfo | Where-Object Extension -EQ '.ps1' | Where-Object { !$ScriptsToProcessFileInfo -or $_.FullName -notin $ScriptsToProcessFileInfo.FullName } | Remove-Item
        
        ## Remove Empty Directories
        Get-ChildItem $ModuleManifestFileInfo.DirectoryName -Recurse -Directory | Where-Object { !(Get-ChildItem $_.FullName -Recurse -File) } | Remove-Item -Recurse
    }
}
