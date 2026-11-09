---
description: "Use when changing or reviewing the React report producer, generated assessment HTML templates, or their PowerShell payload integration. Covers static assets and build ownership, not React style."
applyTo: "src/report/**,src/powershell/assets/ReportTemplate*.html,src/powershell/**/Get-HtmlReport.ps1,code-tests/commands/ReportTemplate.Markers.Tests.ps1"
---

# Static assessment report

## Ownership and runtime boundary

- `src/report` is a React/Vite build-time producer of self-contained HTML assets.
  PowerShell injects assessment data into those assets after assessment. It is not
  a deployed web application, API, or report-server component.
- Vite development/preview servers are local authoring tools only. Do not add a
  production server or confuse this project with the Docusaurus site in
  [src/react](../../src/react).
- Never manually edit, search/replace, or patch the generated
  [default template](../../src/powershell/assets/ReportTemplate.html) or
  [classic template](../../src/powershell/assets/ReportTemplate.classic.html).
  Change the producer source and regenerate the affected asset.

## Sources and builds

Run package commands from `src/report`, using its own manifest and lockfile.

| Variant | Source | Build and automatic copy |
| --- | --- | --- |
| Default/new | `src-curent` (existing spelling), `vite.config.current.ts` | `npm run build:current` -> `ReportTemplate.html` |
| Classic | `src`, `vite.config.ts` | `npm run build` -> `ReportTemplate.classic.html` |
| Both | Both variants | `npm run build:templates` |

- These commands invoke `report-build.ps1` and copy the built HTML into PowerShell
  assets. CI does not rebuild these committed bundles. Runtime source changes must
  include the corresponding regenerated asset; regenerate both for shared changes
  affecting both variants, not for unrelated documentation edits.
- Preserve the exact `reportData={` and `EndOfJson:"EndOfJson"}` markers used by
  PowerShell substitution. Run the existing
  [marker contract tests](../../code-tests/commands/ReportTemplate.Markers.Tests.ps1)
  when changing payload injection, build configuration, or templates.
- Trace changes to report data through PowerShell producers, exported JSON,
  TypeScript shapes, and both affected renderers. Preserve actual verdicts,
  availability, counts, and evidence; calculating a status without rendering it
  does not complete a report feature.
- Use sanitized/synthetic demo data. Do not copy tenant exports into source,
  fixtures, generated assets, or public logs. Follow the
  [report build documentation](../../src/report/README.md) for demo-data generation
  and variant-specific authoring commands.
