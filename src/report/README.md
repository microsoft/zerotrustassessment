# Report building

Run all the following commands inside the `src/report` directory.

## Initial setup

- Run `npm install` to install all dependencies.

## Development

- Run `npm run dev` to start the development server.
- Classic template source lives under `src/`.
- New/default work-in-progress source lives under `src-curent/`.
- Use `npm run dev:current` to run the new/default work-in-progress app.

## Copying a new ZeroTrustReport/ZeroTrustAssessmentReport.json

- Use quicktype (Paste JSON as Code) VSCode extension to generate this typescript interface from ZeroTrustAssessmentReport.json created by PowerShell
- Copy the ts and data to src/report/src/config/report-data.ts

## Building & updating PowerShell

- Run `pwsh -File ./report-build.ps1 -Template Both` to build once and update both template assets.
- Optional: run `pwsh -File ./report-build.ps1 -Template Default` to update only `ReportTemplate.html`.
- Optional: run `pwsh -File ./report-build.ps1 -Template Classic` to update only `ReportTemplate.classic.html`.
- The default/new build uses `vite.config.current.ts` and `index.current.html` (from `src-curent`).
- The classic build uses `vite.config.ts` and `index.html` (from `src`).
- Then do the usual Import-Module .\ZeroTrustAssessment.psm1 to update the PowerShell module

> **Important:** `src/powershell/assets/ReportTemplate.html` (default/new) and
> `src/powershell/assets/ReportTemplate.classic.html` (classic) are committed, prebuilt bundles of this
> React app. `Invoke-ZtAssessment` embeds both templates at runtime (`Get-HtmlReport`) and now emits two
> files per run: `ZeroTrustAssessmentReport.html` (default/new) and `ZeroTrustAssessmentReport-classic.html`.
> There is no CI step that rebuilds template bundles; any change under `src/report/` only reaches
> generated reports after you rebuild and copy templates and commit updated assets.
