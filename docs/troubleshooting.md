# Troubleshooting guide for dev teams
This guide provides basic troubleshooting guidelines

## Logging

This Zero Trust Assessment tooling is based on Microsoft PowerShell and makes heavy use of [PSFramework](https://psframework.org/). Logs are generated and saved in a sub folder `./zt-export/logs` of the main path that you pointed the tool to export the report. For example, if you invoked the zero trust assessment using the parameters:
```PowerShell
Invoke-ZtAssessment -Path c:/t/ztreport/mydomain.com/2026-05-21_01
```
The location of the logs will be `c:/t/ztreport/mydomain.com/2026-05-21_01/zt-export/logs`.

## Exporting the logs in PSFramework format and analyzing

You can compact the logs in a format that PSFramework provides for easy log transfer and analytics using the command:

```PowerShell
New-PSFSupportPackage -Path C:\AssessmentLog_2025_01_01 -Force
```

You must point the command to the same path which you provided to the `Invoke-ZTAssessment`.

### Analyzing the logs manually

 1. Import the package
```PowerShell
$pack = Import-PSFClixml -Path".\ptah\to\exported\file.cliDat"
```
 2. Browse available data
 ```PowerShell
$pack | Get-Member -MemberType NoteProperty

 3. View log messages (most useful for troubleshooting)
```PowerShell
 $pack.Messages | Format-Table Timestamp, Level, FunctionName, Message -AutoSize

 4. Filter for errors/warnings only
```PowerShell
 $pack.Messages | Where-Object Level -in 'Warning','Error' | Format-Table
```

 5. View PowerShell errors
```PowerShell
 $pack.Errors
```

 6. Check environment info
```PowerShell
 $pack.PSVersion
 $pack.OperatingSystem
 $pack.Modules
```

Key properties in the package will be:

| Property   | Purpose                                                      |
|------------|--------------------------------------------------------------|
| Messages   | PSFramework log entries (timestamps, levels, function names) |
| Errors     | PowerShell $Error collection                                 |
| PSErrors   | Additional error records                                     |
| History    | Command history from the session                             |
| Modules    | Loaded modules at capture time                               |
| _ZTA_*     | Custom project-specific data (export/test statistics)        |

Start with $pack.Messages | Where-Object Level -in 'Warning','Error' to find issues, then correlate with $pack.Errorsfor stack traces.

Here is a reusable one-liner that extract all the Errors and Warnings, brings the 2 logs preceeding the error or warning and outputs everything into a text file:

```PowerShell
 $pack = Import-PSFClixml -Path ".\path\to\export\data-file.cliDat"
 $allMsgs = $pack.Messages | Sort-Object Timestamp
 $results = for ($i = 0; $i -lt $allMsgs.Count; $i++) {
     if ($allMsgs[$i].Level -in 'Warning','Error','Critical') {
         $contextStart = [Math]::Max(0, $i - 2)
         "=" * 100
         ">>> ERROR/WARNING at index $i <<<"
         "=" * 100
         for ($j = $contextStart; $j -le $i; $j++) {
             $m = $allMsgs[$j]
             $prefix = if ($j -eq $i) { ">>>" } else { "   " }
             "$prefix [$($m.Timestamp)] [$($m.Level)] [$($m.FunctionName)] $($m.Message)"
             if ($j -eq $i -and $m.ErrorRecord) {
                 "    --- ErrorRecord ---"
                 $m.ErrorRecord | Out-String
             }
         }
         ""
     }
 }
 $results | Out-String -Width 4096 | Set-Content ".\errors_with_context.txt" -Encoding UTF8
```

Change `-2` to `-5` etc. (ont he line ` $contextStart = [Math]::Max(0, $i - 2) `) if you want more context lines.

### Analyzing the logs with provide GitHub Copilot skill

This repository contains a GitHub Copilot troubleshooter skill that helps with first round of analysis. You can run it either via copilot CLI:

```PowerShell
 copilot -C C:\t\zerotrustassessment
 > Analyze the support package at C:\logs\customer_pack.cliDat
```

Or directly from VS Code (OR Visual Studio) Copilot chat:
```
 /psf-support-package-analyzer C:\path\to\support\package-file.cliDat
```

Copilot with automatically invoke the skill when it sees relevant triggerphrases.
