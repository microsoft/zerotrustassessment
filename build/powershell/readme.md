# Developer Guide for the PowerShell module

## Initial setup

### Install dependencies

Lookup /src/powershell/ZeroTrustAssessment.psd1 and install all the required modules using `Install-Module <ModuleName>`.

### Import the module

From the /src/powershell directory, run:

```powershell
Import-Module ./src/powershell/ZeroTrustAssessment.psd1 -Force
```

### Invoke-ZtAssessment tips

You can now run Invoke-ZtAssessment to test the module. Use the parameters to limit tests to individual pillars and specific tests within a pillar. See help for details.

#### Use tenant specific folders

Use the ./ZeroTrustReport folder to store the output. The ZeroTrustReport folder is excluded from source control so you can create subfolders for each tenant you test. Plus you can open the folder directly in VSCode if you need to inspect the downloaded data or exported json report.

E.g 'pora' is my tenant name:

```powershell
Invoke-ZtAssessment -Path ./ZeroTrustReport/pora/2025-11-26-1
```

If I want a fresh download I always provide a different path

E.g. the first run of the day I append a -1 to the folder name:

```powershell
Invoke-ZtAssessment -Path ./ZeroTrustReport/pora/2025-11-26-1
```

On the second run of the day I append a -2 to the folder name:

```powershell
Invoke-ZtAssessment -Path ./ZeroTrustReport/pora/2025-11-26-2
```

#### Resume an assessment

Use the -Resume option if you are running tests with the same data each time or if you test only uses Graph API calls.

Using -Resume skips data that has already been downloaded and stored in the local cache of the folder you specify.

E.g. 

```powershell
Invoke-ZtAssessment -Path ./ZeroTrustReport/pora/2025-11-26-2 -Resume
```

### Troubleshooting export issues

The export module uses parallel processing to speed up exports. However, it can be difficult to troubleshoot issues that occur during export since each job runs in its own process and errors may not be displayed in the main console.

Using the Write-PSFMessage cmdlet to log and then checking with the `Get-ZtExportStatistics` cmdlet can help identify issues that occurred during export.

Here's how to display the log after running the assessment.

```powershell
$l = Get-ZtExportStatistics
$l
```

Display all the messages logged during export.

```powershell
$l.Messages
```

You can also view the log for each job by it's name.

## Building and publishing the module

### Create a preview build

To build the module, run the following command from the root. This auto increments the version number.

Use -ProductionBuild since this is not -Preview build.

```powershell
./build/powershell/Build-PSModule.ps1 -ProductionBuild
```

### Publish to the PowerShell gallery

To publish the module to the PowerShell gallery, run the following command from the root.

```powershell
$key = Read-Host -Prompt "Enter your API key" -AsSecureString
./build/powershell/Publish-PSModule.ps1 -NuGetApiKey $key
```
