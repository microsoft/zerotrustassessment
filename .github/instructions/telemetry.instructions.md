---
applyTo: "**"
authority: canonical
applies-to: pull-requests, ado-work-items
last-reviewed: 2026-08-04
owners: zerotrustassessment maintainers
---

# PR and ADO work-item telemetry tagging

Every pull request and related ADO work item must declare how the work was produced and
what kind of change it contains. These values are consumed by reporting pipelines.

## Pull-request labels

Apply one assistance label:

- `agentic-cli`
- `agentic-ide`
- `agentic-mixed`
- `manual`

Apply one change-type label:

- `bug`
- `hotfix`
- `feature`
- `refactor`
- `test`
- `docs`
- `security`
- `infra`
- `telemetry`
- `chore`

Agents must use an `agentic-*` value, never `manual`.

## Pull-request description

Append this block to every PR description:

```text
<!-- BEGIN pr-telemetry -->
assistance: <agentic-cli|agentic-ide|agentic-mixed|manual>
type: <bug|hotfix|feature|refactor|test|docs|security|infra|telemetry|chore>
agent-tool: <copilot-cli|copilot-chat|claude-cli|cursor|other|n/a>
agent-model: <model or n/a>
work-item: AB#<id or n/a>
<!-- END pr-telemetry -->
```

## ADO work items

Use the same assistance and change-type values in the work item's Tags field. Append:

```text
<!-- BEGIN wit-telemetry -->
assistance: <agentic-cli|agentic-ide|agentic-mixed|manual>
type: <bug|hotfix|feature|refactor|test|docs|security|infra|telemetry|chore>
agent-tool: <copilot-cli|copilot-chat|claude-cli|cursor|other|n/a>
agent-model: <model or n/a>
related-pr: <PR id or n/a>
<!-- END wit-telemetry -->
```

Never remove or downgrade telemetry labels, tags, or footer values added by a human or
prior agent.
