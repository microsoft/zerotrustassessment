# Building and publishing the module

## Create a preview build

To build the module, run the following command from the root. This auto increments the version number.

Use -ProductionBuild since this is not -Preview build.

```powershell
./build/powershell/Build-PSModule.ps1 -ProductionBuild
```

## Publish to the PowerShell gallery

To publish the module to the PowerShell gallery, run the following command from the root.

```powershell
$key = Read-Host -Prompt "Enter your API key" -AsSecureString
./build/powershell/Publish-PSModule.ps1 -NuGetApiKey $key
```
