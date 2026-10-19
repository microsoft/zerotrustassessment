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
- [PowerShell guidance](../.github/instructions/powershell-review.instructions.md)
  applies to module PowerShell, export JSON, Pester, and PowerShell build/scripts.
- [Assessment guidance](../.github/instructions/assessment-review.instructions.md)
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
