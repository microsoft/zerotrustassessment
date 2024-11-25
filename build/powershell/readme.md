# Building and publishing the module

## Create a preview build

To build the module, run the following command from the root. This auto increments the version number.

```powershell
./build/powershell/Build-PSModule.ps1
```

## Publish to the PowerShell gallery

To publish the module to the PowerShell gallery, run the following command from the root.

```powershell
./build/powershell/Publish-PSModule.ps1 -NuGetApiKey <API_KEY>
```
