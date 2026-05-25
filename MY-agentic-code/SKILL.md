---
name: MY-agentic-code
description: >
  Enforces agent-ready code architecture for any software development project.
  Use this skill at the start of EVERY development task — whether building from scratch,
  adding a feature, or modifying existing code. This skill defines the mandatory tracking
  files, code quality rules, and documentation standards that make a codebase easy for
  AI agents (and humans) to enter, understand, and modify quickly. Any skill that involves
  writing or editing code should reference this skill first. Trigger whenever a dev task
  begins, regardless of language, framework, or platform.
---

# Agentic Code

## Core Goal

A new AI agent (or human) should be able to open this project and be productive
within 60 seconds — without asking questions.

Everything in this skill serves that goal.

---

## Mandatory Tracking Files

These files MUST exist in every project. They MUST be updated as part of every
code change — not after, not separately. Updating them IS the change.

| File | Purpose |
|---|---|
| `AGENT_CONTEXT.md` | Primary entry point — what the project is, what changed, what's next |
| `PROJECT_MAP.md` | Full file tree with one-line description per file |
| `ARCHITECTURE.md` | Decisions, patterns, data flow |
| `CHANGELOG.md` | Every change with date and reason |
| `DEPENDENCIES.md` | Every dependency with reason for choosing it |

### After Every Code Change — Mandatory Checklist

```
[ ] AGENT_CONTEXT.md — update "Last Changes", "Current State", "Next Steps"
[ ] PROJECT_MAP.md   — add/remove/rename any files that changed
[ ] CHANGELOG.md     — one line per logical change with date
[ ] ARCHITECTURE.md  — if a pattern or decision changed
[ ] DEPENDENCIES.md  — if a package was added or removed
```

If time is short: update `AGENT_CONTEXT.md` at minimum. The others can follow,
but AGENT_CONTEXT.md must always reflect the current state.

---

## AGENT_CONTEXT.md — Template

```markdown
# Agent Context
_Last updated: [DATE] after [WHAT CHANGED]_

## What This Project Is
[One paragraph. What does it do, for whom, and why.]

## Current State
- ✅ Working: [complete and stable features]
- 🚧 WIP: [in progress]
- ❌ Known Issues: [bugs or broken things]

## Last Changes
- [DATE] — [what changed, in which files, and why]

## Entry Points
- [e.g., `src/index.ts` — main entry]
- [e.g., `src/background/index.ts` — service worker]

## Key Patterns Used
- [e.g., "All storage access goes through src/shared/storage.ts"]
- [e.g., "Messages are typed in src/shared/messages.ts"]

## Next Steps
- [ ] [Known task 1]
- [ ] [Known task 2]

## Gotchas / Watch Out
- [Non-obvious constraints]
- [Things that will break if you don't know them]
```

---

## PROJECT_MAP.md — Template

```markdown
# Project Map
_Last updated: [DATE]_

## File Tree
\`\`\`
[output of: find . -type f | grep -v node_modules | grep -v dist | grep -v .git | sort]
\`\`\`

## File Descriptions
| File | Description |
|---|---|
| `src/index.ts` | Entry point. Does X. |
| `src/shared/messages.ts` | All typed message definitions. |
| ... | ... |
```

---

## ARCHITECTURE.md — Template

```markdown
# Architecture
_Last updated: [DATE]_

## Overview
[One paragraph describing the system.]

## Data Flow
[Numbered list or diagram: user action → component → result]

## Key Decisions
| Decision | Why |
|---|---|
| [choice made] | [reason] |

## Patterns
- [Pattern name]: [where it lives and what it does]
```

---

## CHANGELOG.md — Template

```markdown
# Changelog

## [DATE]
- Added: [what and why]
- Changed: [what and why]
- Fixed: [what and why]
```

---

## DEPENDENCIES.md — Template

```markdown
# Dependencies

| Package | Version | Why |
|---|---|---|
| `typescript` | `^5.3` | Type safety across the project |
| `vite` | `^5.0` | Fast builds and HMR |
| ... | ... | ... |
```

---

## Code Quality Rules

### File Size
- Max ~150 lines per file
- If approaching this limit: split by responsibility
- Exception: generated files, config files

### Naming
- Files: `kebab-case.ts`
- Functions/variables: `camelCase`
- Types/interfaces: `PascalCase`
- Constants: `SCREAMING_SNAKE_CASE`
- No abbreviations — `handleMessageFromContentScript` not `handleMsg`

### TypeScript
- Always type all function signatures — no implicit `any`
- Use discriminated unions for messages or events passed across boundaries
- Never use `any` across module or context boundaries

### Comments
- Comment **why**, not **what**
- Every exported function/class gets JSDoc with `@param`, `@returns`, `@example`
- Use `// TODO(context): description` — always include enough context for a cold agent

### Error Handling
- Never silently swallow errors
- Always log with context: `console.error('[ComponentName] what failed:', error)`
- Errors must surface — either thrown, logged, or shown to the user

### Explicitness Over Magic
- No implicit behavior — all data flow must be traceable by reading, not running
- No global mutable state
- Side effects must be obvious from the call site

---

## New Project Setup — Order of Operations

1. Create the 5 tracking files with initial content (before any feature code)
2. Define the folder structure and add it to `PROJECT_MAP.md`
3. Write the entry point with a comment explaining what it wires up
4. Build features one at a time, updating tracking files with each one

Writing tracking files first forces clarity before code.

---

## Entering an Existing Project

1. Read `AGENT_CONTEXT.md` first — if missing, create it by scanning the project
2. Run file tree scan to understand structure
3. Read entry points (`package.json`, `manifest.json`, `*.csproj`, etc.)
4. Update any stale tracking files before making changes
