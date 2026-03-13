---
name: arc-conduit
description: >
  Query and manage Phabricator via arc CLI and
  Conduit API — tasks, diffs, repos, users, and
  more. Use this skill whenever the user mentions
  Phabricator, arc, Conduit, maniphest,
  differential, or wants to look up tasks, diffs,
  or code reviews.
---

# Arc Conduit API Skill

Use `arc call-conduit` to interact with
Phabricator's Conduit API. This project has
`.arcconfig` configured.

## Workflow

1. Identify which Conduit API method you need.
   Use Grep to search `conduit_api.md` in this
   skill's references directory for the specific
   method or keyword. Do NOT Read the entire file.
   ```
   Grep pattern="### method.name"
        path=".claude/skills/arc-conduit/references/conduit_api.md"
   ```

2. Execute with `arc call-conduit`. The general
   syntax is:
   ```bash
   echo '{"param": "value"}' \
     | arc call-conduit -- <method.name>
   ```
   Always use `--` before the method name.
   Parameters are JSON via stdin.

3. Return the API response to the user.

## Common API domains

If unsure which method to use, Grep for these
domain prefixes in `conduit_api.md`:
- Tasks: `maniphest.`
- Diffs / Code reviews: `differential.`
- Repositories: `diffusion.`
- Users: `user.`
- Projects: `project.`
