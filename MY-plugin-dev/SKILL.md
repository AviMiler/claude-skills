---
name: plugin-dev
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

## ⚠️ עקרונות יסוד — לא לדלג

**לפני שכותבים שורת קוד אחת**, חייב להבין את הגישה של המשתמש הזה:

### ❌ אסור לחלוטין
- NPM / package.json (להתקנת חבילות)
- Webpack / Vite / esbuild / כל build tool
- TypeScript (אלא אם המשתמש ביקש במפורש)
- `node_modules` תיקייה
- dist / build output תיקיות
- ייבוא חבילות חיצוניות (lodash, axios וכד')

### ✅ חובה תמיד
- **Vanilla JS בלבד** — קוד שרץ ישירות בדפדפן / VS Code ללא קומפילציה
- **כמה שפחות קבצים** — עדיף 3 קבצים על פני 8
- **כל קובץ עד 500 שורות** — אם עולה על זה, לפצל לוגית
- **מבנה שאפשר לשלוח במייל** — כמה קבצי JS שמים בתיקייה ומסיימים
- **אין תיקיות src/ dist/ shared/ nested** — שטוח ככל האפשר

---

## אמת מה נדרש לפני שמתחילים

1. Chrome extension, VS Code extension, או שניהם?
2. יש צורך ב-UI? (popup, sidebar, panel)
3. פרויקט חדש או הוספת קוד לקיים?

---

## מבנה קבצים — Chrome Extension (Manifest V3)

**מבנה רגיל (רוב המקרים):**
```
my-extension/
├── manifest.json
├── background.js
├── content.js
├── popup.html
├── popup.js
└── icons/
```

**מבנה גדול יותר (רק אם חובה):**
```
my-extension/
├── manifest.json
├── background.js
├── content.js
├── popup.html
├── popup.js
├── popup.css
└── icons/
```

**אין** `src/`, **אין** `dist/`, **אין** `package.json`.  
manifest.json + קבצי JS → גורר לכרום → עובד.

---

## מבנה קבצים — VS Code Extension

**מבנה רגיל:**
```
my-extension/
├── package.json        ← רק זה (manifest של VS Code, לא NPM install)
├── extension.js        ← activate() + כל הלוגיקה הראשית
└── panel.html          ← אם יש webview
```

**מבנה גדול יותר (רק אם חובה):**
```
my-extension/
├── package.json
├── extension.js
├── commands.js
├── panel.html
└── panel.js
```

> package.json ב-VS Code הוא **manifest בלבד** — לא `npm install`.  
> הקוד רץ ישירות ב-VS Code runtime ללא build.

---

## כללי כתיבת קוד

### פיצול קבצים — מתי ואיך
- קובץ שמגיע ל-**400+ שורות** → לפצל לפי אחריות (UI בנפרד, לוגיקה בנפרד)
- **לא** ליצור קובץ חדש רק כדי לארגן — רק אם הקובץ הנוכחי גדל מדי
- עדיף פונקציה ארוכה עם הערות טובות על פני 5 קבצים קטנים

### תקשורת בין קבצים — Chrome
```js
// שליחה (popup.js / content.js)
chrome.runtime.sendMessage({ type: 'DO_THING', data: payload }, response => { ... });

// קבלה (background.js)
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
  if (msg.type === 'DO_THING') { ... sendResponse({ ok: true }); }
  return true; // חובה אם sendResponse אסינכרוני
});
```

### VS Code — כל ה-disposables ל-subscriptions
```js
function activate(context) {
  const cmd = vscode.commands.registerCommand('ext.hello', () => { ... });
  context.subscriptions.push(cmd);
}
```

---

## Chrome MV3 — כללים קריטיים

- Service worker (background.js) — **אין DOM**, אין `window`, אין `document`
- שמירת נתונים: `chrome.storage.local` בלבד (לא `localStorage`)
- Content script: רץ בעמוד אבל בסביבה מבודדת — `window.postMessage` לתקשורת עם JS של העמוד
- להגן מפני double-injection בcontent script:
```js
if (window.__myExtLoaded) return;
window.__myExtLoaded = true;
```

---

## VS Code — כללים קריטיים

- `package.json` חייב: `"main": "./extension.js"` + `"engines": { "vscode": "^1.70.0" }`
- Webview חייב nonce + CSP:
```js
const nonce = Math.random().toString(36).slice(2);
// בHTML: <meta http-equiv="Content-Security-Policy" content="default-src 'none'; script-src 'nonce-${nonce}';">
```
- `activationEvents: ["onCommand:ext.myCommand"]` או `"*"` לפיתוח

---

## Architecture Context — לתוך הקובץ הראשי

כשיש יותר מ-2 קבצים, לשים בראש extension.js / background.js הערה:

```js
/**
 * ARCHITECTURE
 * background.js  — service worker, לוגיקה מרכזית, chrome.storage
 * content.js     — injection לעמוד, DOM manipulation
 * popup.js       — UI של ה-popup, מדבר עם background דרך messages
 *
 * FLOW: popup → sendMessage → background → storage / tab action
 */
```

אין קובץ ARCHITECTURE.md נפרד — ההערה נמצאת בקוד עצמו.
