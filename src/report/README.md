# Report building

Run all the following commands inside the `src/report` directory.

## Initial setup

- Run `npm install` to install all dependencies.

## Development

- Run `npm run dev` to start the development server.
- Classic template source lives under `src/`.
- New/default work-in-progress source lives under `src-curent/`.
- Use `npm run dev:current` to run the new/default work-in-progress app.

## Refreshing demo report data

- Both frontend variants load `demo-report-data.json` through the Vite report-data plugin. Do not copy tenant exports into TypeScript or this fixture.
- Generate the fixture alongside the anonymized HTML/JSON sample using `build\demo-report\New-DemoReport.ps1` from the repository root. See `build\demo-report\README.md` for the paired source HTML/JSON inputs and publication targets.
- When the source report contains UX changes not yet in this checkout, reuse its HTML shell for the published demo rather than rebuilding it from older frontend sources.
- To check fixture loading without replacing production PowerShell templates, run `.\node_modules\.bin\vite.cmd build --config .\vite.config.current.ts` from this directory.

## Building & updating PowerShell

### Using npm shortcuts (recommended)

- Run `npm run build:current` to build the default/new template and auto-copy to `../powershell/assets/ReportTemplate.html`.
- Run `npm run build` to build the classic template and auto-copy to `../powershell/assets/ReportTemplate.classic.html`.
- Run `npm run build:templates` to build both templates and auto-copy both to assets.

The built files are now automatically copied to the PowerShell assets folder, so no manual copy step is needed.

### Using PowerShell directly (alternative)

- Run `pwsh -File ./report-build.ps1 -Template Both` to build once and update both template assets.
- Optional: run `pwsh -File ./report-build.ps1 -Template Default` to update only `ReportTemplate.html`.
- Optional: run `pwsh -File ./report-build.ps1 -Template Classic` to update only `ReportTemplate.classic.html`.

### Build details

- The default/new build uses `vite.config.current.ts` and `index.current.html` (from `src-curent`).
- The classic build uses `vite.config.ts` and `index.html` (from `src`).
- Then do the usual Import-Module .\ZeroTrustAssessment.psm1 to update the PowerShell module

> **Important:** `src/powershell/assets/ReportTemplate.html` (default/new) and
> `src/powershell/assets/ReportTemplate.classic.html` (classic) are committed, prebuilt bundles of this
> React app. `Invoke-ZtAssessment` embeds both templates at runtime (`Get-HtmlReport`) and now emits two
> files per run: `ZeroTrustAssessmentReport.html` (default/new) and `ZeroTrustAssessmentReport-classic.html`.
> There is no CI step that rebuilds template bundles; any change under `src/report/` only reaches
> generated reports after you rebuild and copy templates and commit updated assets.
