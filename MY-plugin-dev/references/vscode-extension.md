# VS Code Extension Reference

## package.json — Extension Manifest

```json
{
  "name": "my-extension",
  "displayName": "My Extension",
  "version": "0.0.1",
  "engines": { "vscode": "^1.85.0" },
  "categories": ["Other"],
  "activationEvents": [],
  "main": "./out/extension.js",
  "contributes": {
    "commands": [
      {
        "command": "myExtension.doSomething",
        "title": "My Extension: Do Something"
      }
    ],
    "configuration": {
      "title": "My Extension",
      "properties": {
        "myExtension.enableFeature": {
          "type": "boolean",
          "default": true,
          "description": "Enable the main feature"
        }
      }
    }
  },
  "scripts": {
    "compile": "tsc -p ./",
    "watch": "tsc -watch -p ./",
    "package": "vsce package"
  },
  "devDependencies": {
    "@types/vscode": "^1.85.0",
    "typescript": "^5.3.0"
  }
}
```

## Extension Entry Point

```typescript
// src/extension.ts
import * as vscode from 'vscode';
import { registerDoSomethingCommand } from './commands/doSomething';
import { createLogger } from './shared/logger';

const logger = createLogger('Extension');

/**
 * Called when the extension is activated.
 * ALL disposables must be pushed to context.subscriptions.
 */
export function activate(context: vscode.ExtensionContext): void {
  logger.info('Extension activating');

  // Register commands — each in its own file
  context.subscriptions.push(
    registerDoSomethingCommand(context),
  );

  logger.info('Extension activated');
}

/**
 * Called when the extension is deactivated.
 * context.subscriptions are disposed automatically.
 */
export function deactivate(): void {
  // Cleanup not handled by subscriptions goes here
}
```

## Command Pattern — One File Per Command

```typescript
// src/commands/doSomething.ts
import * as vscode from 'vscode';

/**
 * Registers the "myExtension.doSomething" command.
 * @param context - Extension context for subscription management
 * @returns Disposable — push to context.subscriptions
 */
export function registerDoSomethingCommand(
  context: vscode.ExtensionContext
): vscode.Disposable {
  return vscode.commands.registerCommand('myExtension.doSomething', async () => {
    try {
      await executeDoSomething(context);
    } catch (error) {
      vscode.window.showErrorMessage(`Do Something failed: ${error}`);
    }
  });
}

async function executeDoSomething(context: vscode.ExtensionContext): Promise<void> {
  const editor = vscode.window.activeTextEditor;
  if (!editor) {
    vscode.window.showWarningMessage('No active editor');
    return;
  }
  // ... logic
}
```

## Logger — Shared Output Channel

```typescript
// src/shared/logger.ts
import * as vscode from 'vscode';

// One output channel for the whole extension
const outputChannel = vscode.window.createOutputChannel('My Extension');

export interface Logger {
  info(message: string): void;
  warn(message: string): void;
  error(message: string, error?: unknown): void;
}

/**
 * Creates a scoped logger that prefixes messages with the component name.
 * @param component - Name of the component (e.g., 'TreeProvider', 'Command')
 */
export function createLogger(component: string): Logger {
  const prefix = `[${component}]`;
  return {
    info: (msg) => outputChannel.appendLine(`${prefix} INFO: ${msg}`),
    warn: (msg) => outputChannel.appendLine(`${prefix} WARN: ${msg}`),
    error: (msg, err?) => outputChannel.appendLine(
      `${prefix} ERROR: ${msg}${err ? ` — ${err}` : ''}`
    ),
  };
}
```

## Configuration Wrapper

```typescript
// src/shared/config.ts
import * as vscode from 'vscode';

const CONFIG_SECTION = 'myExtension';

/**
 * Get a configuration value with type safety.
 * Always use this — never call getConfiguration() directly in feature code.
 */
export function getConfig<T>(key: string, defaultValue: T): T {
  return vscode.workspace
    .getConfiguration(CONFIG_SECTION)
    .get<T>(key, defaultValue);
}

// Typed accessors for each setting
export const config = {
  get enableFeature(): boolean {
    return getConfig('enableFeature', true);
  },
};
```

