# claude-skills

Personal Claude skill library — shared across claude.ai and Claude Code.

## Skills

| Skill | Description |
|---|---|
| [`agentic-code`](./agentic-code/SKILL.md) | Agent-ready code standards — mandatory for all dev work |
| [`coding-workflow`](./coding-workflow/SKILL.md) | Mandatory 4-stage sequence for every coding task — validate → build → document → git |
| [`plugin-dev`](./plugin-dev/SKILL.md) | Chrome Extension (MV3) + VS Code Extension development |
| [`angular-21-modern`](./angular-21-modern/SKILL.md) | Modern Angular 21 with signals, zoneless, standalone components |

## Structure

```
claude-skills/
├── agentic-code/
│   └── SKILL.md
├── coding-workflow/
│   └── SKILL.md
├── plugin-dev/
│   ├── SKILL.md
│   └── references/
│       ├── chrome-extension.md
│       └── vscode-extension.md
├── angular-21-modern/
│   └── SKILL.md
└── README.md
```

## Usage in Claude Code

```bash
# Clone once
git clone https://github.com/YOUR_USERNAME/claude-skills ~/.claude-skills

# Update
git -C ~/.claude-skills pull
```

## Convention

Every dev skill starts with a reference to `agentic-code`:

```
⚠️ Read First — load agentic-code skill
```
