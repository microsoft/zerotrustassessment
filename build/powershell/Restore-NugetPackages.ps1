param
(
    [Parameter(Mandatory = $true)]
    [string] $PackagesConfigPath,

    [Parameter(Mandatory = $true)]
    [string] $OutputDirectory,

    [Parameter()]
    [string] $NuGetFlatContainerUrl = 'https://api.nuget.org/v3-flatcontainer'
)

$ErrorActionPreference = 'Stop'

[System.IO.FileInfo] $packagesConfigFile = Get-Item -Path $PackagesConfigPath -ErrorAction Stop
[System.IO.DirectoryInfo] $packagesDirectory = New-Item -Path $OutputDirectory -ItemType Directory -Force -ErrorAction Stop

$xmlPackagesConfig = New-Object xml
$xmlPackagesConfig.Load($packagesConfigFile.FullName)

foreach ($package in $xmlPackagesConfig.packages.package) {
    $packageId = [string] $package.id
    $packageVersion = [string] $package.version
    $packageOutputDirectory = Join-Path $packagesDirectory.FullName ("{0}.{1}" -f $packageId, $packageVersion)

    if (Test-Path -Path $packageOutputDirectory -PathType Container) {
        Write-Verbose -Message ("Package {0} {1} already restored." -f $packageId, $packageVersion)
        continue
    }

    $packageIdLower = $packageId.ToLowerInvariant()
    $packageVersionLower = $packageVersion.ToLowerInvariant()
    $packageUrl = "{0}/{1}/{2}/{1}.{2}.nupkg" -f $NuGetFlatContainerUrl.TrimEnd('/'), $packageIdLower, $packageVersionLower
    $downloadPath = Join-Path $packagesDirectory.FullName ("{0}.{1}.nupkg" -f $packageId, $packageVersion)

    Write-Host ("Restoring NuGet package {0} {1}" -f $packageId, $packageVersion)
    Invoke-WebRequest -Uri $packageUrl -OutFile $downloadPath

    $null = New-Item -Path $packageOutputDirectory -ItemType Directory -Force
    Expand-Archive -Path $downloadPath -DestinationPath $packageOutputDirectory -Force
    Remove-Item -Path $downloadPath -Force
}
