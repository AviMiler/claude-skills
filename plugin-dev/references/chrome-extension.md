# Chrome Extension Reference (Manifest V3)

## manifest.json Structure

```json
{
  "manifest_version": 3,
  "name": "My Extension",
  "version": "1.0.0",
  "description": "...",
  "permissions": ["storage", "activeTab"],
  "host_permissions": ["https://*.example.com/*"],
  "background": {
    "service_worker": "dist/background.js",
    "type": "module"
  },
  "content_scripts": [
    {
      "matches": ["https://*.example.com/*"],
      "js": ["dist/content.js"],
      "run_at": "document_idle"
    }
  ],
  "action": {
    "default_popup": "popup/index.html",
    "default_icon": { "16": "icons/16.png", "48": "icons/48.png" }
  },
  "icons": { "16": "icons/16.png", "48": "icons/48.png", "128": "icons/128.png" }
}
```

## Message Passing Patterns

### Typed Message Bus (always use this pattern)

```typescript
// src/shared/messages.ts
export type ExtensionMessage =
  | { type: 'GET_TAB_INFO' }
  | { type: 'TAB_INFO_RESPONSE'; payload: { url: string; title: string } }
  | { type: 'SAVE_DATA'; payload: { key: string; value: unknown } };

/**
 * Send a message to the background service worker.
 * @param message - Typed message object
 * @returns Promise resolving to the response
 */
export async function sendToBackground<T>(message: ExtensionMessage): Promise<T> {
  return chrome.runtime.sendMessage(message);
}

/**
 * Send a message to the active tab's content script.
 * @param tabId - Target tab ID
 * @param message - Typed message object
 */
export async function sendToContent<T>(tabId: number, message: ExtensionMessage): Promise<T> {
  return chrome.tabs.sendMessage(tabId, message);
}
```

### Background — Receiving Messages

```typescript
// src/background/index.ts
import { ExtensionMessage } from '../shared/messages';

chrome.runtime.onMessage.addListener(
  (message: ExtensionMessage, sender, sendResponse) => {
    // Must return true if sendResponse will be called asynchronously
    handleMessage(message, sender).then(sendResponse);
    return true;
  }
);

async function handleMessage(
  message: ExtensionMessage,
  sender: chrome.runtime.MessageSender
): Promise<unknown> {
  switch (message.type) {
    case 'GET_TAB_INFO': {
      const tab = await chrome.tabs.get(sender.tab!.id!);
      return { url: tab.url, title: tab.title };
    }
    default:
      console.error('[Background] Unhandled message type:', message.type);
      return null;
  }
}
```

## Storage Wrapper Pattern

```typescript
// src/shared/storage.ts

// Define all storage keys in one place — never use magic strings
const STORAGE_KEYS = {
  USER_SETTINGS: 'user_settings',
  LAST_SYNC: 'last_sync',
} as const;

export interface UserSettings {
  theme: 'light' | 'dark';
  autoSync: boolean;
}

/**
 * Get user settings from chrome.storage.local.
 * Returns default settings if none are saved.
 */
export async function getUserSettings(): Promise<UserSettings> {
  const result = await chrome.storage.local.get(STORAGE_KEYS.USER_SETTINGS);
  return result[STORAGE_KEYS.USER_SETTINGS] ?? { theme: 'light', autoSync: false };
}

/**
 * Save user settings to chrome.storage.local.
 */
export async function saveUserSettings(settings: UserSettings): Promise<void> {
  await chrome.storage.local.set({ [STORAGE_KEYS.USER_SETTINGS]: settings });
}
```

## Content Script Rules

- Cannot use `chrome.tabs` API — must message background instead
- Has access to `window` and `document` of the host page
- Runs in isolated world by default (cannot access page's JS variables)
- To communicate with page JS: use `window.postMessage` / `window.addEventListener('message')`

```typescript
// src/content/index.ts

// Guard against double-injection
if (!(window as any).__MY_EXTENSION_LOADED__) {
  (window as any).__MY_EXTENSION_LOADED__ = true;
  init();
}

function init() {
  // Listen for messages from background
  chrome.runtime.onMessage.addListener((message, _sender, sendResponse) => {
    // handle messages...
    return true;
  });
}
```

## Service Worker Constraints

The background script is a service worker — it:
- Has **no DOM** — no `window`, no `document`, no `localStorage`
- May be **terminated at any time** — never store state in variables between events
- Use `chrome.storage` for all persistence
- Wakes up on events (messages, alarms, etc.)

```typescript
// WRONG — state lost when service worker sleeps
let cachedData: string | null = null;

// RIGHT — always read from storage
async function getCachedData(): Promise<string | null> {
  const result = await chrome.storage.local.get('cached_data');
  return result['cached_data'] ?? null;
}
```

## Permissions Guide

Only request permissions you actually use. Declare in manifest:

| Permission | When to use |
|---|---|
| `storage` | `chrome.storage.local` / `sync` |
| `activeTab` | Access current tab on user action |
| `tabs` | Access all tabs (use sparingly) |
| `scripting` | Inject scripts programmatically |
| `alarms` | Schedule periodic work in service worker |
| `contextMenus` | Add right-click menu items |

Host permissions (`host_permissions`) for specific domains are preferred over broad `<all_urls>`.

## Build Setup (Vite — recommended)

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import { resolve } from 'path';

export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        background: resolve(__dirname, 'src/background/index.ts'),
        content: resolve(__dirname, 'src/content/index.ts'),
        popup: resolve(__dirname, 'src/popup/index.ts'),
      },
      output: {
        entryFileNames: '[name].js',
        format: 'iife', // Required for content scripts
      },
    },
    outDir: 'dist',
  },
});
```

## Debugging Tips

- Background service worker: `chrome://extensions` → "Service Worker" link
- Content script: DevTools of the target page
- Popup: Right-click popup → "Inspect"
- Storage: DevTools → Application → Extension Storage
