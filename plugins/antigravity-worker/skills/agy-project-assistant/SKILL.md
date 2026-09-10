---
name: agy-project-assistant
description: Orchestrate Antigravity CLI (AGY) as an isolated Gemini 3.8 Flash implementation worker while Codex leads architecture, TDD, review, and final integration. Use for bounded coding tasks after design approval, or whenever the user explicitly asks for AGY/Antigravity.
---

# AGY Project Assistant

Use the globally available Antigravity MCP as an idle bridge. The user's durable local policy authorizes AGY for bounded implementation after design approval. For analysis-only work, do not call AGY unless the user explicitly requests it.

## Resolve the project

1. Use the current Codex project root as `project_root`.
2. If the current root is unavailable or ambiguous, ask for the exact directory.
3. Never substitute a parent directory, drive root, user home, or another saved project.

## Enable AGY on explicit request

1. Call `antigravity_project_status` with the exact project root.
2. If disabled, note that enabling AGY grants read access to that exact project and may send relevant content to the Google model.
3. Treat either an explicit AGY request or approved bounded implementation under the durable local policy as authorization for that exact read scope, then call `antigravity_enable_project`.
4. If the request only asks to load AGY and no active conversation exists, call `antigravity_start_session`.
5. If the request includes a substantive task, call the appropriate task tool directly; its conversation becomes active.

## Delegate work

- Use `antigravity_ask` for a new analysis conversation.
- Before a follow-up, use `antigravity_sync_conversation` when the user may have interacted through AGY CLI. `antigravity_continue` also synchronizes before and after its model call.
- Use `antigravity_continue` for follow-ups in the active conversation. Inspect `transcriptSync.before.records` for messages added through AGY CLI.
- Use `antigravity_review` for an independent correctness, regression, security, or test-gap review.
- Use `antigravity_execute` for implementation. It may modify only an isolated copy and must never merge automatically. For a follow-up on the same feature, pass the exact `conversation_id` returned by the previous run; omit it for a new or unrelated feature. Keep `verification: "none"` unless the user explicitly accepts execution of AGY-influenced code; only then set `allow_untrusted_verification: true` with a bounded verification timeout.
- Prefer AGY for bounded implementation work after Codex has approved the design and defined the acceptance criteria. Codex remains responsible for architecture, TDD direction, review, and final integration.
- Consolidate approved acceptance criteria before implementation. Default to one `antigravity_execute` call per feature, inspect failures before retrying, and let Codex safely integrate minor corrections after review instead of opening another implementation conversation.

After every model call, report the exact `project_root` and `conversation_id`. After implementation, also report `run_id`, isolated workspace path, changed files, and verification status. Verify AGY conclusions independently before applying anything to source.

## Inspect and resume

- Use `antigravity_get_active_session` to recover the active conversation in a new Codex task.
- Use `antigravity_list_sessions` for project delegation history.
- Use `antigravity_sync_conversation` to pull newly added visible AGY CLI messages without calling a model.
- Use `antigravity_get_transcript` when the user asks Codex to read or summarize the visible AGY conversation.
- Use `antigravity_list_runs` and `antigravity_get_run` for isolated implementation audits.
- Tell the user they can inspect a conversation with `agy --conversation=<conversation_id>`.

## Disable AGY

When the user asks to disable, unload, revoke, or stop AGY for the current project, call `antigravity_disable_project`. Preserve local session and run history.

## Safety rules

- Enable AGY only for approved bounded implementation or when the user explicitly requests it.
- Never grant a broader path than the exact current project root.
- Never add AGY write, command, URL, or MCP permissions.
- Never use dangerous auto-approval flags.
- Apply isolated changes to source only after Codex review. The durable local policy authorizes application within the already approved task scope without an additional per-tool or per-patch confirmation; ask the user if scope expands, a destructive action is needed, or a business/design decision is unresolved.
- Never enable non-`none` verification without explicit user risk acceptance. Verification commands execute code from the AGY-influenced isolated workspace and are not an OS sandbox.
- Never request, expose, reconstruct, or persist AGY private thinking or chain-of-thought. Use only visible messages, final answers, and sanitized tool traces.
- Transcript synchronization is on demand. Avoid concurrent sends from Codex and an interactive AGY CLI in the same conversation.

## Local lead/worker policy

The user has authorized this durable collaboration model:

- Codex is the lead, business analyst, solution architect, TDD owner, and final reviewer.
- AGY is the implementation worker for bounded coding and routine tasks after the design is approved.
- For every `antigravity_execute` call, always set `model: "gemini-3.8-flash-high"` and `verification: "none"`. Use `effort: "medium"` for routine bounded implementation. Reserve `effort: "high"` for complex architecture, security-sensitive work, or an explicit user request.
- Never omit the model parameter for implementation work. If Gemini 3.8 Flash High is unavailable, stop and report the failure; do not silently fall back to another model.
- Codex must define the objective, allowed files, forbidden files, acceptance criteria, and tests before delegation.
- AGY may modify only the isolated workspace created by `antigravity_execute`.
- Codex must inspect every changed file, verify UTF-8, and independently run the relevant project tests before applying changes to the source tree.
- Never merge or copy isolated changes into the source tree without Codex review.
- Reject AGY output that changes architecture, security, public APIs, or files outside the approved scope.
- For Odoo work, require current Odoo 19 syntax verified against the actual project source.
