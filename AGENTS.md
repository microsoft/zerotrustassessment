# AGENTS.md - zerotrustassessment

The **Zero Trust Assessment** PowerShell module runs tenant assessments and generates
reports. This file is the entry point for humans and coding agents. Copilot-specific guidance
already lives in [`.github/copilot-instructions.md`](.github/copilot-instructions.md), and
there are repo skills under [`.github/skills/`](.github/skills/).

## Repository map
| Path | What lives here |
| --- | --- |
| `src/powershell/` | Module source and dependency initialization. |
| `src/documentgenerator/` | Report and document-generation assets. |
| `build/` | Build pipeline, configuration, and helpers. |
| `code-tests/` | Pester commands, structure gates, and assessment tests. |
| `.github/skills/` | Repository-specific agent skills. |
| `.github/workflows/`, `.azure-pipelines/` | CI/CD definitions. |

## Conventions
See [`docs/conventions.md`](docs/conventions.md).

## Verification / Definition of Done
```powershell
pwsh scripts/verify.ps1
```

For the full suite, build the module and run Pester:

```powershell
pwsh build/powershell/Build-PSModule.ps1
Invoke-Pester -Path ./code-tests
```

A change is done when `verify.ps1` and the relevant tests under `code-tests/` pass.

## PR and work-item telemetry
Every PR must follow
[`.github/instructions/telemetry.instructions.md`](.github/instructions/telemetry.instructions.md).
