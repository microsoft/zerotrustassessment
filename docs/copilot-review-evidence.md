# Evidence behind Copilot PR review instructions

The review guidance is based on PR discussions and adopted fixes, checked against
current PowerShell/PSFramework code, documentation, and tests. It targets GitHub's
built-in Copilot PR reviewer, not a custom coding-agent definition.

## Coverage and method

Research window: **June 1, 2025 through October 19, 2026 at 09:46:51 UTC**.
Comments qualify by their own creation/submission timestamp, not the PR's creation
date. Older discussion is retained as context when needed.

| Review corpus | Candidate PRs enumerated | PRs with in-scope records | Conversation | Inline | Submitted reviews | Total records | alexandair records |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| microsoft/zerotrustassessment | 1,038 | 824 | 378 | 3,400 | 2,881 | 6,659 | 1,295 |
| Supplementary review corpus | 23 | 16 | 6 | 98 | 86 | 190 | 76 |

Upstream coverage includes all accessible in-window PR comments. Supplementary coverage
includes all in-window comments on PRs with `alexandair` participation in any of
the three comment types. The 1,371 target-reviewer records span 335 upstream and
16 supplementary PRs. Review totals include empty formal reviews; not every record contains
an actionable suggestion.

Collection used paginated PR metadata/reviews/threads and repository-wide REST
conversation/inline-comment listings, not GitHub search as an exhaustive source.
All 6,849 scoped record identities are unique; all 3,498 inline records map to
review threads, including resolved/outdated threads. REST listings supplied all
thread replies, avoiding truncation of nested GraphQL comment connections.
Search was a cross-check: it found only 15 matching supplementary PRs, missing participation
visible through the full review/comment collection.

The analysis separates substantive human feedback, replies, editorial remarks,
automated findings, and empty approvals. Closed merged and closed-unmerged PRs
were evaluated chronologically. The main cohort requires `alexandair`'s affirmative
final LGTM; his formal APPROVED-only reviews are a separate supporting cohort.
Other reviewers' approvals do not confer membership. Conditional/deferred feedback,
revocations, subsequent objections, and commits after approval remain explicit
caveats rather than evidence of unconditional acceptance.
The equivalent phrase "it looks good to me now" on #658 is supporting context,
not counted as a literal-LGTM approval.

### Reviewer-specific outcome cohorts

| Outcome | Upstream | Supplementary PRs |
| --- | ---: | ---: |
| Final affirmative literal LGTM, no explicit outstanding qualification | 279 | 12 |
| Final affirmative literal LGTM with scoped deferral/qualification | 6 | 0 |
| Earlier LGTM, later head without alexandair reapproval | 5 | 0 |
| LGTM superseded by later substantive objection/review | 1 | 1 |
| LGTM followed by unresolved later findings | 1 | 1 |
| Explicitly revoked approval | 1 | 0 |
| Formal APPROVED without literal LGTM | 5 | 0 |
| Equivalent affirmative wording, not literal LGTM | 1 | 0 |
| Intent to approve, not a final approval | 1 | 0 |

