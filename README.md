# Agent Skills

A collection of [Claude Code skills](https://docs.anthropic.com/en/docs/claude-code/skills)
for enhancing AI agent workflows.

## Available Skills

### arc-conduit

Query and manage Phabricator via `arc` CLI and
Conduit API — tasks, diffs, repos, users, and more.

**Prerequisites:**
- [Arcanist](https://secure.phabricator.com/book/phabricator/article/arcanist/)
  (`arc`) installed and configured
- `.arcconfig` in your project root pointing to
  your Phabricator instance

**Installation:**

Copy the skill directory into your project's
`.claude/skills/`:

```bash
cp -r arc-conduit /path/to/your/project/.claude/skills/
```

The expected path after installation:

```
your-home/
└── .claude/
    └── skills/
        └── arc-conduit/
            ├── SKILL.md
            └── references/
                └── conduit_api.md
```

## License

MIT
