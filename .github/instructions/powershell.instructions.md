---
description: "Use when implementing or reviewing PowerShell module commands, data access, build tooling, or Pester tests. Covers ZTA types, helpers, errors, lifecycle, and behavioral validation."
applyTo: "src/powershell/**/*.ps1,src/powershell/**/*.psm1,src/powershell/**/*.psd1,src/powershell/assets/**/*.json,code-tests/**/*.ps1,build/**/*.ps1,build/**/*.psm1,build/**/*.psd1,scripts/**/*.ps1,Update-ZtTestService.ps1,.github/skills/psf-support-package-analyzer/*.ps1"
---

# PowerShell implementation and review

## Commands, types, and output

- Preserve the manifest's supported host (currently PowerShell 7.6) and public
  parameter, default, alias, unit, pipeline, output-type, and help contracts.
  New public commands need complete comment-based help. In module public/private
  command files, keep one top-level command and unique command names; local nested
  helpers are not extra top-level commands. These structural rules do not turn
  build scripts or frontend build helpers into module commands.
- Check zero, one, and many results. Pipeline output can collapse to a scalar;
  use intentional collection cardinality and membership tests. `$null` belongs on
  the left of null comparisons; use `-contains`/`-in` for membership rather than
  accidental array truthiness. `@($null).Count` is 1, not 0. Do not remove or add
  array wrapping without checking the actual returned values and callers.
- Distinguish `$null`, empty collections, `DBNull`, false, zero, and absent
  properties. DuckDB structs/lists are not necessarily PowerShell property bags.
  Use the actual types and existing conversion helpers; do not coerce missing
  evidence into favorable numbers, dates, enums, or Boolean values. Preserve
  legitimate zero values and numeric range, including 64-bit counts.
- For score/percentage aggregation, distinguish unknown from measured zero,
  validate the input range and denominator, and round after weighting rather
  than rounding each source first. Apply the control's actual scoring contract.
- Check success-stream pollution: bare expressions, collection `.Add()` return
  values, and extra output inside expression blocks can change returned objects.
  Suppress unintended output at its source, not intended pipeline results.
  A final return cannot erase earlier output; methods already returning void do
  not need redundant suppression.
- Prefer existing helpers, splatting, and direct typed parsing over duplicated
  infrastructure or speculative fallback logic. Do not impose blanket quotation,
  backtick, StringBuilder, GUID-array, or formatter rules.
- Honor the module structural command bans and explicit exceptions in
  [FileIntegrity.Exceptions.ps1](../../code-tests/general/FileIntegrity.Exceptions.ps1),
  including the applicable output, WMI, dynamic-variable, expression, and console
  command checks. Preserve unattended behavior across the entire public workflow,
  including prompts, progress handling, and opening the final report.

## Requests and data

- Prefer exported database data for high-cardinality entities when the required
  properties and scope are actually exported. Filter/join/aggregate in SQL instead
  of materializing entire tables. Live Graph/ARM calls remain valid for missing
  data or endpoint-specific behavior; verify coverage before demanding conversion.
- Reuse `Invoke-ZtGraphRequest`, `Invoke-ZtGraphBatchRequest`,
  `Invoke-ZtAzureRequest`, and `Invoke-ZtAzureResourceGraphRequest` as appropriate.
  Fetch shared data once and batch necessary independent lookups. Preserve
  API version, connected-cloud routing, headers, response representation, paging,
  correlation, and per-member failure/retry behavior.
- Distinguish page size from a deliberate sample: `-Top` alone may still page all
  results. When paging is intentionally disabled, check the wrapper's returned
  envelope/collection contract and normalize its rows. Do not add redundant paging
  loops around helpers that already return an unwrapped complete collection.
- Validate batch completeness, actual success/failure argument shapes, and raw,
  matched, or plain output contracts when changing batching. Bound retries, respect
  dependency recovery/exhaustion, and avoid replaying completed work. Accepted
  deprecations or intentional behavior changes need explicit documentation/tests,
  not silent parameter disregard.
- Verify the meaning of identifiers at every join, lookup, and portal URL:
  application `appId`, application object `id`, service-principal object `id`,
  and resource IDs are not interchangeable. Check documented property semantics,
  not just a matching variable name or a specification that repeats the same error.
- For export/query optimizations, trace each selected/nested property to model
  JSON, DuckDB struct/list inference, SQL views, assessments, and tests. Preserve
  empty-input schemas, model-row removal, UNION column types/order, and required
  downstream fields. Inner joins/unnesting must not drop noncompliant empty rows.
- Independently exported snapshots can disagree. Preserve a missing joined object
  separately from a present object with a null property; do not hide unresolved
  identities with an inner join or label them compliant through `coalesce`.
  Compare normalized distinct ID sets, not just row counts. Avoid per-assessment
  export-statistics/runner plumbing when handling missing records suffices.

## Lifecycle and configuration

- Cache identity must include options that change the response. Preserve
  DisableCache, method restrictions, valid falsy/null/empty hits, expiry, and session
  reset according to the current helper and pinned PSFramework contract. Do not
  cache failed/incomplete results as successful data or mutate caller-owned headers.
- Use existing PSFramework configuration/session helpers. New shared state must be
  visible to the workers that consume it and cleared by the established reset path.
  Preserve service/remoting execution affinity and synchronous/parallel result parity.
- Dispose runspaces, PowerShell instances, controllers, database readers/connections,
  streams, jobs, and subscriptions in `finally` or equivalent cleanup, including
  pre-start failure, cancellation, and timeout. Preserve public timeout units and
  idle/wall-clock semantics; do not substitute historical workarounds for current
  dependency behavior.

## Errors and privacy

- Put `-ErrorAction Stop` on the command that can fail when its catch depends on
  terminating errors, not merely on a downstream `Select-Object`. Confirm the
  wrapper's status/error contract; non-2xx responses do not always throw.
- Prefer exception/error properties, HTTP status codes, and existing
  `Get-ZtHttpStatusCode`/retry helpers over locale-dependent message matching.
  Do not blanket-retry permanent errors or replay writes without a safe contract.
- Let the framework handle unexpected assessment collection errors, or use its
  explicit error/result path. Do not swallow errors into empty data, return a
  success-shaped fallback, or continue after a stop helper without checking whether
  it terminates. If logging locally, use `New-ZtSafeErrorRecord` and its safe message.
  Avoid raw service text in string throws: PowerShell can copy that text into
  `FullyQualifiedErrorId`. Use stable error IDs or preserve the original error;
  a raw ErrorRecord passed to PSFramework is not automatically sanitized.

## Behavioral validation

- Add focused Pester coverage of changed contracts: null/single/many outputs,
  actual object representations, error paths, pagination/batch boundaries, and
  cleanup where relevant. Exercise the real changed helper and observable output;
  a mock returning an idealized status or response can conceal the integration bug.
  [verify.ps1](../../scripts/verify.ps1) checks syntax/build configuration, not Pester.
- Keep Pester setup isolated. `function global:Name` (including
  `global:Write-PSFMessage`) must preserve session state. Direct declarations
  are not Pester `Mock` replacements and are not automatically restored; they can
  overwrite real commands or leak no-op fakes into later tests and the caller's session.
  Prefer Pester `Mock` or test-scoped fakes, and remove unused stubs. If global scope
  is necessary, save any pre-existing function and restore it in `AfterAll`; if none
  existed, remove only the function the fixture created. Do not delete caller-owned
  commands. Use `Get-Command -ListImported` for existence checks that must not autoload
  modules. Check isolation with and without a pre-existing function, including cleanup
  after a test failure; passing the isolated test alone does not prove session safety.
