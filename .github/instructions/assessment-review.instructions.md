---
applyTo: "src/powershell/tests/**/*.ps1,src/powershell/tests/**/*.md,code-tests/test-assessments/**/*.ps1,src/powershell/classes/ZtTest.ps1,src/powershell/private/tests/**/*.ps1,src/powershell/private/tests-metadata/**/*.ps1,src/powershell/private/core/Add-ZtTestResultDetail.ps1"
excludeAgent: "cloud-agent"
---

# Assessment and result review

## Metadata and evaluation

- Keep `Test-Assessment.<id>.ps1`, its function/TestId, matching Markdown, and
  assessment Pester coverage consistent. Required metadata includes `Title`,
  `TenantType`, `ImplementationCost`, `RiskLevel`, and `UserImpact`; validate values
  against `ZtTest`. Structural code/Markdown gates do not prove behavior coverage.
- Use `CompatibleLicense` service-plan names, not deprecated `MinimumLicense` or
  product marketing names. Entries are OR alternatives; `&` inside an entry means
  AND. Declare required `Service` metadata so framework gating handles connections;
  do not duplicate framework service/license checks without a specific need.
- Preserve the separation of collection, assessment logic, and report generation.
  Use the existing result helpers and supported skip/custom-status values rather
  than inventing status strings or manually reconstructing framework results.
- A successfully established absence of applicable resources is not the same as
  a query/schema failure, expired authentication, insufficient permission, or a
  false security setting. Do not convert those failures to benign NotApplicable,
  an empty pass, or a tenant-control failure. Use the current framework error path
  or an explicitly supported outcome; 401 does not establish a missing directory role.
- Check both directions of the control: all/any, AND/OR, enabled/report-only/disabled,
  included/excluded scope, defaults, and empty values. Resource existence alone
  does not prove effective enforcement. Unknown enum values and failed sign-ins
  must not become positive security evidence; require the documented successful
  status and the correct subject/resource identity when the control depends on them.
- Check row-level and aggregate outcomes separately. Do not let unreadable rows
  erase confirmed failures or let a passing subset imply complete coverage.
  Preserve unknown evidence in the report and follow this control's rollup contract;
  do not impose a universal Fail/Investigate/Error precedence.
- Follow actual API/schema semantics when a specification and implementation share
  an error. Update affected queries, joins, evaluation, docs, and tests together;
  do not patch only the displayed explanation.

## Reports without changing the verdict

- Calculate compliance and summary counts over the complete applicable population.
  Unless the control explicitly defines a bounded sample, limit only displayed
  detail rows; a SQL LIMIT or early Select-Object before evaluation can hide failures.
  Check totals, passing/failing counts, and status agree.
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
  Do not add an API lookup solely to decorate every row with a name already available.
- Check `%TestResult%` replacement, table column alignment, nonduplicated summaries,
  and empty/error output paths. Do not leave a literal placeholder, fabricate "0
  resources" after collection failure, or disagree with the computed verdict.
- Pass structured results through `Add-ZtTestResultDetail`. Keep raw error/request
  objects, credentials, and unnecessary tenant payloads out of results and diagnostics;
  an intentionally scoped assessment report is not a public debug dump.

## Regression evidence

- New assessments and changed behavior need relevant tests under
  `code-tests/test-assessments/`. Cover applicable empty, single, all-pass, mixed,
  and all-fail cases, plus collection/permission failures and supported skips.
  Missing data is not automatically a pass or a skip; assert this control's contract.
- For report caps, test exactly at and beyond the cap, the omitted count and emitted
  text, and a noncompliant item beyond the first displayed/evaluated-looking page.
  Assert the full-population verdict as well as the bounded output.
- Test real query/result shapes and identifier kinds, not fixtures that accidentally
  make `appId` and object `id` identical or mock away the failing branch. An approval
  and resolved comments are not substitutes for these assertions.
