---
name: MY-coding-workflow
description: >
  Enforces a mandatory 4-stage workflow (spec-validate → build → document → git)
  for EVERY coding task in EVERY project — new feature, bug fix, or refactor. Use
  this skill at the very start of any task that will result in code changes, before
  writing or editing a single line. This skill defines the sequence itself: what
  order things happen in, what each stage must produce, and how to handle failures
  without skipping ahead. It does not replace MY-agentic-code (which defines *what
  good code and docs look like*) — load that skill too, since the "document" stage
  of this workflow follows its templates. Trigger on any request to build, add,
  implement, fix, or refactor code, regardless of language or platform.
---

# Coding Workflow

⚠️ Read First — also load `MY-agentic-code` for the tracking-file templates and
code quality rules used in Stage 3 of this workflow.

## Core Rule

**Every coding task goes through all 4 stages, in order, every time.** Do not
jump straight to writing code. Do not skip documentation because the change
"felt small." Do not skip git because "the user will commit later" unless they
explicitly say so for this task.

```
1. VALIDATE  →  2. BUILD  →  3. DOCUMENT  →  4. GIT
```

This sequence must never break. If a stage fails, stop and resolve it before
moving to the next stage — do not silently skip forward.

## When This Applies

Any request that will change code: new features, bug fixes, refactors,
config changes, dependency changes. This includes requests that sound small
("just rename this variable," "fix this typo in a function").

It does NOT apply to: pure Q&A, code review with no edits, read-only
exploration, or explicitly non-code tasks (writing docs standalone, etc.).

## The 4 Stages

### Stage 1 — Validate

Before writing any code, check the request against the project's actual spec
and current state:
- Does a spec file exist for this project? If yes, read it and confirm the
  request doesn't conflict with it.
- If no spec file exists, use the project's existing code/docs (README,
  AGENT_CONTEXT.md, ARCHITECTURE.md) as the de facto spec.
- Minor gaps or ambiguity → note them, proceed with a stated assumption.
- Serious conflicts (the request contradicts an explicit architectural
  decision, breaks a stated constraint, or duplicates existing
  functionality) → **stop and ask the user** before writing code.

Output of this stage: a one-line confirmation of what will be built and any
assumptions made. Do not skip straight to Stage 2 silently — say what you
validated.

### Stage 2 — Build

Implement the change:
- Follow the code quality rules from `MY-agentic-code` (file size, naming,
  typing, error handling, no dead abstractions).
- Keep the change scoped to what was validated in Stage 1 — no drive-by
  refactors or speculative features.
- Track every file created, modified, or deleted — Stage 3 needs this list.

Output of this stage: the code change itself, plus a concrete list of
changed files.

### Stage 3 — Document

Immediately after the build, update the project's tracking files per
`MY-agentic-code`'s templates:

```
[ ] AGENT_CONTEXT.md — "Last Changes", "Current State", "Next Steps"
[ ] PROJECT_MAP.md   — any files added/removed/renamed
[ ] CHANGELOG.md     — one line per logical change with date
[ ] ARCHITECTURE.md  — if a pattern or decision changed
[ ] DEPENDENCIES.md  — if a package was added or removed
```

If these tracking files don't exist yet in the project, create them using
the templates in `MY-agentic-code` before or alongside this change — don't
leave the project without them.

This is not optional cleanup — the change is not done until this stage is
done. If time is genuinely short, update `AGENT_CONTEXT.md` at minimum and
say explicitly that the rest is pending.

### Stage 4 — Git

Commit (and push, if applicable) the change:
- Check for a `git-instructions.md` at the project root. If it exists,
  follow its workflow exactly.
- If it doesn't exist, ask the user what git workflow they want
  (branch-per-feature vs. direct-to-main, commit message style, whether to
  push automatically) and create `git-instructions.md` with their answer so
  future tasks don't need to ask again.
- Stage only the files actually touched by this task (code + the tracking
  files from Stage 3) — never a blanket `git add -A`.
- Follow the destructive-action and confirmation rules from the system
  instructions: never force-push, never skip hooks, confirm before pushing
  unless the user has pre-authorized it for this session.

## Failure Handling

If any stage fails or is blocked:
- **Stop the sequence.** Do not proceed to the next stage.
- State clearly which stage failed and why.
- Ask the user: retry this stage / adjust the plan / abort the task.
- Never silently drop a stage to "save time" — if the user explicitly says
  to skip a stage for this task ("don't worry about docs this time"), that's
  their call to make, not a default.

## Relationship to Sub-Agents

This workflow can be run either inline (in the current conversation) or by
delegating stages to the `spec-validator`, `builder`, `doc-agent`, and
`git-agent` sub-agents if they're available in the project — the sequence
and rules are the same either way. Prefer running inline for small/medium
tasks; delegate to sub-agents for large tasks where isolating each stage's
context is worth the overhead.
