# This script builds the PowerShell module and increments the build number
# Run from the root of the repository with `./build/Build-PSModule.ps1`

$outputPath = './output/ZeroTrustAssessment'

# Clean the output directory
if (Test-Path $outputPath) {
    Remove-Item -Recurse -Force $outputPath
}

# Build the module
dotnet publish ./src/powershell/ZeroTrustAssessment/ZeroTrustAssessment.csproj --output $outputPath --configuration Release

# Get the current version in the gallery and increment the build number
$ver = [version](Find-Module -Name ZeroTrustAssessment).Version
$newBuild = $ver.Build + 1
$newVer = '{0}.{1}.{2}' -f $ver.Major, $ver.Minor, $newBuild

# Update the version in the module manifest
$manifestPath = 'src/powershell/ZeroTrustAssessment/ZeroTrustAssessment.psd1'
$manifest = Get-Content -Path $manifestPath -Raw
$manifest = $manifest -replace 'ModuleVersion = ''\d+\.\d+\.\d+''', "ModuleVersion = '$newVer'"
$manifest = $manifest -replace "RootModule = './src/powershell/ZeroTrustAssessment/bin/Debug/net7.0/ZeroTrustAssessment.dll'", "RootModule = 'ZeroTrustAssessment.dll'"
$manifestOutputPath = $outputPath + '/ZeroTrustAssessment.psd1'
Set-Content -Path $manifestOutputPath -Value $manifest

