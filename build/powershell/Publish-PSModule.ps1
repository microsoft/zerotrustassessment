#Requires -Version 7.0
param
(
    # Path to Module Manifest
    [Parameter(Mandatory = $false)]
    [string] $ModuleManifestPath = ".\build\release\*\*.*.*\*.psd1",
    # Repository for PowerShell Gallery
    [Parameter(Mandatory = $false)]
    [string] $RepositorySourceLocation = 'https://www.powershellgallery.com/api/v2',
    # API Key for PowerShell Gallery
    [Parameter(Mandatory = $true)]
    [SecureString] $NuGetApiKey,
    # Unlist from PowerShell Gallery
    [Parameter(Mandatory = $false)]
    [switch] $Unlist
)

## Initialize
Import-Module "$PSScriptRoot\CommonFunctions.psm1" -Force -WarningAction SilentlyContinue -ErrorAction Stop

[System.IO.FileInfo] $ModuleManifestFileInfo = Get-PathInfo $ModuleManifestPath -DefaultFilename "*.psd1" -ErrorAction Stop | Select-Object -Last 1

## Read Module Manifest
$ModuleManifest = Import-PowerShellDataFile $ModuleManifestFileInfo.FullName

if (-not (Get-PSResourceRepository -Name 'PSGallery' -ErrorAction SilentlyContinue)) {
    Register-PSResourceRepository -PSGallery -ErrorAction Stop
}

## Install Module Dependencies
foreach ($Module in $ModuleManifest['RequiredModules']) {
    if ($Module -is [hashtable]) { $ModuleName = $Module.ModuleName }
    else { $ModuleName = $Module }
    if ($ModuleName -notin $ModuleManifest.PrivateData.PSData['ExternalModuleDependencies'] -and !(Get-Module $ModuleName -ListAvailable)) {
        Install-PSResource -Name $ModuleName -Repository PSGallery -TrustRepository -AcceptLicense -ErrorAction Stop
    }
}

## Publish
$ApiKeyPlainText = (ConvertFrom-SecureString $NuGetApiKey -AsPlainText).Trim()
$PSRepositoryAll = Get-PSResourceRepository
$PSRepository = $PSRepositoryAll | Where-Object Uri -Like "$RepositorySourceLocation*"
if (!$PSRepository) {
    try {
        [string] $RepositoryName = New-Guid
        Register-PSResourceRepository -Name $RepositoryName -Uri $RepositorySourceLocation
        $PSRepository = Get-PSResourceRepository -Name $RepositoryName
        Publish-PSResource -Path $ModuleManifestFileInfo.DirectoryName -ApiKey $ApiKeyPlainText -Repository $PSRepository.Name
    }
    finally {
        Unregister-PSResourceRepository -Name $RepositoryName
    }
}
else {
    Write-Host ('Publishing Module Path [{0}]' -f $ModuleManifestFileInfo.DirectoryName) -ForegroundColor Green
    Publish-PSResource -Path $ModuleManifestFileInfo.DirectoryName -ApiKey $ApiKeyPlainText -Repository $PSRepository.Name
}

## Unlist the Package
if ($Unlist) {
    $PublishLocation = "{0}/package" -f $PSRepository.Uri.ToString().TrimEnd('/')
    if ($ModuleManifest.PrivateData.PSData['Prerelease']) {
        Invoke-RestMethod -Method Delete -Uri ("{0}/{1}/{2}-{3}" -f $PublishLocation, $ModuleManifestFileInfo.BaseName, $ModuleManifest['ModuleVersion'], $ModuleManifest.PrivateData.PSData['Prerelease']) -Headers @{ 'X-NuGet-ApiKey' = $ApiKeyPlainText }
    }
    else {
        Invoke-RestMethod -Method Delete -Uri ("{0}/{1}/{2}" -f $PublishLocation, $ModuleManifestFileInfo.BaseName, $ModuleManifest['ModuleVersion']) -Headers @{ 'X-NuGet-ApiKey' = $ApiKeyPlainText }
    }
}
