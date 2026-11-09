# Conventions - zerotrustassessment

The shared [project instructions](../.github/copilot-instructions.md) provide
coding-agent context. [AGENTS.md](../AGENTS.md) is a thin entry point; path-scoped
instructions hold the detailed contracts for both coding and review.

## Layout

| Path | Responsibility |
| --- | --- |
| [src/powershell](../src/powershell) | Core module: service connections, tenant export, DuckDB, assessments, results, and report integration. Public/private commands and assessment implementations/Markdown are separate. |
| [build/powershell](../build/powershell) | Packaging/dependency/versioning tools. Default package output is `build/release/ZeroTrustAssessment/<ModuleVersion>`. |
| [src/report](../src/report) | Build-time React/Vite producer of self-contained static report HTML, not a production web server. |
| [src/react](../src/react) | Separate Docusaurus workshop/documentation site, statically published to GitHub Pages. |
| [src/documentgenerator](../src/documentgenerator) | Separate document-generation templates and assets. |
| [code-tests/commands](../code-tests/commands) | Command and integration-contract Pester tests. |
| [code-tests/general](../code-tests/general) | Structural/integrity gates. |
| [code-tests/test-assessments](../code-tests/test-assessments) | Assessment-specific behavioral regression tests. |
| [.github/skills](../.github/skills), [.github/workflows](../.github/workflows), [.azure-pipelines](../.azure-pipelines) | On-demand skills and CI/CD automation. |

## Authoring

- Follow the shared [PowerShell](../.github/instructions/powershell.instructions.md)
  and [assessment](../.github/instructions/assessments.instructions.md) contracts.
  Public/private module command files contain one top-level command with a unique
  name; local nested helpers and standalone build scripts have different roles.
- New assessments need matching code, Markdown, metadata, and relevant Pester
  coverage. Behavior fixes need an observable regression test of the failure,
  not just syntax checks or a mocked dispatcher.
- Treat `ReportTemplate.html` and `ReportTemplate.classic.html` as generated,
  committed assets: change the [report source](../src/report/README.md), build
  the affected variants, and include the generated assets. Never edit them manually.
  The workshop site has a separate [build boundary](../.github/instructions/workshop-docs.instructions.md).
- Keep secrets, tenant identifiers/payloads, and sensitive report data out of source,
  fixtures, and public diagnostics. Follow the canonical
  [PR/ADO telemetry contract](../.github/instructions/telemetry.instructions.md).
- [Review guidance](../.github/instructions/code-review.instructions.md) separates
  demonstrated defects from optional/editorial feedback. Historical sources and
  qualifications live in the [review evidence](copilot-review-evidence.md).

## Validation

The [manifest](../src/powershell/ZeroTrustAssessment.psd1) defines the supported
host, currently PowerShell 7.6. Windows PowerShell 5.1 is not an assessment host.
Run the following from the repository root in PowerShell:

```powershell
pwsh -NoLogo -NoProfile -NonInteractive -File .\scripts\verify.ps1
```

[verify.ps1](../scripts/verify.ps1) parses source `.ps1` and imports build `.psd1`
configuration. It does not import the module, run Pester, cover every PowerShell
extension, or prove behavior. Documentation-only changes do not need unrelated
module packaging or frontend builds. Its legacy build-first Pester hint does not
supply test bootstrap; use the source-based runner below.

Use the smallest relevant Pester tests with their required setup. The full runner
supplies shared AST/test data and imports the source module:

```powershell
pwsh -NoLogo -NoProfile -NonInteractive -File .\code-tests\pester.ps1 -Output Detailed
```

Do not replace that bootstrap with bare `Invoke-Pester -Path ./code-tests`.
Self-contained command fixtures can run separately when their own setup permits it.
The runner writes XML under `code-tests/TestResults` and has metadata-failure waiver
logic; inspect reported failed assertions/waivers, not just its final exit code.

Module import and prerequisite installation can download dependencies, load native
libraries, create caches, and alter module search paths. The complete native/service
dependency suite is not established as Linux-cloud-ready by this checkout. Use
existing compatible Windows CI when local prerequisites are unavailable; report
the exact checks run or blocked. Never present parser success as behavioral or
tenant validation. Do not connect to a tenant, publish, or invoke secret-backed
assessment validation as a routine test step.

## Packaging is separate from tests

When the assigned change actually requires packaging:

```powershell
pwsh -NoLogo -NoProfile -NonInteractive -File .\build\powershell\Build-PSModule.ps1
```

The build queries PSGallery and updates the **source manifest** version/export/
prerelease metadata before copying output. A custom output directory does not
avoid those side effects. The normal Pester runner imports source and does not
require this build first. Use the existing
[prerequisite installer](../build/powershell/Install-Prerequisites.ps1) only when
needed, and do not commit incidental version or generated-result changes.
