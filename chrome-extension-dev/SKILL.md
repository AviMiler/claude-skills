---
name: chrome-extension-dev
description: >
  Develops Chrome Extensions (Manifest V3) using vanilla JavaScript without
  build tools, package managers, or TypeScript. Use when the user wants to
  create a new Chrome extension, add features to an existing one, refactor
  extension code, or troubleshoot Chrome WebExtension API issues. Applies to
  requests involving manifest.json, service workers, content scripts, popup UI,
  message passing, storage, and chrome.* APIs.
---

# Chrome Extension Developer

## Core Constraints

**Never use:**
- NPM, package.json, node_modules
- Build tools (Webpack, Vite, esbuild)
- TypeScript
- External packages (lodash, axios, etc.)
- dist/ or build/ directories

**Always use:**
- Vanilla JavaScript only
- Manifest V3
- Files organized flat (no src/, no nested directories)
- Maximum 500 lines per file

## Project Structure

```
my-extension/
├── manifest.json
├── background.js       (service worker)
├── content.js          (page injection)
├── popup.html          (popup UI, if needed)
├── popup.js            (popup script, if needed)
└── icons/              (extension icons)
```

No package.json. No build step. Manifest + JS files → drag into Chrome → works.

## Critical Rules

### Manifest V3 specifics
- Service worker cannot access DOM, window, or document
- Storage: use `chrome.storage.local` only, never `localStorage`
- Content script runs isolated from page JS — use `window.postMessage` for cross-realm communication

### Preventing double-injection in content scripts
```js
if (window.__extLoaded) return;
window.__extLoaded = true;
```

### Message passing (background ↔ popup/content)
```js
// Send (popup.js, content.js)
chrome.runtime.sendMessage({ type: 'ACTION', data: payload }, response => {
  console.log(response);
});

// Listen (background.js)
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
  if (msg.type === 'ACTION') {
    // Do work
    sendResponse({ success: true });
  }
  return true; // Required if sendResponse is async
});
```

### File size & splitting
- If a file reaches 400+ lines, split by responsibility (UI separate from logic)
- Prefer one longer file with clear comments over multiple tiny files
- Add architecture note at top of main file:

```js
/**
 * ARCHITECTURE
 * background.js  — service worker, messaging hub, chrome.storage
 * content.js     — DOM injection, page interaction
 * popup.html/js  — UI for popup, sends messages to background
 *
 * DATA FLOW: popup → sendMessage → background → storage/tab action
 */
```

## System Permissions — Strictly Limited

⚠️ **This environment has very limited permissions.** Cannot:
- Install software or packages (no NPM, Homebrew, apt, choco, etc.)
- Run system commands that modify the computer
- Change system settings or registry
- Execute installers or setup files
- Access protected system directories

**This means all code must be:**
- **Self-contained** — no external dependencies, no build steps
- **Vanilla JavaScript** — runs directly in Chrome without compilation
- **Files only** — just manifest.json + .js files, drag into Chrome, done

If a task requires installation, compilation, or system changes, **stop and ask
the user** — it cannot be done in this environment.

## Setup Checklist

Before writing code:
1. Confirm extension purpose (what does it do?)
2. What tabs/pages does it affect?
3. Does it need popup UI? (Yes/No)
4. Does it need persistent storage? (Yes/No)

Write only the files that are actually needed.

**All code is self-contained — zero dependencies, zero build tools, zero setup.**
