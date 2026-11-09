# AGENTS.md - zerotrustassessment

The **Zero Trust Assessment** PowerShell module runs tenant assessments and generates
reports. Start with the shared
[Copilot project instructions](.github/copilot-instructions.md) and
[contributor conventions](docs/conventions.md). This file is a navigation entry
point, not a separate rulebook.

## Repository map
| Path | What lives here |
| --- | --- |
| `src/powershell/` | Core module, assessments, data, and report integration. |
| `build/powershell/` | Packaging tools; default package output is under `build/release/`. |
| `src/report/` | React producer of committed static report templates; never edit generated HTML manually. |
| `src/react/` | Docusaurus workshop/documentation site published to GitHub Pages. |
| `src/documentgenerator/` | Separate document-generation templates and assets. |
| `code-tests/` | Pester commands, structure gates, and assessment tests. |
| `.github/skills/` | Repository-specific agent skills. |
| `.github/workflows/`, `.azure-pipelines/` | CI/CD definitions. |

## Verification

Use PowerShell 7.6 or the current manifest minimum. From the repository root:
```powershell
pwsh -NoLogo -NoProfile -NonInteractive -File .\scripts\verify.ps1
```

This is a parsing/configuration gate, not behavioral validation. Run relevant
tests using their required bootstrap; the full source-based runner is
`code-tests/pester.ps1`, not a bare recursive `Invoke-Pester` call. Packaging is
not a test prerequisite. See the [validation guidance](docs/conventions.md#validation)
for commands, side effects, and compatible-CI limitations.

## PR and work-item telemetry
Every PR must follow
[`.github/instructions/telemetry.instructions.md`](.github/instructions/telemetry.instructions.md).
