---
description: "Use when adding, fixing, or reviewing assessments and their metadata, licensing, result, or rollup contracts. Covers scaffold, evidence, verdicts, reports, and regression tests."
applyTo: "src/powershell/tests/**/*.ps1,src/powershell/tests/**/*.md,code-tests/test-assessments/**/*.ps1,src/powershell/classes/ZtTest.ps1,src/powershell/private/tests/**/*.ps1,src/powershell/private/tests-metadata/**/*.ps1,src/powershell/private/license/**/*.ps1,src/powershell/private/core/Add-ZtTestResultDetail.ps1,src/powershell/private/core/*-ZtTestData.ps1,src/powershell/private/core/Get-ZtTestResult*.ps1,src/powershell/private/tenantinfo/**/*.ps1"
---

# Assessment implementation and review

Scaffold/attribute rules apply to assessment implementations. Shared helpers,
licensing, runners, and tenant-info producers consume these contracts; they do not
become assessment functions or require their own ZtTest attributes.

## Authoring and metadata

- Keep `Test-Assessment.<id>.ps1`, its function/TestId, matching Markdown, and
  assessment Pester coverage consistent. Required metadata includes `Title`,
  `TenantType`, `ImplementationCost`, `RiskLevel`, and `UserImpact`; validate values
  against `ZtTest`. Structural code/Markdown gates do not prove behavior coverage.
- For additions, start from the current [scaffold](../../build/scaffold/readme.md)
  and templates, not an arbitrary legacy assessment. Keep helper `param(...)`
  blocks and helpers before collection; separate Data Collection, Assessment Logic,
  and Report Generation. Do not re-scaffold unrelated code during a focused fix.
- Use `CompatibleLicense` service-plan names, not deprecated `MinimumLicense` or
  product marketing names. Entries are OR alternatives; `&` inside an entry means
  AND. Declare required `Service` metadata so framework gating handles connections;
  do not duplicate framework service/license checks without a specific need.
  Consumption-based checks need not invent a license prerequisite. The retained
  exported result field `TestMinimumLicense` is not deprecated authoring metadata;
  do not rename output fields as a side effect of updating attributes.
- Use existing result helpers and supported skip/custom-status values, not invented
  strings or reconstructed framework results. Let ordinary results derive their
  TestId/Title from metadata; preserve intentional supported caller overrides.
  Keep assessments independent: reuse shared helpers, not another test's execution.

## Evidence and outcomes

- A successfully established absence of applicable resources is not the same as
  a query/schema failure, expired authentication, insufficient permission, or a
  false security setting. Do not convert those failures to benign NotApplicable,
  an empty pass, or a tenant-control failure. Use the current framework error path
  or an explicitly supported outcome; 401 does not establish a missing directory role.
- Check both directions of the control: all/any, AND/OR, enabled/report-only/disabled,
  included/excluded scope, defaults, and empty values. Resource existence alone
  does not prove effective enforcement or assignment. Interpret the actual API
  fields, nested settings, defaults, and successful states; unknown data must not
  become positive security evidence through an `else`, string search, or coercion.
- Preserve each query/entity's failure state separately from successful empty data.
  A fallback should run when its required primary evidence is absent, not merely
  when contextual rows are absent. Optional informational probes must not change
  the control verdict when its contract says they are nonfatal.
- Identify the control's authoritative quantifier and truth table, including empty,
  unknown, and not-applicable cases. Evaluate row evidence and aggregate outcomes
  separately. Preserve confirmed findings and unknown evidence without imposing
  universal status precedence: a witness may satisfy an existential check despite
  other errors, while a passing subset cannot prove a complete-scan requirement.
  Row-level Investigate does not automatically imply aggregate Investigate.
- Follow actual API/schema semantics when a specification and implementation share
  an error. Resolve conflicting requirements with the responsible owner, record
  accepted deviations/unmerged-spec dependencies, and update affected queries,
  evaluation, companion docs, and tests together. Do not standardize withdrawn
  malformed-response requirements or historical HTTP-to-status mappings.

## Report generation

- Evaluate the complete required population unless the control explicitly permits
  a bounded sample or decisive short circuit. Limit presentation separately: a SQL
  LIMIT or early Select-Object introduced only to cap a report can hide failures.
  Distinguish exact totals, lower bounds, distinct people, role rows, listed items,
  and actually evaluated items; make counts and verdicts agree.
- Check large-detail scalability against the assessment's report contract. Where
  a cap is appropriate, prioritize remediation rows, count actual rendered rows,
  and disclose truncation/omissions. Do not impose a universal cap or hide required
  decisive/unreadable evidence. StringBuilder alone does not bound output size.
- Prefer readable display-name links to the correct admin portal object rather
  than redundant raw-ID columns. Keep identifiers needed internally for joins and
  URLs; an explicit unresolved/deleted-object fallback may legitimately display an ID.
- Reuse `Get-SafeMarkdown`, `Get-FormattedDate`, and existing link/result helpers
  when suitable. Check dynamic values for their actual Markdown/HTML context;
  `Get-SafeMarkdown` escapes square brackets, not every table delimiter or HTML risk.
  Escape all relevant free-text branches appropriately, not just one identity format.
  Parse dates once and reuse safe values for evaluation and display.
  Do not add a lookup solely to decorate a row with an already available name.
- Use the connected cloud's API/portal host and verified object route. Preserve
  entity associations and required informational fields even when they do not
  affect compliance. Reuse evaluated row facts rather than independently assigning
  green indicators from object existence or aggregate counts.
- Check `%TestResult%` replacement, table column alignment, nonduplicated summaries,
  and empty/error output paths. Do not leave a literal placeholder, fabricate "0
  resources" after collection failure, or disagree with the computed verdict.
- Pass structured results through `Add-ZtTestResultDetail`. Keep raw error/request
  objects, credentials, and unnecessary tenant payloads out of results and diagnostics;
  an intentionally scoped assessment report is not a public debug dump.
- For shared dashboard data, carry child execution availability, actual verdicts,
  and distinct-ID populations through the producer and every renderer. Counts or
  chart widths do not replace verdicts. Follow the
  [report build contract](report.instructions.md) for affected generated bundles.

## Regression coverage

- New assessments and assessment behavior changes need relevant tests under
  `code-tests/test-assessments/`; use appropriate command tests for shared helper
  or runner behavior. Cover applicable empty, single, all-pass, mixed,
  and all-fail cases, plus collection/permission failures and supported skips.
  Missing data is not automatically a pass or a skip; assert this control's contract.
- For report caps, test exactly at and beyond the cap, the omitted count and emitted
  text, and a noncompliant item beyond the first displayed/evaluated-looking page.
  Assert the full-population verdict as well as the bounded output.
- Test real query/result shapes and identifier kinds, not fixtures that accidentally
  make `appId` and object `id` identical or mock away the failing branch. An approval
  and resolved comments are not substitutes for these assertions. For rollups,
  assert published status, counts, and evidence, not only a diagnostic flag or
  that a mocked dispatcher called a helper.
