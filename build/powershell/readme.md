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

## How the parallel export works of Graph and tenant data works

Implemented a parallelized tenant export, with the goal of accelerating the export phase.
The configuration, what should be exported has been moved into a config file under assets: `export-tenant.config.psd1`

The actual export then processes those entries and launches background runspaces via PSFramework Runspace Workflows to actually execute them, wait for the completion and report it all.
The final result is the exact same json files as in the previous iteration.

> RelatedPropertyNames

The feature to include additional properties - previously used by the Service Principal export - has been rewritten to use batch requests, significantly improving the performance of exporting Service Principals (in my test lab, what took 2.5 minutes turned into 5 seconds).

> Export Statistics / Troubleshooting

One of the issues that arise with parallelizing the export is, that it is harder to troubleshoot the export.
When everything happens in the background, errors and details are easily lost.

To help with that - and also to better see performance issues - a new publicly available command has been added:

```powershell
Get-ZtExportStatistics
```

It includes the status, the duration, any errors and all related log messages.
Note: The logs are taken from the in-memory log, which is limited to 1024 entries _by default_.
An export that takes too long might not include all messages as it and other exports happening fill the in-memory log too fast.
The in-memory log's capacity can be increased like this:

```powershell
Set-PSFConfig -FullName PSFramework.Logging.MaxMessageCount -Value 102400
```

> Improved Batch Request handling

The new command `Invoke-ZtGraphBatchRequest` offers improved batch request handling, available for all tests or other, internal usage. It does _not_ integrate into request caching however, to limit memory overload.
Features:

- Handles throttling individually
- Handles paging individually
- Convenient query scaling: `Invoke-ZtGraphBatchRequest -Path "$Uri/{0}/$PropertyName" -ArgumentList $Results -Properties id`
- Can return a matched pair, matching each item in ArgumentList with the corresponding result (and whether it was successful)

> PSFramework dependency version update

The new export handling has to deal with one issue:
The config tracking - what export was successful and need not be repeated when resuming an export - now might be accessed from multiple runspaces in parallel.
To avoid conflicts, a feature from `v1.13.419` was used: RunspaceLocks allow marshalling parallel resource access, similar to classic locks in C#.

## How parallel test execution works

Tests are now processed in parallel runspaces, significantly speeding up the assessment phase.

By default, Up to 5 tests will now be processed at a time, there is a parameter & configuration setting to change that.

Added a new command for better Tests diagnostics:

> Get-ZtTestStatistics

```powershell
$s = Get-ZtTestStatistics
$s[0].Messages
```
```text
Timestamp           FunctionName           Line Level       TargetObject Message
---------           ------------           ---- -----       ------------ -------
2025-10-16 16:02:31 Invoke-ZtTest          54   Verbose                  Processing test '21810'
2025-10-16 16:02:31 Test-Assessment-21810  21   VeryVerbose              🟦 Start
2025-10-16 16:02:46 Add-ZtTestResultDetail 192  Verbose                  Adding test result detail for Resource-specific consent is restricted
2025-10-16 16:02:46 Add-ZtTestResultDetail 193  Debug                    Result: …
2025-10-16 16:02:46 Invoke-ZtTest          86   Verbose                  Processing test '21810' - Concluded
```
```powershell
$s | Where-Object Success -ne $true
```
```text
TestID Start               Duration         Success Error
------ -----               --------         ------- -----
21822  2025-10-16 16:02:40 00:00:02.1888895 False   Cannot bind argument to parameter 'InputObject' because it is null.
24568  2025-10-16 16:02:54 00:00:00.1956550 False   Cannot bind argument to parameter 'Policies' because it is null.
21862  2025-10-16 16:02:45 00:00:00.0535597 False   Response status code does not indicate success: Forbidden (Forbidden).
```


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
