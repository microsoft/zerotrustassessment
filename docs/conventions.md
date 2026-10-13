# Conventions - zerotrustassessment

These conventions reflect the current repository structure and should evolve with it.

## Layout

- `src/powershell/` contains module source.
- `src/documentgenerator/` contains report-generation assets.
- `build/` contains the build pipeline and configuration.
- `code-tests/commands/` contains command tests.
- `code-tests/general/` contains structural and integrity gates.
- `code-tests/test-assessments/` contains assessment-specific tests.
- `.github/skills/`, `.github/workflows/`, and `.azure-pipelines/` contain automation.

## Authoring

- Keep one PowerShell command per file and command names unique.
- Add or update tests under `code-tests/` for behavior changes.
- New assessments should have a matching `Test-Assessment.<id>.Tests.ps1`.
- Build the module before running tests that import it.
- Do not commit secrets, tokens, tenant identifiers, or sensitive report data.

## Validation

Run `pwsh scripts/verify.ps1` for the readiness verification loop. For full validation,
build the module and run `Invoke-Pester -Path ./code-tests`.
