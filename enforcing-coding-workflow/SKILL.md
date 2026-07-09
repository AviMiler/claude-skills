---
name: enforcing-coding-workflow
description: >
  Enforces a mandatory 4-stage sequence (validate, build, document, git) for
  every coding task in every project — new features, bug fixes, refactors.
  Applies whenever a request will result in code changes, before any code is
  written. Defines the stage order, what each stage must produce, and how to
  handle failures without skipping ahead. Complements MY-agentic-code (which
  defines what good code and docs look like) — the document stage follows
  its templates. Use when the user asks to build, add, implement, fix, or
  refactor code, regardless of language or platform.
---

# Coding Workflow

⚠️ Read First — also load `anthropic-skills:agentic-code` for the tracking-file templates and
code quality rules used in Stage 3.

## Core Rule

Every coding task goes through all 4 stages, in order, every time. Never jump
straight to code, skip documentation because a change "felt small," or skip
git because "the user will commit later" — unless the user explicitly says so
for this specific task.

```
1. VALIDATE  →  2. BUILD  →  3. DOCUMENT  →  4. GIT
```

If a stage fails, stop and resolve it before moving on — never skip forward
silently.

## When This Applies

Any request that changes code: features, bug fixes, refactors, config or
dependency changes — including ones that sound small ("rename this
variable," "fix this typo").

Does NOT apply to: pure Q&A, read-only code review, exploration, or
non-code tasks (standalone doc writing, etc.).

## The 4 Stages

### Stage 1 — Validate

Before writing code, check the request against the project's spec and
current state:
- If a spec file exists, read it and confirm the request doesn't conflict.
- If not, treat existing docs (README, AGENT_CONTEXT.md, ARCHITECTURE.md) as
  the de facto spec.
- Minor gaps → note them, proceed with a stated assumption.
- Serious conflicts (contradicts an architectural decision, breaks a stated
  constraint, duplicates existing functionality) → stop and ask the user.

State what will be built and any assumptions made before moving to Stage 2.

### Stage 2 — Build

- Follow the code quality rules from `anthropic-skills:agentic-code` (file size, naming,
  typing, error handling, no dead abstractions).
- Keep the change scoped to what Stage 1 validated — no drive-by refactors.
- Track every file created, modified, or deleted for Stage 3.

### Stage 3 — Document

Update the project's tracking files per `anthropic-skills:agentic-code`'s templates:

```
[ ] AGENT_CONTEXT.md — "Last Changes", "Current State", "Next Steps"
[ ] PROJECT_MAP.md   — any files added/removed/renamed
[ ] CHANGELOG.md     — one line per logical change with date
[ ] ARCHITECTURE.md  — if a pattern or decision changed
[ ] DEPENDENCIES.md  — if a package was added or removed
```

If these files don't exist yet, create them from `anthropic-skills:agentic-code`'s
templates rather than leaving the project without them. If time is short,
update `AGENT_CONTEXT.md` at minimum and say the rest is pending.

### Stage 4 — Git

- Check for `git-instructions.md` at the project root; if present, follow it
  exactly.
- If absent, ask the user for their git workflow (branching, commit message
  style, auto-push) and write `git-instructions.md` with the answer.
- Stage only the files touched by this task (code + Stage 3 docs) — never a
  blanket `git add -A`.
- Follow the system's destructive-action rules: never force-push, never skip
  hooks, confirm before pushing unless pre-authorized for this session.

## Failure Handling

- Stop the sequence at the failed stage.
- State clearly which stage failed and why.
- Ask the user: retry / adjust the plan / abort.
- Only the user can authorize skipping a stage for a specific task — never
  drop one by default to save time.
