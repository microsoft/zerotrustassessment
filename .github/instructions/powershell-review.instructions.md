---
applyTo: "src/powershell/**/*.ps1,src/powershell/**/*.psm1,src/powershell/**/*.psd1,src/powershell/assets/**/*.json,code-tests/**/*.ps1,build/**/*.ps1,scripts/**/*.ps1"
excludeAgent: "cloud-agent"
---

# PowerShell and data-contract review

## Commands, types, and output

- Preserve the manifest's PowerShell 7 minimum and existing public parameter,
  pipeline, output-type, and help contracts. New public commands need complete
  comment-based help. Follow one top-level command per public/private command file
  and unique command names; local nested helpers are not extra top-level commands.
- Check zero, one, and many results. Pipeline output can collapse to a scalar;
  `@($items).Count` is appropriate when collection cardinality matters. Do not
  remove array wrapping without checking callers, or add it indiscriminately.
- Distinguish `$null`, empty collections, `DBNull`, false, zero, and absent
  properties. A database value is not necessarily a comparable number or date.
  Use the actual returned types and existing conversion helpers; do not invent
  values that make missing/invalid evidence look successful.
- For score/percentage aggregation, distinguish unknown from measured zero,
  validate the input range and denominator, and round after weighting rather
  than rounding each source first. Apply the control's actual scoring contract.
- Check success-stream pollution: bare expressions, collection `.Add()` return
  values, and extra output inside expression blocks can change returned objects.
  Suppress unintended output, not the command's intended pipeline results.
- Prefer existing helpers, splatting, and direct typed parsing over duplicated
  infrastructure or speculative fallback logic. Do not impose blanket quotation,
  backtick, StringBuilder, GUID-array, or formatter rules.
- Honor the structural command bans and explicit exceptions in
  `code-tests/general/FileIntegrity.Exceptions.ps1`: unnecessary `Write-Output`,
  WMI cmdlets, `Get-EventLog`, dynamic-variable cmdlets, `Invoke-Expression`,
  `Clear-Host`, and `Set-Location`. Guard interactive actions such as `Invoke-Item`.

## Collection and integration

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
  envelope and inspect its `value` rows rather than counting the envelope itself.
- Verify the meaning of identifiers at every join, lookup, and portal URL:
  application `appId`, application object `id`, service-principal object `id`,
  and resource IDs are not interchangeable. Check documented property semantics,
  not just a matching variable name or a specification that repeats the same error.
- For export/query optimizations, trace each selected/nested property to model
  JSON, DuckDB struct/list inference, SQL views, assessments, and tests. Preserve
  empty-input schemas, model-row removal, UNION column types/order, and required
  downstream fields. Inner joins/unnesting must not drop noncompliant empty rows.
- Cache identity must include options that change the response. Preserve
  DisableCache, method restrictions, null/empty cache hits, and session cleanup
  according to the helper's contract. Do not cache failed or incomplete results
  as successful data or mutate caller-owned headers while preparing a request.

## Errors and behavior tests

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
  `FullyQualifiedErrorId`. Use stable error IDs or preserve the original error.
- Require focused Pester coverage of changed contracts: null/single/many outputs,
  actual object representations, error paths, pagination/batch boundaries, and
  cleanup where relevant. `scripts/verify.ps1` checks syntax/build configuration;
  it does not execute Pester.
- Flag new or changed Pester setup that declares `function global:Name` (including
  `global:Write-PSFMessage`) without preserving session state. Direct declarations
  are not Pester `Mock` replacements and are not automatically restored; they can
  overwrite real commands or leak no-op fakes into later tests and the caller's session.
  Prefer Pester `Mock` or test-scoped fakes, and remove unused stubs. If global scope
  is necessary, save any pre-existing function and restore it in `AfterAll`; if none
  existed, remove only the function the fixture created. Do not delete caller-owned
  commands. Use `Get-Command -ListImported` for existence checks that must not autoload
  modules. Check isolation with and without a pre-existing function, including cleanup
  after a test failure; passing the isolated test alone does not prove session safety.
