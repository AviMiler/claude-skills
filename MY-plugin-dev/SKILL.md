---
name: MY-plugin-dev
description: >
  Fullstack plugin/extension developer specializing in Chrome Extensions (Manifest V3)
  and VS Code Extensions. Use this skill whenever the user wants to: build a Chrome or
  VS Code extension from scratch, add features to an existing extension, refactor
  extension code, set up a plugin project structure, or work on any browser/editor
  extension task. Also trigger for any request involving content scripts, background
  service workers, popup UI, message passing, WebExtension API, VS Code Extension API,
  vscode commands, providers, or webview panels.
---

# Plugin Developer Skill

## ⚠️ Read First — Agentic Code Standards

**Before writing any code**, read and apply the `MY-agentic-code` skill.
It defines the mandatory tracking files, code quality rules, and documentation
standards that apply to ALL development work in this project.

> Load skill: `MY-agentic-code`

---

## Scope of This Skill

This skill covers only plugin/extension-specific knowledge:
- Project structure for Chrome and VS Code extensions
- Platform-specific APIs and patterns
- Build setup and packaging

Everything else (tracking files, naming, comments, error handling) is in `MY-agentic-code`.

---

## Confirm Scope First

Before scaffolding, confirm:
1. Chrome extension, VS Code extension, or both?
2. Does it need a UI? (popup, sidebar, webview panel)
3. Target: new project or existing?

---

## Project Structure

### Chrome Extension (Manifest V3)

```
my-extension/
├── manifest.json
├── src/
│   ├── background/
│   │   └── index.js          # Service worker entry point
│   ├── content/
│   │   └── index.js          # Content script entry point
│   ├── popup/
│   │   ├── index.html
│   │   ├── popup.js
│   │   └── popup.css
│   └── shared/
│       ├── messages.js       # All message definitions
│       ├── storage.js        # All chrome.storage access
│       └── constants.js
├── public/icons/
├── dist/                     # Build output (gitignored)
├── AGENT_CONTEXT.md
├── PROJECT_MAP.md
├── ARCHITECTURE.md
├── CHANGELOG.md
├── DEPENDENCIES.md
└── package.json
```

### VS Code Extension

```
my-vscode-extension/
├── package.json              # Extension manifest
├── src/
│   ├── extension.js          # activate() / deactivate()
│   ├── commands/
│   │   └── [commandName].js  # One file per command
│   ├── providers/
│   │   └── [providerName].js # TreeDataProvider, CodeLensProvider, etc.
│   ├── webview/
│   │   └── [panelName].js
│   └── shared/
│       ├── config.js         # Workspace configuration access
│       ├── logger.js         # Output channel wrapper
│       └── constants.js
├── dist/                     # Compiled output (gitignored)
├── AGENT_CONTEXT.md
├── PROJECT_MAP.md
├── ARCHITECTURE.md
├── CHANGELOG.md
├── DEPENDENCIES.md
└── .vscodeignore
```

---

## Chrome Extension Patterns

For full Chrome MV3 reference:
→ Read `references/chrome-extension.md`

**Key rules:**
- Always use Manifest V3 (not V2)
- Service worker has no DOM — never assume `window` or `document`
- Use `chrome.storage.local` (not `localStorage`) for all persistence
- All cross-context communication through messages in `shared/messages.js`
- Content scripts run in isolated world — use `window.postMessage` to reach page JS
- Guard content scripts against double-injection

---

## VS Code Extension Patterns

For full VS Code API reference:
→ Read `references/vscode-extension.md`

**Key rules:**
- Every `Disposable` returned by VS Code APIs must be pushed to `context.subscriptions`
- One file per command in `src/commands/`
- All config access through `shared/config.js` wrapper — never call `getConfiguration()` directly in feature code
- All logging through `shared/logger.js` — one Output Channel for the whole extension
- Webview content must use `getNonce()` and strict CSP
- `activationEvents: []` in package.json lets VS Code auto-detect — prefer this

---

## Plugin-Specific ARCHITECTURE.md Addition

When writing `ARCHITECTURE.md` for a plugin project, include this section:

```markdown
## Extension Architecture

### Context Boundaries
| Context | Has DOM | Has chrome.* | Can message |
|---|---|---|---|
| Background (service worker) | ❌ | ✅ full | → content, popup |
| Content script | ✅ (host page) | ✅ limited | → background |
| Popup | ✅ | ✅ limited | → background |

### Message Flow
[e.g., User clicks popup → popup sends GET_DATA → background reads storage → returns DATA_RESPONSE]
```
