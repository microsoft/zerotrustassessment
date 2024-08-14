[CmdletBinding()]
Param(
    [Parameter()]
    [switch]$preview = $false
)

$ModuleRoot = "./src/powershell"
$ModuleManifestPath = "./src/powershell/*.psd1"


$ManfifestPath = Get-PathInfo $ModuleManifestPath -DefaultFilename "*.psd1" -ErrorAction Stop | Select-Object -Last 1
$moduleName = Split-Path $ManfifestPath -LeafBase

if ( -not (Test-Path $ManfifestPath )) {
    Write-Error "Could not find PowerShell module manifest ($ManfifestPath)"
    throw
} else {
    # Get the current version of the module from the PowerShell gallery
    $previousVersion = (Find-Module -Name $moduleName -AllowPrerelease:$preview).Version
    Write-Host "Previous version: $previousVersion"

    $ver = [version]($previousVersion -replace '-preview')

    # Set new version number. If it is pre-release, increment the build number otherwise increment the minor version.
    $major = $ver.Major # Update this to change the major version number of Maester.
    $minor = $ver.Minor

    if ($preview) {
        $build = $ver.Build + 1
    } else {
        $minor = $ver.Minor + 1
        $build = 0 # Reset the build number when incrementing the minor version.
    }

    $NewVersion = '{0}.{1}.{2}' -f $major, $minor, $build

    $publicScripts = @( Get-ChildItem -Path "$ModuleRoot/public" -Recurse -Filter "*.ps1" )
    $FunctionNames = @( $publicScripts.BaseName | Sort-Object )

    $previewLabel = if ($preview) { '-preview' } else { '' }

    Update-ModuleManifest -Path $ManfifestPath -ModuleVersion $NewVersion -FunctionsToExport $FunctionNames -Prerelease $previewLabel
}

$NewVersion += $previewLabel
Write-Host "New version: $NewVersion"
#Add-Content -Path $env:GITHUB_OUTPUT -Value "newtag=$NewVersion"
#Add-Content -Path $env:GITHUB_OUTPUT -Value "tag=$NewVersion"