## TreeDataProvider Pattern

```typescript
// src/providers/myTreeProvider.ts
import * as vscode from 'vscode';

interface MyItem {
  id: string;
  label: string;
  children?: MyItem[];
}

export class MyTreeProvider implements vscode.TreeDataProvider<MyItem> {
  private readonly _onDidChangeTreeData =
    new vscode.EventEmitter<MyItem | undefined | void>();

  readonly onDidChangeTreeData = this._onDidChangeTreeData.event;

  /** Call this to refresh the tree view */
  refresh(): void {
    this._onDidChangeTreeData.fire();
  }

  getTreeItem(element: MyItem): vscode.TreeItem {
    return new vscode.TreeItem(
      element.label,
      element.children?.length
        ? vscode.TreeItemCollapsibleState.Collapsed
        : vscode.TreeItemCollapsibleState.None
    );
  }

  async getChildren(element?: MyItem): Promise<MyItem[]> {
    if (!element) {
      return this.getRootItems();
    }
    return element.children ?? [];
  }

  private async getRootItems(): Promise<MyItem[]> {
    // Fetch/compute root items
    return [];
  }
}
```

## Webview Panel with CSP

```typescript
// src/webview/myPanel.ts
import * as vscode from 'vscode';
import * as crypto from 'crypto';

/**
 * Generates a cryptographic nonce for Content Security Policy.
 * Required for inline scripts in VS Code webviews.
 */
function getNonce(): string {
  return crypto.randomBytes(16).toString('base64');
}

export function createMyPanel(context: vscode.ExtensionContext): vscode.WebviewPanel {
  const panel = vscode.window.createWebviewPanel(
    'myPanel',
    'My Panel',
    vscode.ViewColumn.One,
    {
      enableScripts: true,
      localResourceRoots: [context.extensionUri],
    }
  );

  const nonce = getNonce();
  panel.webview.html = getWebviewContent(panel.webview, context.extensionUri, nonce);

  // Handle messages from webview
  panel.webview.onDidReceiveMessage(
    (message) => handleWebviewMessage(panel, message),
    undefined,
    context.subscriptions
  );

  return panel;
}

function getWebviewContent(
  webview: vscode.Webview,
  extensionUri: vscode.Uri,
  nonce: string
): string {
  return `<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="Content-Security-Policy"
    content="default-src 'none'; script-src 'nonce-${nonce}';">
</head>
<body>
  <script nonce="${nonce}">
    const vscode = acquireVsCodeApi();
    // webview JS here
  </script>
</body>
</html>`;
}

function handleWebviewMessage(
  panel: vscode.WebviewPanel,
  message: { command: string; payload?: unknown }
): void {
  switch (message.command) {
    case 'ready':
      panel.webview.postMessage({ command: 'init', data: {} });
      break;
    default:
      console.error('[MyPanel] Unknown command:', message.command);
  }
}
```

## Subscriptions — The Golden Rule

Every API call that returns a `Disposable` must be pushed to `context.subscriptions`:

```typescript
// RIGHT
context.subscriptions.push(
  vscode.commands.registerCommand(...),
  vscode.window.registerTreeDataProvider(...),
  vscode.workspace.onDidChangeConfiguration(...),
);

// WRONG — memory leak, not cleaned up on deactivation
vscode.commands.registerCommand(...);
```

## .vscodeignore

```
.vscode/**
src/**
.gitignore
tsconfig.json
webpack.config.js
node_modules/**
out/test/**
**/*.map
```

## Publishing Checklist

- [ ] `vsce package` runs without errors
- [ ] All `activationEvents` are correct (or use `"*"` for development only)
- [ ] README has screenshots
- [ ] `publisher` field set in package.json
- [ ] `.vscodeignore` excludes source and dev files