The conservative final-affirmative cohort is **297 PRs: 285 upstream and 12 supplementary**,
including six qualified cases. The five formal-approved-only cases are supporting
evidence; one (#1312) is conditional. These are PR counts, not independent-change
counts. The remaining target-reviewer discussions and other authors' feedback
remain contextual evidence, not approvals.

"Final affirmative" describes the observed review chronology, **not assurance that
every concern was fixed or every final-head change was reviewed**. Qualified #776,
#1199, and #1466 include later commits; some older LGTMs are COMMENTED reviews or
conversation comments rather than formal APPROVED nodes. The five additional
head-advance cases are #906, #1229, #1240, #1331, and #1352. In #906 another reviewer,
not alexandair, approved the final head.

Comments were mapped to historical paths, replies, final patches, and review/commit
chronology. Narrow fixes used as rule evidence were checked individually.
Other concerns remain classified as context, superseded, unresolved, or
unverifiable when the available patch does not demonstrate their resolution.
Resolved-thread flags and approvals are not proof of a fix. Replacement PRs,
mirrored fixes, repeated comments, and the same assessment's later revisions are
not counted as independent implementations.

The scoped corpus contains 4,454 human-authored records (3,168 nonempty) and
2,395 automated records. An account's authorship establishes provenance, not how
the text was drafted; disclosed AI-assisted human comments were not represented
as proof of unaided human judgment.
The four analysis catalogs reconcile exactly to all 6,849 scoped records, with
no missing or duplicate identities; PR dispositions cover all 1,038 upstream
candidates and all 16 selected supplementary PRs.

## Adopted checks and their boundaries

Historical links below identify the feedback, not an instruction for Copilot to
follow external links during review. The actionable checks are included directly
in the instruction files. Supplementary feedback is summarized without identifying
its source repository or linking to it; the guidance remains self-contained.

| Check | Historical evidence | Current contract and boundary |
| --- | --- | --- |
| Reuse repository request wrappers | [alexandair on #907](https://github.com/microsoft/zerotrustassessment/pull/907#discussion_r2822131542), adopted in replacement #922 | [ARG wrapper](../src/powershell/public/Invoke-ZtAzureResourceGraphRequest.ps1). Prefer shared cloud routing/paging/error behavior over ad hoc REST; ARG is appropriate only when it contains the required resource/data. |
| Use exported data where it actually covers the control | [alexandair on #879](https://github.com/microsoft/zerotrustassessment/pull/879#issuecomment-3928534977); [API exception on #716](https://github.com/microsoft/zerotrustassessment/pull/716#discussion_r2646091304) | [Database query helper](../src/powershell/private/db/engine/Invoke-DatabaseQuery.ps1). Push large-table filtering/aggregation into SQL, but retain live API calls for unexported properties or different endpoint semantics. |
| Batch necessary lookups and hoist shared calls | [alexandair on #722](https://github.com/microsoft/zerotrustassessment/pull/722#discussion_r2657541051); [merill on #484](https://github.com/microsoft/zerotrustassessment/pull/484#discussion_r2386569622) | [Batch contracts/tests](../code-tests/commands/Invoke-ZtGraphBatchRequest.Tests.ps1). Preserve output representation, correlation, paging, headers, and member failures; do not introduce batching if the lookup can be eliminated. |
| Distinguish null/empty/DBNull and real returned types | [alexandair on #658](https://github.com/microsoft/zerotrustassessment/pull/658#discussion_r2589200866) | [Typed numeric checks](../src/powershell/tests/Test-Assessment.21858.ps1#L49-L66). The review's initial simplification was revised after reproduction. Neither `$null` checking nor array wrapping is a universal substitute for understanding the data. |
| Keep expression blocks and the success stream intentional | [alexandair on #760](https://github.com/microsoft/zerotrustassessment/pull/760#discussion_r2773006892) | [Report implementation](../src/powershell/tests/Test-Assessment.35022.ps1). A bare raw date plus a formatted date yields two values; method-return suppression must not remove intended command output. |
| Put terminating-error behavior on the actual producer | [alexandair on #770](https://github.com/microsoft/zerotrustassessment/pull/770#discussion_r2688302008) | [Framework invocation](../src/powershell/private/tests/Invoke-ZtTest.ps1#L101-L104). `-ErrorAction Stop` on `Select-Object` does not make the preceding cmdlet's error terminating. |
| Preserve cache identity and empty-result hits | [alexandair on #894](https://github.com/microsoft/zerotrustassessment/pull/894#pullrequestreview-3851167060); [alexandair on #890](https://github.com/microsoft/zerotrustassessment/pull/890#discussion_r2798329679) | [Graph cache](../src/powershell/private/core/Invoke-ZtGraphRequestCache.ps1#L77-L91), [Azure cache](../src/powershell/private/core/Invoke-ZtAzureRequestCache.ps1#L52-L71). Header-dependent results and a cached null need contract-aware handling. Current legacy behavior is not uniformly identical across helpers. |
| Use current license/service metadata | [gaelcolas on #1038](https://github.com/microsoft/zerotrustassessment/pull/1038#discussion_r2919910945) | [License contract](./license_checks.md), [framework gates](../src/powershell/private/tests/Invoke-ZtTests.ps1#L101-L119). `CompatibleLicense` entries use service-plan names, OR between entries and AND with `&`; `Service` drives connection gating. This is supporting policy evidence, not attribution to alexandair. |
| Match identifiers by meaning, not similar names | Reviewer identified a resource application ID incorrectly compared with a principal object ID. | [Correct resource-principal match](../src/powershell/tests/Test-Assessment.61011.ps1#L94-L123). Application IDs and principal object IDs remain distinct in queries, fixtures, joins, and URLs. |
| Require positive evidence for a positive security signal | Reviewer identified failed sign-ins and unknown subject types being accepted as positive evidence. | [Success checks](../src/powershell/tests/Test-Assessment.61011.ps1#L102-L137). Missing status is not success; excluding one agent subject does not prove a human subject. Avoid claiming synthetic fixtures prove a live tenant returns a particular combination. |
| Do not disguise collection failure as inapplicability | Reviewer rejected collection errors being converted to benign NotApplicable results. | [Current error path](../src/powershell/private/tests/Invoke-ZtTest.ps1#L170-L178), [empty-resource skip](../src/powershell/tests/Test-Assessment.61011.ps1#L62-L67). Use existing supported outcomes; do not invent a permission skip enum or turn 401/403 into evidence that no resources exist. |
| Sanitize diagnostics before logging/persisting | Reviewer identified raw error logging in redundant collection catches. | [Safe ErrorRecord](../src/powershell/private/tests/New-ZtSafeErrorRecord.ps1), [privacy tests](../code-tests/commands/ErrorSanitization.Tests.ps1). Removing the redundant catches let framework sanitization handle errors. PSFramework alone does not sanitize an arbitrary raw record. |
| Compute the full verdict, cap only report details | [alexandair on #1597](https://github.com/microsoft/zerotrustassessment/pull/1597#pullrequestreview-5538217793) | [Full counts and bounded rows](../src/powershell/tests/Test-Assessment.21801.ps1#L53-L94), [beyond-cap failure case](../code-tests/test-assessments/Test-Assessment.21801.Tests.ps1#L129-L155). A SQL LIMIT before evaluation can hide failures; StringBuilder does not cap output. Existing limits of 10 and 50 are assessment-specific, not universal policy. |
| Prefer actionable names/links without redundant raw-ID columns | Reviewer requested removing display-only ID columns while retaining actionable object links. | [Link rendering](../src/powershell/tests/Test-Assessment.61011.ps1#L197-L211). Retain IDs internally. [Deleted-group fallback](../src/powershell/private/graph/Get-ZtAssignmentText.ps1#L8-L31) is a legitimate exception; Get-SafeMarkdown is not a complete HTML/table sanitizer. |
| Preserve decisive and unreadable evidence in rollups | [alexandair on #1516](https://github.com/microsoft/zerotrustassessment/pull/1516#discussion_r3799100555), [row/aggregate distinction on #1507](https://github.com/microsoft/zerotrustassessment/pull/1507#discussion_r3860123298) | [Workspace rollup](../src/powershell/tests/Test-Assessment.41201.ps1). Confirmed failures and unreadable workspaces remain visible; the exact aggregate status is control-specific, not a universal ordering. |
| Keep thrown error IDs safe as well as messages | [alexandair on #1593](https://github.com/microsoft/zerotrustassessment/pull/1593#discussion_r4264960269) | [Stable ErrorRecord IDs](../src/powershell/tests/Test-Assessment.21818.ps1#L115-L145). Arbitrary string throws can copy raw service text into FullyQualifiedErrorId, which later survives message sanitization. |
| Preserve weighted precision and unknown-versus-zero semantics | Reviewer identified premature rounding and unavailable values being confused with measured zero. | [Overview calculation](../src/powershell/private/tenantinfo/Add-ZtOverviewCloudSecureScore.ps1). Weight unrounded values, round the aggregate, and validate available weight/input. Its upstream mirror is one lineage, not another independent example. |
| Isolate test fakes and inspect actual stored results | Reviewer observed test setup autoloading the real module and leaving fake commands in the session. | [Fixture lifecycle and result assertions](../code-tests/commands/Add-ZtOverviewCloudSecureScore.Tests.ps1#L1-L106). Use imported-command checks to avoid unintended autoload, clean fixture-created commands, and acknowledge query-text assertions do not execute KQL. |
| Do not leak or overwrite session-wide functions from Pester setup | Repeated review findings showed direct global fake declarations surviving passing tests, potentially replacing real commands; [upstream unused-stub example](https://github.com/microsoft/zerotrustassessment/pull/1186#discussion_r3145067020). | [Test-scoped logging fake](../code-tests/commands/Send-ZtAppInsightsTelemetry.Tests.ps1#L1-L10) and [fixture-owned cleanup](../code-tests/commands/Add-ZtOverviewCloudSecureScore.Tests.ps1#L1-L36). Direct `function global:Name` declarations are not automatically restored like Pester mocks. Prefer test scope; necessary globals must restore prior functions or remove only fixture-created ones in AfterAll. Check both pre-existing/absent-function cases and failure cleanup. Existing unsafe neighboring tests do not justify new occurrences or require unrelated suite rewrites. |
| Distinguish page size, bounded samples, and response envelopes | [alexandair on #1390](https://github.com/microsoft/zerotrustassessment/pull/1390#discussion_r3569392979), [later finding on #1396](https://github.com/microsoft/zerotrustassessment/pull/1396#discussion_r3571774413) | [Bounded alert requests and unwrapping](../src/powershell/tests/Test-Assessment.41121.ps1#L45-L115). `-Top` alone can still fetch every page; disabling paging changes the returned shape. The #1396 finding was post-merge, not proven fixed inside that PR. |
| Exercise the branch a regression test claims to cover | [alexandair on #1186](https://github.com/microsoft/zerotrustassessment/pull/1186#discussion_r3145061300) | [Pagination fixture](../code-tests/commands/Export-ZtGraphEntity.Tests.ps1#L95-L115). A mock without a nextLink cannot prove behavior on a later empty page. |
| Preserve snapshot mismatches rather than inventing empty populations | [alexandair on #1471](https://github.com/microsoft/zerotrustassessment/pull/1471#pullrequestreview-4840954916) | [Ownership snapshot join and failed-group handling](../src/powershell/private/tenantinfo/ai/Add-ZtAgentOwnershipDistribution.ps1#L16-L130). Track unmatched populations and unreadable lookups; do not classify them as confirmed ownerless/sponsorless identities. This supports data/status semantics, not every legacy logging choice in the file. |

Cross-cutting resource cleanup, hidden-content, workflow privilege, privacy, and
test requirements retain the repository's existing review policy. Examples include
[timeout cleanup](../src/powershell/private/tests/Invoke-ZtTest.ps1#L160-L166),
[session reset](../src/powershell/private/core/Clear-ZtModuleVariable.ps1),
[structural gates](../code-tests/general/FileIntegrity.Tests.ps1), and
[prebuilt report assets](../src/report/README.md#L43-L48).
They are not presented as newly discovered preferences of one reviewer.

## Lessons that were deliberately not made rules

- An earlier approval can be withdrawn without the API's original review state
  changing: [#1002's LGTM](https://github.com/microsoft/zerotrustassessment/pull/1002#pullrequestreview-3896216824)
  was followed by [explicit revocation](https://github.com/microsoft/zerotrustassessment/pull/1002#pullrequestreview-3898548569).
  It is not a clean final-LGTM success.
- [#850](https://github.com/microsoft/zerotrustassessment/pull/850#issuecomment-3850345349)
  expresses an intention to approve, not a final affirmative LGTM.
- [#848](https://github.com/microsoft/zerotrustassessment/pull/848#issuecomment-3844450037)
  explicitly defers a skip-reason correction. Qualified approvals remain qualified.
- [#1396](https://github.com/microsoft/zerotrustassessment/pull/1396#pullrequestreview-4686018719)
  received new correctness/privacy findings after merge. [#1223](https://github.com/microsoft/zerotrustassessment/pull/1223#pullrequestreview-4325172878)
  received another reviewer's change request after alexandair's earlier approval.
  Neither history proves final acceptance of the eventual implementation.
- [#1199](https://github.com/microsoft/zerotrustassessment/pull/1199#pullrequestreview-4230620719)
  defers related model work to #1200; [#1466](https://github.com/microsoft/zerotrustassessment/pull/1466#pullrequestreview-4826430966)
  expressly scopes away other spec findings. Aggregate final PR patches support
  selected changes, not the claim that every bundled concern was fixed.
- Historical recommendations disagree about blanket try/catch, redundant arrays,
  here-strings versus concatenation, and optional StringBuilder use. The guidance
  checks the real output/error contract rather than imposing those preferences.
- Report caps are not universally accepted: [#1505](https://github.com/microsoft/zerotrustassessment/pull/1505#discussion_r3817472216)
  and [#1523](https://github.com/microsoft/zerotrustassessment/pull/1523#discussion_r3817386489)
  removed global caps that hid required evidence, while #1597 required a display cap.
  The guidance therefore checks the control's evidence and scalability contract.
- [#1584's qualified approval](https://github.com/microsoft/zerotrustassessment/pull/1584#pullrequestreview-5506808792)
  explicitly deferred wrapper work. API-version, batch recovery/completeness, and
  representation fixes landed separately in #1591, #1590, and #1596; accepted
  deprecations must not be mistaken for broken promises to preserve retired options.
- Historical findings can disappear with the implementation they targeted: one reviewed
  resolver implementation was absent from its approved head, and another change
  removed intermediate HTTP 206 handling after a specification change. Neither
  intermediate mechanism was promoted into a mandatory rule.
- Editorial feedback about wording, sentence case, titles, locale, or emoji was
  recorded but not promoted. Existing exclusions for user-facing prose remain.
- Legacy `MinimumLicense`, raw error logging, and manual service checks still occur
  in source. Copying a nearby file is not evidence that those patterns are current
  policy. The instruction change does not repair unrelated implementations.

## Instruction surfaces and use

- [Repository-wide guidance](../.github/copilot-instructions.md) contains review
  scope, evidence standards, integration, cleanup, and privacy/security checks.
- [PowerShell guidance](../.github/instructions/powershell.instructions.md)
  applies to module PowerShell, export JSON, Pester, and PowerShell build/scripts.
- [Assessment guidance](../.github/instructions/assessments.instructions.md)
  applies to assessment code/docs/tests and the metadata/execution/result surfaces.
- The two scoped files use documented `applyTo` globs and
  `excludeAgent: "cloud-agent"` to target review rather than add a competing coding
  agent. Existing telemetry instructions are unchanged.

GitHub documents repository/path-specific support for its PR reviewer, with
instructions read from the **head branch**. Repository settings must allow custom
instructions; this work does not change that setting or request a live review.
No `.github/agents/*.agent.md`, new workflow, enforced overview format, or automatic
merge-blocking behavior is assumed.

Official references:
[supported surfaces](https://docs.github.com/en/copilot/reference/custom-instructions-support),
[configuration/frontmatter](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions),
and [effective review instructions and limitations](https://docs.github.com/en/copilot/tutorials/customize-code-review).
These are configuration references, not external rule dependencies for the reviewer.

## Validation and limitations

Historical regression replay used actual reviewed and final source revisions with
synthetic dependencies: 18 cases produced 36 expected revision observations across
three upstream PRs and one supplementary PR. Cases cover null/DBNull,
single/empty results, unwanted success-stream values, report boundaries, identifier
semantics, failed/missing sign-in status, unknown subjects, collection failure,
and legitimate empty-resource applicability.

This is a narrow behavior replay and manual rule-to-evidence check, **not a live
Copilot review, a held-out benchmark, or a measured precision/recall result**.
Synthetic Graph responses do not establish live server-side enum/filter behavior.
Some existing weak test assertions and unfulfilled automated test requests remained
even after LGTM; approval was not used as a blanket correctness guarantee.

The collection manifest, raw/normalized records, per-comment analysis, cohort ledger,
historical patch/revision evidence, and replay results are retained as session
research artifacts, not committed raw discussions. Deleted comments, earlier edited
text, pending reviews, and omitted API patch text cannot be fully reconstructed.
Current thread/review states are not a perfectly versioned historical snapshot.

Custom instructions are nondeterministic and do not replace Pester, tenant
validation, or human judgment. `scripts/verify.ps1` checks source syntax and build
configuration; it does not run Pester. Revisit the guidance when current contracts
change, and add future review rules only with concrete evidence and known exceptions.

## Merged-PR census: March through November 2026

This addendum is a separate research cohort, collected on **2026-11-09**.
It does not replace or combine the older cohort's counts, timestamp selection,
or synthetic-replay results above.

### Selection and completeness

The GitHub search was:

```text
repo:microsoft/zerotrustassessment is:pr is:merged merged:2026-03-01..2026-11-09
```

- Enumerated **381 distinct merged PRs** across eight paginated search responses.
  Selection is by merge date, not creation date or comment timestamp.
- Retrieved alexandair's available review history for every candidate, including
  later-superseded requests for changes. Checked review-dismissal events and their
  previous state; no dismissal events were returned.
- Selected **124 PRs** containing **174 CHANGES_REQUESTED reviews** by alexandair.
  Filtering only the latest review state would omit approved PRs in this cohort.
- Retrieved complete reviews, review threads, issue discussion, and changed-file
  lists for the selected PRs. Checked each connection's pagination, including
  comments within threads; no pages remained outstanding.
- The selected PRs contain **304 alexandair review records**, **409 inline comments**
  by alexandair, and **8 issue comments** by alexandair. Focused extracts retained
  every one of those records. Analysis included relevant replies and later reviews,
  even when their timestamp falls outside the merge-date window.
- Analyzed disjoint groups of 42, 41, and 41 PRs and checked their union against the
  full 124-PR selection. The index below includes every selected PR, not only
  #1541, #1524, #1523, and #1461 supplied as examples.

The query, raw API snapshots, pagination/coverage manifests, reviewer-focused
extracts, and full analyses are retained in the session workspace, not committed
as raw discussions. Deleted/edited historical text cannot be reconstructed from
the current API snapshot. A source link and recorded disposition do not prove
every proposed correction was implemented or remains current policy.

### Rule mapping

The concise instructions carry implementation contracts; this document carries
their provenance and qualifications. An index entry can support a general
principle without making its original proposed algorithm a rule.

| Area | Adopted context |
| --- | --- |
| Types | [PowerShell commands/types/output](../.github/instructions/powershell.instructions.md#commands-types-and-output): null/cardinality, membership, real driver types, numeric range, and output purity. |
| Data | [Requests and data](../.github/instructions/powershell.instructions.md#requests-and-data): wrappers, paging/batching, identifier meaning, SQL/export shape, and snapshot joins. |
| Lifecycle | [Lifecycle/configuration](../.github/instructions/powershell.instructions.md#lifecycle-and-configuration): shared state, cache presence/expiry, service affinity, units, and cleanup. |
| Errors | [Errors/privacy](../.github/instructions/powershell.instructions.md#errors-and-privacy): structured failure state, safe diagnostics/IDs, and bounded retries. |
| Metadata | [Assessment authoring](../.github/instructions/assessments.instructions.md#authoring-and-metadata): scaffold, parameters, services, license alternatives, and independent assessments. |
| Verdicts | [Evidence/outcomes](../.github/instructions/assessments.instructions.md#evidence-and-outcomes): control-specific quantifiers, row versus aggregate decisions, and unresolved evidence. |
| Reports | [Report generation](../.github/instructions/assessments.instructions.md#report-generation): required evidence, actual counts, safe formatting, portal links, and approved presentation bounds. |
| Tests | [Behavioral validation](../.github/instructions/powershell.instructions.md#behavioral-validation) and [assessment coverage](../.github/instructions/assessments.instructions.md#regression-coverage): reachable failures and observable outputs, not idealized mocks. |
| Report build | [Static report ownership](../.github/instructions/report.instructions.md): producer/consumer wiring and regenerated default/classic assets. |
| Review process | [Review evidence and scope](../.github/instructions/code-review.instructions.md#evidence-and-scope): later decisions, fixed/deferred/rejected distinctions, and demonstrated impact. |

### PR coverage index

Entries summarize the technical lesson and its limits, not an assertion that
every historical finding is still open. Editorial-only entries are retained for
coverage but do not become code-review gates.

| PR | Lesson and qualification | Feedback source |
| --- | --- | --- |
| [#938](https://github.com/microsoft/zerotrustassessment/pull/938) | Enforce actual SKU/scope, preserve required profiles and associated counts, and do not invent an omitted action's default. | [Review](https://github.com/microsoft/zerotrustassessment/pull/938#discussion_r2864627962) |
| [#948](https://github.com/microsoft/zerotrustassessment/pull/948) | Reuse Azure/ARG wrappers; recognize valid category groups and preserve all relevant setting names. | [Review](https://github.com/microsoft/zerotrustassessment/pull/948#discussion_r2854148022) |
| [#951](https://github.com/microsoft/zerotrustassessment/pull/951) | Unnesting empty arrays must not erase the very resources that should fail. The suggested KQL replacement is not a universal algorithm. | [Review](https://github.com/microsoft/zerotrustassessment/pull/951#discussion_r2860783770) |
| [#954](https://github.com/microsoft/zerotrustassessment/pull/954) | Retain Graph errors instead of evaluating an empty fallback; historical skip suggestions do not define every API failure's status. | [Review](https://github.com/microsoft/zerotrustassessment/pull/954#discussion_r2865568754) |
| [#959](https://github.com/microsoft/zerotrustassessment/pull/959) | Distinguish enabled, disabled-only, and absent rules in evidence. Narrower projections were optional optimization, not a correctness gate. | [Review](https://github.com/microsoft/zerotrustassessment/pull/959#discussion_r2865723030) |
| [#968](https://github.com/microsoft/zerotrustassessment/pull/968) | Failed TLS queries are not verified zero-rule results; applicability depends on the specified resource/SKU/attachment conditions. | [Review](https://github.com/microsoft/zerotrustassessment/pull/968#discussion_r2914018510) |
| [#969](https://github.com/microsoft/zerotrustassessment/pull/969) | A count of disabled JavaScript challenge rules must not display as successful protection. | [Review](https://github.com/microsoft/zerotrustassessment/pull/969#discussion_r2865883077) |
| [#970](https://github.com/microsoft/zerotrustassessment/pull/970) | Enabled-rule counts and textual status must agree with the evaluated configuration. | [Review](https://github.com/microsoft/zerotrustassessment/pull/970#discussion_r2865922916) |
| [#993](https://github.com/microsoft/zerotrustassessment/pull/993) | Check whether a framework stop actually ends caller execution; retain operational diagnostics rather than only console output. | [Review](https://github.com/microsoft/zerotrustassessment/pull/993#discussion_r2885312969) |
| [#1000](https://github.com/microsoft/zerotrustassessment/pull/1000) | Use normal PowerShell helper invocation and context-appropriate escaping; fixed enum strings do not need mechanical decoration. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1000#pullrequestreview-3912083900) |
| [#1003](https://github.com/microsoft/zerotrustassessment/pull/1003) | Similar application/service-principal properties are not interchangeable; preserve query failures and actionable object links. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1003#discussion_r2891753926) |
| [#1005](https://github.com/microsoft/zerotrustassessment/pull/1005) | Keep report predicates consistent with verdicts. Rule-state heuristics and a cardinality concern were superseded or disputed; do not standardize them. | [Spec-change reply](https://github.com/microsoft/zerotrustassessment/pull/1005#discussion_r2924200148) |
| [#1009](https://github.com/microsoft/zerotrustassessment/pull/1009) | Hoist invariant work and capture errors. The absent-certificate Pass was defended as specified, not settled as a general defect. | [Qualification](https://github.com/microsoft/zerotrustassessment/pull/1009#discussion_r2896634786) |
| [#1010](https://github.com/microsoft/zerotrustassessment/pull/1010) | Let result helpers derive ordinary TestId/Title metadata; use supported skip-and-return behavior. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1010#discussion_r2895626354) |
| [#1012](https://github.com/microsoft/zerotrustassessment/pull/1012) | Remove a proven unnecessary fallback in this implementation, not every fallback in the project. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1012#pullrequestreview-3925046869) |
| [#1035](https://github.com/microsoft/zerotrustassessment/pull/1035) | Prefer suitable exported device data and existing formatting; early returns must not leak report placeholders. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1035#pullrequestreview-3933060309) |
| [#1047](https://github.com/microsoft/zerotrustassessment/pull/1047) | Use intentional null comparisons and retained endpoint errors. Unused expansion removal was nonblocking. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1047#discussion_r2941126425) |
| [#1053](https://github.com/microsoft/zerotrustassessment/pull/1053) | Verify `enabledState` and inherited defaults; the proposed override inference still could not prove complete coverage. | [Qualification](https://github.com/microsoft/zerotrustassessment/pull/1053#discussion_r2937546759) |
| [#1064](https://github.com/microsoft/zerotrustassessment/pull/1064) | Ordinary malformed-request 400s are not blanket-retryable transient errors. Author confirmation is not a later review approval. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1064#discussion_r2942361894) |
| [#1076](https://github.com/microsoft/zerotrustassessment/pull/1076) | Check output against the current contract; the per-loop initialization suggestion was explicitly not a present functional bug. | [Qualification](https://github.com/microsoft/zerotrustassessment/pull/1076#discussion_r2955974947) |
| [#1083](https://github.com/microsoft/zerotrustassessment/pull/1083) | Remove unused Graph expansions/selections after checking both evaluation and reporting consumers. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1083#discussion_r2962662656) |
| [#1084](https://github.com/microsoft/zerotrustassessment/pull/1084) | A recipient collection needs collection/null semantics, not string emptiness checks; an earlier approval did not cover later feedback. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1084#discussion_r3110655586) |
| [#1098](https://github.com/microsoft/zerotrustassessment/pull/1098) | Test actual principal/table variants. Later maintainer direction favored export-model correction over a runtime JSON workaround. | [Later direction](https://github.com/microsoft/zerotrustassessment/pull/1098#issuecomment-4115890760) |
| [#1112](https://github.com/microsoft/zerotrustassessment/pull/1112) | Declare actual services and reuse evaluated predicates for reports. Unresolved thread flags plus approval do not prove implementation completeness. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1112#discussion_r3019651518) |
| [#1127](https://github.com/microsoft/zerotrustassessment/pull/1127) | Trace separate Connect/Invoke workflows and acknowledged session choices; JSON config could not bypass a gate running before config loading. | [Qualification](https://github.com/microsoft/zerotrustassessment/pull/1127#discussion_r3055423744) |
| [#1141](https://github.com/microsoft/zerotrustassessment/pull/1141) | Editorial-only duplicated explanation; no durable technical implementation rule was established. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1141#discussion_r3058904699) |
| [#1164](https://github.com/microsoft/zerotrustassessment/pull/1164) | Reuse declared dependencies, Graph wrappers, exported users, nested membership resolution, and batched SQL enrichment. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1164#discussion_r3177089380) |
| [#1165](https://github.com/microsoft/zerotrustassessment/pull/1165) | Validate authentication parameter combinations, connected-cloud/session state, shared lookups, and PFX cleanup. Some permission/module suggestions remained unverified. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1165#discussion_r3145505239) |
| [#1174](https://github.com/microsoft/zerotrustassessment/pull/1174) | Distinguish collection null/emptiness from string emptiness; null and an empty collection are not automatically equivalent. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1174#discussion_r3110647588) |
| [#1182](https://github.com/microsoft/zerotrustassessment/pull/1182) | Transitive membership, thresholds, and performance concerns were explicitly deferred. Record disposition instead of treating resolved threads as fixes. | [Disposition](https://github.com/microsoft/zerotrustassessment/pull/1182#issuecomment-4364558715) |
| [#1185](https://github.com/microsoft/zerotrustassessment/pull/1185) | Use the wrapper's projection contract and focused deleted-object coverage; this is not permission to suppress all 404s. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1185#discussion_r3130039594) |
| [#1186](https://github.com/microsoft/zerotrustassessment/pull/1186) | Pagination fixtures must actually reach the next-page branch; test null separately from an empty collection. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1186#discussion_r3145061300) |
| [#1190](https://github.com/microsoft/zerotrustassessment/pull/1190) | Express collection membership directly rather than relying on pipeline truthiness; a separately raised inherited omission was follow-up work. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1190#discussion_r3145212369) |
| [#1191](https://github.com/microsoft/zerotrustassessment/pull/1191) | Push applicable filtering into SQL and validate parameters; ordinary ValidateSet does not canonicalize case-sensitive SQL values. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1191#discussion_r3193813094) |
| [#1197](https://github.com/microsoft/zerotrustassessment/pull/1197) | Normalize risk values, preserve explicit metadata overrides, and build functional links. Preview/helper suggestions evolved or were rebutted. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1197#discussion_r3184162853) |
| [#1208](https://github.com/microsoft/zerotrustassessment/pull/1208) | Apply compound predicates to the same assignment item; PIM-for-Groups semantics were disputed and cannot be copied from role schedules. | [Qualification](https://github.com/microsoft/zerotrustassessment/pull/1208#discussion_r3387079283) |
| [#1211](https://github.com/microsoft/zerotrustassessment/pull/1211) | Deduplicate principals before counting/calling APIs; verify the full resistant-authentication predicate and required Database parameter. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1211#discussion_r3329916946) |
| [#1215](https://github.com/microsoft/zerotrustassessment/pull/1215) | Identify console failures structurally, not by localized text, and trace every unattended prompt/report-launch side effect. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1215#discussion_r3236944358) |
| [#1216](https://github.com/microsoft/zerotrustassessment/pull/1216) | Schedule by real service/remoting affinity, not an entire pillar; keep changed public parameter help accurate. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1216#discussion_r3236844672) |
| [#1219](https://github.com/microsoft/zerotrustassessment/pull/1219) | Build shared views once after dependencies load and avoid unnecessary per-entity requests when supported expansion covers the data. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1219#pullrequestreview-4308693020) |
| [#1225](https://github.com/microsoft/zerotrustassessment/pull/1225) | Preserve the actual query error and supported framework error path; Investigate was not the chosen mapping in this case. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1225#discussion_r3268561335) |
| [#1227](https://github.com/microsoft/zerotrustassessment/pull/1227) | Use current license metadata, helper parameter blocks, and scaffold placement, not arbitrary new regions or late helper definitions. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1227#discussion_r3276796091) |
| [#1229](https://github.com/microsoft/zerotrustassessment/pull/1229) | Missing agent data and feature non-support are different tenant conditions; a licensing suggestion was later qualified for consumption-based checks. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1229#discussion_r3284758979) |
| [#1234](https://github.com/microsoft/zerotrustassessment/pull/1234) | Use intentional multi-pillar membership. Declared attribute types do not prove AST extraction normalizes scalar inputs. | [Qualification](https://github.com/microsoft/zerotrustassessment/pull/1234#discussion_r3296712393) |
| [#1239](https://github.com/microsoft/zerotrustassessment/pull/1239) | Denied pricing reads are not proven bad configuration; consumption-based checks need not invent CompatibleLicense gates. | [Qualification](https://github.com/microsoft/zerotrustassessment/pull/1239#discussion_r3322074032) |
| [#1240](https://github.com/microsoft/zerotrustassessment/pull/1240) | Reconcile central scope resolution, required API version, and actual licensing; an illustrative skip name is not an established result API. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1240#discussion_r3304393724) |
| [#1245](https://github.com/microsoft/zerotrustassessment/pull/1245) | Preserve actual error representation; historical message-word fallbacks are not a mandate to replace modern structured status helpers. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1245#discussion_r3329974317) |
| [#1263](https://github.com/microsoft/zerotrustassessment/pull/1263) | Enforce actual subscription scope and error distinctions; avoid body-level connection checks already handled by Service metadata. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1263#discussion_r3344792669) |
| [#1265](https://github.com/microsoft/zerotrustassessment/pull/1265) | Partial query failures must not become empty lookups that falsely label agents unauthenticated; initialize values on every reachable path. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1265#discussion_r3362071110) |
| [#1268](https://github.com/microsoft/zerotrustassessment/pull/1268) | Use framework license gating and independent shared discovery, not dependency on another assessment's execution. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1268#discussion_r3376619173) |
| [#1276](https://github.com/microsoft/zerotrustassessment/pull/1276) | Filtering parent subscriptions does not constrain an independently queried workspace set; preserve scope through downstream collection. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1276#discussion_r3354811123) |
| [#1277](https://github.com/microsoft/zerotrustassessment/pull/1277) | Name the actual helper failure rather than assume permission denial; cross-assessment alignment was acknowledged future work. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1277#discussion_r3388101510) |
| [#1280](https://github.com/microsoft/zerotrustassessment/pull/1280) | Unexpected null discovery data is unavailable evidence, not automatically inapplicability; report the correct resource surface. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1280#discussion_r3370051003) |
| [#1296](https://github.com/microsoft/zerotrustassessment/pull/1296) | Shared discovery does not mean another assessment must run first. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1296#discussion_r3387646852) |
| [#1300](https://github.com/microsoft/zerotrustassessment/pull/1300) | Prefer actionable policy-name links when a reliable object route exists; a later review qualified header-link alternatives. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1300#pullrequestreview-4497554053) |
| [#1302](https://github.com/microsoft/zerotrustassessment/pull/1302) | Remove unused retrieval. A proposed broad error mapping and numeric-cast objection were questions, not established blanket rules. | [Qualification](https://github.com/microsoft/zerotrustassessment/pull/1302#discussion_r3439142044) |
| [#1309](https://github.com/microsoft/zerotrustassessment/pull/1309) | A failed policy detail read is Unknown, not zero approver groups; use object links only when reliable. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1309#discussion_r3414005487) |
| [#1315](https://github.com/microsoft/zerotrustassessment/pull/1315) | Verify actual DuckDB/nested-setting representation and terminating live-call handling; conditional driver concerns require real-shape tests. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1315#discussion_r3419347754) |
| [#1317](https://github.com/microsoft/zerotrustassessment/pull/1317) | Preserve timeout units, cache presence/falsy values, callback output, shared result shape, and cleanup. Version-specific upstream workarounds are not permanent rules. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1317#discussion_r3573949269) |
| [#1329](https://github.com/microsoft/zerotrustassessment/pull/1329) | Eligibility schedules differ from instances and can expire by duration; verify prerequisite licensing and use the status helper. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1329#discussion_r3480652943) |
| [#1341](https://github.com/microsoft/zerotrustassessment/pull/1341) | Use one intentional assignment source and describe the actual failing operation, not a policies API when data came from SQL. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1341#discussion_r3459033378) |
| [#1342](https://github.com/microsoft/zerotrustassessment/pull/1342) | Obtain owner clarification of existential versus universal aggregation; this control accepted any qualifying workspace. | [Decision](https://github.com/microsoft/zerotrustassessment/pull/1342#discussion_r3479141136) |
| [#1345](https://github.com/microsoft/zerotrustassessment/pull/1345) | One-off alias-attribute ordering preference; no demonstrated functional invalidity or universal review gate. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1345#discussion_r3468649731) |
| [#1351](https://github.com/microsoft/zerotrustassessment/pull/1351) | Check actual sensor enum coverage and the per-domain quantifier; pooled inventory counts do not prove every domain covered. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1351#pullrequestreview-4574557094) |
| [#1352](https://github.com/microsoft/zerotrustassessment/pull/1352) | Parse structured error codes and distinguish provisioning from access failure. A historical unparseable-403 fallback conflicts with later guidance. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1352#discussion_r3475421075) |
| [#1353](https://github.com/microsoft/zerotrustassessment/pull/1353) | Hoist a proven invariant mapping out of row loops; do not mandate that exact mapping everywhere. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1353#discussion_r3475223102) |
| [#1356](https://github.com/microsoft/zerotrustassessment/pull/1356) | Remove unreachable failure handling and verify actual license semantics. Timestamp/service enhancements were qualified, not unequivocal defects. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1356#discussion_r3500242011) |
| [#1361](https://github.com/microsoft/zerotrustassessment/pull/1361) | Preserve service/remoting execution affinity and partition once; the omitted-service question did not establish its answer. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1361#discussion_r3494553222) |
| [#1364](https://github.com/microsoft/zerotrustassessment/pull/1364) | Latest-snapshot Top 1 still paged; choose paging intentionally and preserve the returned shape. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1364#discussion_r3497944278) |
| [#1368](https://github.com/microsoft/zerotrustassessment/pull/1368) | Reuse helpers independently. Enabled-subscription filtering here was a qualified consistency recommendation, not a clear spec violation. | [Qualification](https://github.com/microsoft/zerotrustassessment/pull/1368#pullrequestreview-4646918651) |
| [#1369](https://github.com/microsoft/zerotrustassessment/pull/1369) | Keep required informational report fields even when they do not affect verdicts; reuse evaluated policy status and placeholders. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1369#discussion_r3513470324) |
| [#1370](https://github.com/microsoft/zerotrustassessment/pull/1370) | Markdown cleanup must preserve code spans/identifiers, recheck content after stripping, and test every introduced transformation. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1370#discussion_r3589859909) |
| [#1379](https://github.com/microsoft/zerotrustassessment/pull/1379) | Declare required Service metadata and disclose unmerged-spec dependencies rather than silently treating draft requirements as settled. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1379#discussion_r3514831001) |
| [#1383](https://github.com/microsoft/zerotrustassessment/pull/1383) | Protect all free-text table branches and contexts, not only one UPN representation; the existing helper is not a universal sanitizer. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1383#discussion_r3514454248) |
| [#1385](https://github.com/microsoft/zerotrustassessment/pull/1385) | Verify actual license meanings when code and spec repeat the same questionable value; do not make a historical identifier universal. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1385#discussion_r3521227983) |
| [#1386](https://github.com/microsoft/zerotrustassessment/pull/1386) | Remove initialization only when every path demonstrably overwrites it before use; no general ban on defensive initialization. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1386#discussion_r3530018474) |
| [#1387](https://github.com/microsoft/zerotrustassessment/pull/1387) | A bounded sample needs a valid total/truncation contract; Investigate still needs safe diagnostics. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1387#discussion_r3560083835) |
| [#1389](https://github.com/microsoft/zerotrustassessment/pull/1389) | Null numeric comparisons cannot prove compliance; initial skip/query-flow requests were qualified by later owner decisions. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1389#discussion_r3577983666) |
| [#1390](https://github.com/microsoft/zerotrustassessment/pull/1390) | Disabling paging changed the output envelope and caused no rows to be evaluated; test shape as well as requested switches. UI requirements were separately waived. | [Follow-up review](https://github.com/microsoft/zerotrustassessment/pull/1390#pullrequestreview-4685708536) |
| [#1392](https://github.com/microsoft/zerotrustassessment/pull/1392) | Unparseable 403s do not prove non-onboarding; preserve missing timestamps and full-precision ordering. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1392#discussion_r3554264313) |
| [#1397](https://github.com/microsoft/zerotrustassessment/pull/1397) | Check required values/default scope and returned structured permissions; the earlier rendered-text workaround was later replaced by direct property access. | [Later correction](https://github.com/microsoft/zerotrustassessment/pull/1397#discussion_r3658598969) |
| [#1398](https://github.com/microsoft/zerotrustassessment/pull/1398) | Assess effective rules, exclusions, and policy precedence. The duplicate-rule scenario was rebutted using the actual one-to-one relationship. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1398#issuecomment-4957730354) |
| [#1405](https://github.com/microsoft/zerotrustassessment/pull/1405) | Unknown workspaces cannot be omitted from a universal requirement; supported clouds also need correct portal hosts. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1405#discussion_r3594599220) |
| [#1407](https://github.com/microsoft/zerotrustassessment/pull/1407) | A missing required default policy and null threshold do not establish compliance; associated-rule display was a qualified completeness suggestion. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1407#discussion_r3603671988) |
| [#1413](https://github.com/microsoft/zerotrustassessment/pull/1413) | Unknown health enum values must not silently become out-of-scope and manufacture complete coverage. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1413#discussion_r3603325351) |
| [#1414](https://github.com/microsoft/zerotrustassessment/pull/1414) | Full-inventory checks must not disable paging; intentional bounded reads still need correct envelope normalization. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1414#discussion_r3603216287) |
| [#1415](https://github.com/microsoft/zerotrustassessment/pull/1415) | Required counts must distinguish verified zero from unavailable data, including after an initial output fix. | [Later correction](https://github.com/microsoft/zerotrustassessment/pull/1415#pullrequestreview-4724268977) |
| [#1425](https://github.com/microsoft/zerotrustassessment/pull/1425) | Show the endpoint actually queried in each cloud, preserve 64-bit counts, and verify role guidance. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1425#discussion_r3621246119) |
| [#1431](https://github.com/microsoft/zerotrustassessment/pull/1431) | Preserve each setting's category/destination relationship; independent aggregates can imply a false routing association. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1431#discussion_r3631836367) |
| [#1436](https://github.com/microsoft/zerotrustassessment/pull/1436) | Separate prerequisites from the entitlement being assessed; preserve error state, placeholders, and required empty-state evidence. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1436#discussion_r3631369022) |
| [#1442](https://github.com/microsoft/zerotrustassessment/pull/1442) | Several rollup/UI requests were disputed or removed in updated specs; skipped-child exclusion and removed UI sections are not blanket requirements. | [Discussion](https://github.com/microsoft/zerotrustassessment/pull/1442#discussion_r3655161169) |
| [#1445](https://github.com/microsoft/zerotrustassessment/pull/1445) | Complete-scan onboarding errors must not disappear behind another workspace's Pass; publish enabled flags only after successful interpretation. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1445#discussion_r3655361061) |
| [#1448](https://github.com/microsoft/zerotrustassessment/pull/1448) | Preserve required report columns even when query scope fixes their value; array wrapping here was a clarity suggestion, not a proven defect. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1448#discussion_r3658757259) |
| [#1454](https://github.com/microsoft/zerotrustassessment/pull/1454) | Test the real upstream error format, not a mocked status parser that bypasses the broken integration. A release-specific deferral is not permanent policy. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1454#discussion_r3675178241) |
| [#1457](https://github.com/microsoft/zerotrustassessment/pull/1457) | Null/cardinality changed scheduling and bypassed timeouts; do not add unused partial dependency infrastructure for a dashboard-only feature. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1457#pullrequestreview-4858069594) |
| [#1461](https://github.com/microsoft/zerotrustassessment/pull/1461) | Opaque/non-audit data does not prove enforcement. Keep assignment/mode availability separate and verify functional portal routes. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1461#discussion_r3675337580) |
| [#1470](https://github.com/microsoft/zerotrustassessment/pull/1470) | Match documented special 404 cases precisely and validate all relevant metrics where required, not just the first item. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1470#discussion_r3756080457) |
| [#1471](https://github.com/microsoft/zerotrustassessment/pull/1471) | Snapshot mismatches are not empty owners; failed/missing group responses are not zero members. Assert complete published distributions. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1471#pullrequestreview-4840954916) |
| [#1476](https://github.com/microsoft/zerotrustassessment/pull/1476) | Carry child availability, verdicts, and distinct-ID populations through PowerShell, TypeScript, rendered UI, and rebuilt bundles; widths do not replace status. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1476#discussion_r3705346331) |
| [#1481](https://github.com/microsoft/zerotrustassessment/pull/1481) | Do not invent stricter nullable-field prerequisites; table population must match the specified predicate. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1481#discussion_r3715962114) |
| [#1484](https://github.com/microsoft/zerotrustassessment/pull/1484) | This existential hunting control has authoritative Pass evidence even when another workspace is unreadable; no error-always-wins rule. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1484#discussion_r3750716332) |
| [#1487](https://github.com/microsoft/zerotrustassessment/pull/1487) | Inspect actual strength semantics and every OR alternative; unresolved optional data must not hide an independently conclusive failure. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1487#discussion_r3751749352) |
| [#1488](https://github.com/microsoft/zerotrustassessment/pull/1488) | Preserve required error-evidence rows and use expandable strings for generated links to the correct route. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1488#discussion_r3740938627) |
| [#1489](https://github.com/microsoft/zerotrustassessment/pull/1489) | Authorization failure means inability to assess, not proof of non-applicability; follow this control's supported outcome. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1489#discussion_r3740897390) |
| [#1492](https://github.com/microsoft/zerotrustassessment/pull/1492) | Both original requests were resolved through API/spec correction: NoExpiration is an input switch; all-query failure is exempted from tables. | [Decision](https://github.com/microsoft/zerotrustassessment/pull/1492#discussion_r3763540806) |
| [#1494](https://github.com/microsoft/zerotrustassessment/pull/1494) | Parse dates once and retain existential Pass precedence. The early 395-day proposal was later qualified/reversed for unusable completion dates. | [Later correction](https://github.com/microsoft/zerotrustassessment/pull/1494#discussion_r3850639319) |
| [#1495](https://github.com/microsoft/zerotrustassessment/pull/1495) | Non-Microsoft does not prove customer authorship; unresolved identity and incomplete workspace coverage need explicit evidence. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1495#discussion_r3760444639) |
| [#1504](https://github.com/microsoft/zerotrustassessment/pull/1504) | Follow this control's precedence and preserve pinned-profile evidence without claiming every listed control was evaluated. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1504#discussion_r3794237147) |
| [#1505](https://github.com/microsoft/zerotrustassessment/pull/1505) | Unknown storage plans cannot pass through an else branch; global row caps must not remove contractually required per-table evidence. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1505#discussion_r3817462304) |
| [#1507](https://github.com/microsoft/zerotrustassessment/pull/1507) | Separate optional reachability warnings, route-level evidence, and aggregate verdicts; row Investigate did not authorize aggregate Investigate here. | [Later correction](https://github.com/microsoft/zerotrustassessment/pull/1507#discussion_r3869329772) |
| [#1508](https://github.com/microsoft/zerotrustassessment/pull/1508) | Filter before unnecessary expansion; absence of the assessed baseline can fail. The extra-permission request was rebutted for the actual endpoint/app-only contract. | [Decision](https://github.com/microsoft/zerotrustassessment/pull/1508#discussion_r3780824242) |
| [#1516](https://github.com/microsoft/zerotrustassessment/pull/1516) | A conclusive failure of an every-workspace requirement outranks uncertainty; show unresolved scopes and reuse existing pagination. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1516#discussion_r3799100555) |
| [#1523](https://github.com/microsoft/zerotrustassessment/pull/1523) | A tenant GUID fallback is not resolved publisher identity. Fallback/output lessons survive, but skip/malformed-response requirements changed during review. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1523#discussion_r3831711502) |
| [#1524](https://github.com/microsoft/zerotrustassessment/pull/1524) | Cloud-aware portal hosts are durable. Malformed-onboarding and retention-invariant requests were closed after their spec requirements were removed. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1524#discussion_r3832264223) |
| [#1527](https://github.com/microsoft/zerotrustassessment/pull/1527) | Scope uncertainty to records it can affect; cap flattened rendered rows, not their parent workspaces; populate every required column. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1527#discussion_r3824618071) |
| [#1528](https://github.com/microsoft/zerotrustassessment/pull/1528) | Base fallback on missing primary evidence, accumulate per-policy errors before rollup, and retain details. Some subtype/exact-match concerns were forward-looking warnings. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1528#discussion_r3831975371) |
| [#1532](https://github.com/microsoft/zerotrustassessment/pull/1532) | Parse eligibility dates safely; field-specific contracts matter: a successfully read non-Enabled workflow state is Fail in this control. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1532#discussion_r3872872771) |
| [#1541](https://github.com/microsoft/zerotrustassessment/pull/1541) | Preserve each independent query's error state; a request failure and successful empty result need different safe diagnostics. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1541#discussion_r3902601344) |
| [#1572](https://github.com/microsoft/zerotrustassessment/pull/1572) | Missing joined users cannot become cloud-only through coalesce; count distinct users separately from role rows. Later direction rejected export-statistics runner plumbing. | [Maintainer decision](https://github.com/microsoft/zerotrustassessment/pull/1572#discussion_r4255986212) |
| [#1584](https://github.com/microsoft/zerotrustassessment/pull/1584) | Trace initial/continuation output, transport, retries, and fixtures. Deprecations were accepted and other issues deferred; approval explicitly did not mean all fixed. | [Disposition](https://github.com/microsoft/zerotrustassessment/pull/1584#pullrequestreview-5506808792) |
| [#1590](https://github.com/microsoft/zerotrustassessment/pull/1590) | Recovery must preserve dependent requests across retriable failures and terminate after exhaustion without replaying successes or returning empty success. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1590#discussion_r4275648494) |
| [#1592](https://github.com/microsoft/zerotrustassessment/pull/1592) | Preserve confirmed findings alongside failed lookups, real matched-failure arguments, and honest lower bounds; existing helper debt was not a new blocker. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1592#discussion_r4264627549) |
| [#1593](https://github.com/microsoft/zerotrustassessment/pull/1593) | Raw string throws can leak through FullyQualifiedErrorId despite message sanitization; test the complete safe-record/report path. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1593#discussion_r4264960269) |
| [#1597](https://github.com/microsoft/zerotrustassessment/pull/1597) | Evaluate required population before presentation limits; test a noncompliant record beyond the cap. StringBuilder and copied legacy output do not establish a bound. | [Review](https://github.com/microsoft/zerotrustassessment/pull/1597#pullrequestreview-5538217793) |

### Boundaries on adopting historical feedback

- **Verdict precedence is control-specific.** Compare the existential Pass in
  [#1484](https://github.com/microsoft/zerotrustassessment/pull/1484#discussion_r3750716332)
  with complete-scan uncertainty in
  [#1445](https://github.com/microsoft/zerotrustassessment/pull/1445#discussion_r3655361061)
  and universal failure in
  [#1516](https://github.com/microsoft/zerotrustassessment/pull/1516#discussion_r3799100555).
  Row status, aggregate status, display ordering, and optional warnings are different contracts.
- **Withdrawn assumptions stay withdrawn.** In
  [#1524](https://github.com/microsoft/zerotrustassessment/pull/1524#discussion_r3841572972)
  and [#1523](https://github.com/microsoft/zerotrustassessment/pull/1523#discussion_r3846207734),
  malformed-response requirements were removed; they do not justify exhaustive
  validation rules for every successful response.
  [#1492](https://github.com/microsoft/zerotrustassessment/pull/1492#discussion_r3763540806)
  corrected an assumed API output representation.
- **Verify the actual endpoint and owner decision.** The extra permission proposed in
  [#1508](https://github.com/microsoft/zerotrustassessment/pull/1508#discussion_r3780824242)
  was rebutted for the expanded list request and app-only mode.
  [#1572](https://github.com/microsoft/zerotrustassessment/pull/1572#discussion_r4255986212)
  rejected broad export-statistics plumbing for the assessment fix.
- **Approval does not erase debt or establish later review.**
  [#1584's explicit disposition](https://github.com/microsoft/zerotrustassessment/pull/1584#pullrequestreview-5506808792)
  distinguishes accepted deprecations, a separately merged prerequisite, fixed
  fixtures, and deferred helper work. Do not repeat all of them as new blockers or
  claim they were all fixed by approval.
- **Do not codify taste or a historical workaround as a gate.** Alias ordering,
  particular caps/emoji mappings, redundant casts, loop initialization, and
  version-specific cache behavior need their own current evidence. Preserve
  actual public compatibility and executable rules instead.

### Instruction delivery

The implementation contracts now apply to both cloud coding and code review;
review-only process guidance retains `excludeAgent: "cloud-agent"`. Separate
[report](../.github/instructions/report.instructions.md) and
[workshop](../.github/instructions/workshop-docs.instructions.md) instructions
describe architecture/build ownership without inventing a React coding standard.
The [contributor conventions](conventions.md) distinguish source-based Pester,
the parser gate, packaging side effects, and compatible-CI limitations.

Platform support was checked against GitHub's current
[repository-instruction documentation](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions),
[support matrix](https://docs.github.com/en/copilot/reference/custom-instructions-support),
and [review customization guidance](https://docs.github.com/en/copilot/tutorials/customize-code-review).
Use focused, self-contained files and correct path matching rather than relying on
unsupported review formatting instructions, external-link traversal, or old
fixed-size/base-branch assumptions. These instructions remain guidance, not a
replacement for executable regression tests or an observed cloud-session trial.
