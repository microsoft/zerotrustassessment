# Report building

Run all the following commands inside the `src/report` directory.

## Initial setup

- Run `npm install` to install all dependencies.

## Development

- Run `npm run dev` to start the development server.

## Copying a new ZeroTrustReport/ZeroTrustAssessmentReport.json

- Use quicktype (Paste JSON as Code) VSCode extension to generate this typescript interface from ZeroTrustAssessmentReport.json created by PowerShell
- Copy the ts and data to src/report/src/config/report-data.ts

## Building & updating PowerShell

- Run `npm run build` to build the report.
- Run `Copy-Item ./dist/index.html ../powershell/assets/ReportTemplate.html -Force`
- Then do the usual Import-Module .\ZeroTrustAssessment.psm1 to update the PowerShell module

> **Important:** `src/powershell/assets/ReportTemplate.html` is a committed, prebuilt bundle of this
> React app. `Invoke-ZtAssessment` embeds it at assessment runtime (`Get-HtmlReport`) — there is no CI
> step that rebuilds it. Any change under `src/report/` only reaches generated reports after you rebuild
> and copy the bundle with the two commands above and commit the updated `ReportTemplate.html`.
