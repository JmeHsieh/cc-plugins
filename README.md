# cc-plugins

A [Claude Code plugin marketplace](https://docs.anthropic.com/en/docs/claude-code/plugins)
for personal tools, skills, and hooks.

Marketplace name: `jo-yuan`

## Plugins

### arc-conduit

Query and manage Phabricator via `arc` CLI and
Conduit API — tasks, diffs, repos, users, and more.

### ask-save-permit

PreToolUse hook that prompts (via macOS dialog)
whether to permanently save a permission grant
to `~/.claude/settings.json`.

## Installation

Register this marketplace in your
`~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "jo-yuan": {
      "source": {
        "source": "github",
        "repo": "yuan/cc-plugins"
      }
    }
  }
}
```

Then enable plugins:

```json
{
  "enabledPlugins": {
    "arc-conduit@jo-yuan": true,
    "ask-save-permit@jo-yuan": true
  }
}
```

## License

MIT
