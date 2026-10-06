# Generate the demo report

`New-DemoReport.ps1` creates an anonymized HTML report and companion JSON from an assessment export. It can reuse a completed report's HTML shell, preserving a newer UX even when its frontend source is not yet in the checkout.

Run the generator with PowerShell 7 from the repository root. Supply HTML and JSON from the **same assessment run**:

```powershell
.\build\demo-report\New-DemoReport.ps1 `
    -InputJsonPath 'C:\Reports\LatestRun\zt-export\ZeroTrustAssessmentReport.json' `
    -SourceHtmlPath 'C:\Reports\LatestRun\ZeroTrustAssessmentReport.html' `
    -OutputHtmlPath '.\SampleReport.html' `
    -OutputFrontendJsonPath '.\src\report\demo-report-data.json' `
    -OutputWebsiteHtmlPath '.\src\react\static\demo\index.html'
```

| Output | Purpose |
| --- | --- |
| `SampleReport.html` | Checked-in standalone demo with the supplied UX shell. |
| `SampleReport.json` | Anonymized companion data, generated beside the HTML. |
| `src\report\demo-report-data.json` | The same dataset for frontend development and builds. |
| `src\react\static\demo\index.html` | Identical HTML copy for the existing website demo. |

The frontend and website output parameters are optional. Without `-SourceHtmlPath`, the generator uses the repository report template instead; that fallback cannot reproduce UX changes absent from the repository. It does not rebuild or overwrite production templates.

The existing optional `-SourceJsonPath` overlays Network and AI assessments from a secondary export before applying the same anonymization and validation pipeline. When using source HTML, its embedded payload must match the primary input; do not supply HTML from an unrelated run.

## Anonymization contract

All GUIDs, including built-in role and application identifiers, become GUIDs containing one repeated decimal digit throughout. Only ten values are available, so distinct original GUIDs can deliberately share a demo GUID. Records are not deduplicated by those masked IDs, and original-to-demo mappings are never written to the repository. A dictionary that cannot retain its entries after masking is rejected rather than silently losing data.

Human names use deterministic invented aliases with numeric suffixes, not a catalog of real people or fictional characters. Agents use a separate synthetic namespace. The customer-domain palette is `contoso.com`, `contoso.onmicrosoft.com`, and synthetic subdomains. Customer-specific names, UPNs, network addresses, paths and app URLs are replaced, including identifying URL paths, queries and fragments. Customer app names are retained only when they do not expose an identity.

Reviewed public documentation/product references and required public runtime constants may remain. HTTP and HTTPS references under `Remediation`, `Remediation action`, and `Remediation links` sections remain intact unless they contain identity or credential markers. Deep links into Azure, Entra, Microsoft 365, security, compliance, Intune, Defender, Purview, Exchange, Teams, Power Platform, or Fabric administration portals are still replaced; a portal's generic root link may remain. Standard schema fields, product terms, chart node labels, numeric assessment IDs, pillar assignments and outcomes remain functional. Cloud recommendation GUID assessment IDs are masked too; their deliberate collisions do not remove assessment rows.

Dashboard populations are synthetic. Counts, ownership lists, chart flows and descriptions must reconcile. Assessment pass/total summaries are computed from the retained tests using the framework's status and multi-pillar rules; they are not fabricated independently.

Cloud secure scores use distinct representative percentages for each available environment, not multiples of ten. `All` is calculated from the combined current and maximum scores. Standard public environment names (`Azure`, `AWS`, `GCP`, and `All`) remain unchanged.

The generated data includes Boolean `IsDemo: true`. Collection metadata is synthetic, and credentials and sensitive diagnostic content are removed. Original-name CSVs and mappings are not required.

## Validation and publication

Generation validates the input pair, transformed data, privacy residuals, aggregate invariants, embedded payload and unchanged HTML shell before publishing final files. Malformed input, unresolved identifiers, conflicting output paths or unsupported transformations produce a terminating error. Never bypass a validation failure to publish a demo.

For a new source export, review the output in addition to running the checks: arbitrary free text can contain identifiers that cannot be established from a pattern scan alone. Retaining assessments and their outcomes is not a claim of formal statistical anonymization.

Run the focused command tests from the repository root:

```powershell
.\code-tests\pester.ps1 -TestGeneral $false -TestAssessments $false `
    -Include '*Report*.Tests.ps1' `
    -Output Detailed
```

Check the dashboard, visible pillar pages, device configuration, agent ownership lists, assessment filters and detail views in the generated HTML. Do not visit source customer links or upload the original input to external tools.

An external report shell captures its generated UX, not the missing source changes that produced it. For a subsequent UX refresh, use another matching HTML/JSON pair, or the repository template after the relevant frontend changes have landed. Updating the website copy does not itself deploy the website.
