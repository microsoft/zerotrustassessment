# Troubleshoot Zero Trust Assessment runs

This guide helps administrators and contributors investigate export, database, and test failures using local diagnostics. For installation, access requirements, and common symptoms, start with the [PowerShell operating guide](../src/powershell/doc/readme.md#troubleshooting).

## Prerequisites

- Access to the output folder from the affected run.
- For a new support package, the same PowerShell session in which the problem occurred.
- For package analysis, PSFramework and permission to handle the diagnostic data.

> [!WARNING]
> Logs and support packages can contain tenant identifiers, user information, query text, and sensitive configuration. Do not post raw diagnostics publicly or upload them to an unapproved analysis service. Review the [support and privacy guidance](../SUPPORT.md) before sharing any excerpt.

## Troubleshooting checklist

Follow the failing stage rather than assuming every warning is a tenant security finding:

1. Record the module and PowerShell versions, selected pillar/test IDs, output path, and whether the run used `-Resume`.
2. Check service connection messages. An unavailable service can cause skipped checks; a Graph connection alone does not prove workload access.
3. Locate the run's progress logs, then open the individual collector or test log for the failing component.
4. For connection/import failures or exceptions outside those components, check the extended PSFramework logs or create a session support package before closing PowerShell.
5. Use the [symptom-based troubleshooting table](../src/powershell/doc/readme.md#troubleshooting) to check permissions, dependencies, certificate access, and resource limits.

## Logging

The module uses [PSFramework](https://psframework.org/) for diagnostic messages. The [complete output and log-location map](../src/powershell/doc/readme.md#logs-and-diagnostic-files) distinguishes:

- `<Path>\log\`: optional support-package ZIP containing a `.cliDat` snapshot, created by `Invoke-ZtAssessment -ExportLog` near completion.
- `<Path>\zt-export\logs\<yy-MM-dd-HHmmss>\`: progress files and per-component Markdown logs, generated independently of `-ExportLog`.
- `%APPDATA%\PowerShell\PSFramework\Logs\` on Windows: extended message logs and XML error records outside the assessment output directory.

For example, a run with `-Path C:\Reports\ZT` writes its per-run diagnostics beneath `C:\Reports\ZT\zt-export\logs`. Use the timestamped child directory for the run you are investigating, then:

| Stage | Files to inspect |
| --- | --- |
| Export | `1-export_progress.log` and `1-Export\export_<Name>.md` |
| Database | `2-database_progress.log` |
| Tests | `3-test_progress.log` and `2-Tests\<TestID>.md` |
| Connection, import, or broader session errors | PSFramework `*_message_*.log` and `*_error_*.xml`, correlated by process identifier and timestamp |

Some files can be absent after an early failure or when a phase was skipped by `-Resume`. The exported entities and database under `zt-export` are tenant data, not just logs; preserve them if needed for reproduction, but do not routinely include them in a public issue.

## Causes and next steps

| Diagnostic finding | Next step |
| --- | --- |
| Authentication failure, missing scope, or access denied | Check the [interactive and app-only access requirements](../src/powershell/doc/readme.md#permissions-and-roles), activate roles where needed, and reconnect after changes. |
| Missing or unavailable workload connection | Check platform support, dependency initialization, service licensing, and the connection error before investigating test logic. |
| Dependency timeout or failed export | Open the named collector's Markdown log and the logs for its dependencies. Confirm the data exists before relying on a resumed run. |
| Throttling, slow queries, or memory pressure | Review [concurrency, cache, and timeout settings](../src/powershell/doc/readme.md#tuning-configuration-settings-heavy-load--large-tenants). Increasing a timeout does not resolve authorization failures. |
| Test execution error | Correlate the test ID, timestamp, and source location with the log and code version. An execution error is not equivalent to a failed security recommendation. |
| Report rendering failure after successful collection | Preserve the exports and database; review the [report troubleshooting guidance](../src/powershell/doc/readme.md#the-html-report-shows-unexpected-application-error-invalid-array-length) before regenerating the report. |

## Exporting the logs in PSFramework format and analyzing

Create a support package **in the same PowerShell session** where the issue occurred so available messages, errors, and registered diagnostic data can be captured. Choose a destination for the package; it does **not** need to match the assessment output path.

The following command writes a package to an example destination. Replace the folder name with one for your run:

```powershell
New-PSFSupportPackage -Path C:\AssessmentLogs\Run01 -Force
```

Extract the generated ZIP and locate the `.cliDat` file inside it. Substitute that file's actual path in the examples below. The package is a snapshot, not an automatic copy of every report, exported entity, database, or historical log file. Retention limits and when you capture the package affect which messages are available. The snapshot can also contain command history and console output, so review it for sensitive information.

### Analyzing the logs manually

To inspect a package locally, import it and discover its properties before selecting fields:

1. Import the `.cliDat` file from your package.

   ```powershell
   $pack = Import-PSFClixml -Path 'C:\AssessmentLogs\package.cliDat'
   $pack | Get-Member -MemberType NoteProperty
   ```

2. Read messages in timestamp order, then narrow to warning/error context.

   ```powershell
   $pack.Messages | Sort-Object Timestamp |
       Format-Table Timestamp, Level, FunctionName, Message -Wrap

   $pack.Messages | Where-Object Level -in 'Warning', 'Error', 'Critical' |
       Format-List Timestamp, Level, FunctionName, Message, ErrorRecord
   ```

3. Inspect errors and registered assessment diagnostics. Field availability depends on the PSFramework version and the stage reached by the run; use the property list from step 1 rather than assuming every field exists.

   ```powershell
   $pack.Errors
   $pack | Get-Member -Name '_ZTA_*' -MemberType NoteProperty
   ```

| Field or group | What to look for |
| --- | --- |
| `Messages` | Timestamps, levels, function names, and the events leading up to a failure. |
| `Errors` | PSFramework error records and exception context. |
| `PSErrors`, when present | Captured PowerShell error history. |
| Environment/session properties | PowerShell version, operating system, loaded modules, and other session information exposed by the package. |
| `_ZTA_*` properties, when present | Assessment-specific export/test statistics and diagnostics. |

### Extract warning and error context

For a focused local text file, this example includes the two messages preceding each warning, error, or critical message. Adjust the context count if needed. The output can still contain sensitive data; review it before sharing.

```powershell
$pack = Import-PSFClixml -Path 'C:\AssessmentLogs\package.cliDat'
$allMsgs = @($pack.Messages | Sort-Object Timestamp)
$results = for ($i = 0; $i -lt $allMsgs.Count; $i++) {
    if ($allMsgs[$i].Level -in 'Warning', 'Error', 'Critical') {
        $contextStart = [Math]::Max(0, $i - 2)
        ">>> Warning or error at message $i"
        for ($j = $contextStart; $j -le $i; $j++) {
            $m = $allMsgs[$j]
            "[$($m.Timestamp)] [$($m.Level)] [$($m.FunctionName)] $($m.Message)"
            if ($j -eq $i -and $m.ErrorRecord) {
                $m.ErrorRecord | Out-String
            }
        }
        ''
    }
}
$results | Out-String -Width 4096 |
    Set-Content -Path '.\errors-with-context.txt' -Encoding UTF8
```

<a name="analyzing-the-logs-with-provide-github-copilot-skill"></a>

### Optional Copilot-assisted analysis

The repository includes a [PSFramework support-package analyzer skill](../.github/skills/psf-support-package-analyzer/SKILL.md). Use it only if your organization's data-handling policy permits processing the package with the selected AI service. Having a local file does not mean that an AI-assisted analysis stays entirely local.

In Copilot CLI or an editor with the repository skill available, ask it to analyze the approved package:

```text
Analyze the support package at C:\AssessmentLogs\package.cliDat
```

Review the generated findings against the source and logs before acting on them. Report bugs through the [community issue process](../SUPPORT.md#how-to-file-issues-and-get-help), with sanitized evidence rather than the raw package.
