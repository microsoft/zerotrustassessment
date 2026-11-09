---
description: "Use when changing or reviewing the Docusaurus Zero Trust Workshop site and its GitHub Pages build. Covers site ownership, static publishing, routes, and localization, not React style."
applyTo: "src/react/**,.github/workflows/webapp-ghpages.yml"
---

# Workshop documentation site

- [src/react](../../src/react) is the Docusaurus workshop/documentation project,
  published as static GitHub Pages at
  https://microsoft.github.io/zerotrustassessment/docs/intro.
  It is separate from the React assessment-report producer in `src/report`.
- Use this directory's package manifest and committed lockfile. Run package
  commands from `src/react`; dependency restoration uses `npm ci`.
  The existing Pages workflow builds with Node.js 20; the package requires Node.js
  20 or newer. Do not apply the report project's Vite/template build commands here.
- `npm run build` generates the static site in `src/react/build`.
  `npm run start` is a local development server, not a production backend.
  The existing [Pages workflow](../workflows/webapp-ghpages.yml) builds and publishes
  this output; do not change publishing behavior as an incidental documentation fix.
- Preserve the configured `/zerotrustassessment/` base path, document IDs/routes,
  sidebars, and existing localization. Check links and assets against the static
  Pages deployment, not just a local development URL.
- Keep changes in the relevant documentation/source/localization locations.
  Do not modify PowerShell report templates to update workshop content, and do
  not copy customer reports or tenant data into public site assets.
- Validate affected site changes with the existing production build and report
  actual failures or unavailable prerequisites. Do not introduce a new React
  coding standard, runtime service, or unrelated dependency churn for this scope.
