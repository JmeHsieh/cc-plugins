#!/bin/bash
# ask-save-permit.sh
# PreToolUse hook: asks user whether to permanently save
# a permission grant to ~/.claude/settings.json.
#
# Uses macOS osascript dialogs since Claude Code hooks
# don't have terminal (tty) access.

set -euo pipefail

SETTINGS_FILE="$HOME/.claude/settings.json"
INPUT=$(cat)

python3 - "$INPUT" "$SETTINGS_FILE" << 'PYTHON_SCRIPT'
import json
import subprocess
import sys
import os
import fnmatch
from pathlib import Path


def build_group_permission(
    tool_name: str,
    tool_input: dict,
) -> str | None:
    """Build a group-level permission string for option 2.

    Returns None if no meaningful group can be derived
    (i.e., option 2 would be identical to option 1).
    """
    if tool_name == "Bash":
        cmd = tool_input.get("command", "").strip()
        first_word = cmd.split()[0] if cmd else ""
        if first_word:
            return f"Bash({first_word} *)"
        return None

    if tool_name in ("Edit", "Write", "Read"):
        fp = tool_input.get("file_path", "")
        if fp:
            parent = str(Path(fp).parent)
            return f"{tool_name}({parent}/**)"
        return None

    if tool_name == "WebFetch":
        url = tool_input.get("url", "")
        if url:
            from urllib.parse import urlparse
            domain = urlparse(url).netloc
            if domain:
                return f"WebFetch(domain:{domain})"
        return None

    return None


def should_skip(
    tool_name: str,
    tool_input: dict,
    settings_file: str,
) -> bool:
    """Skip if this tool call targets settings.json itself."""
    if tool_name not in ("Edit", "Write"):
        return False
    fp = tool_input.get("file_path", "")
    return os.path.abspath(fp) == os.path.abspath(settings_file)


def is_already_allowed(
    tool_name: str,
    tool_input: dict,
    settings: dict,
) -> bool:
    """Check if tool is already covered by an allow rule."""
    allow_list = (
        settings.get("permissions", {}).get("allow", [])
    )

    # Bare tool name allows everything
    if tool_name in allow_list:
        return True

    # Build the value to match against patterns
    if tool_name == "Bash":
        val = tool_input.get("command", "").strip()
    elif tool_name in ("Edit", "Write", "Read"):
        val = tool_input.get("file_path", "")
    elif tool_name == "WebFetch":
        val = tool_input.get("url", "")
    else:
        val = ""

    if not val:
        return False

    prefix = tool_name + "("
    for rule in allow_list:
        if not (rule.startswith(prefix) and rule.endswith(")")):
            continue
        pat = rule[len(prefix):-1]
        # Handle legacy colon syntax: "npm:*" → "npm *"
        pat_normalized = pat
        if pat.endswith(":*"):
            pat_normalized = pat[:-2] + " *"
        if (
            fnmatch.fnmatch(val, pat)
            or fnmatch.fnmatch(val, pat_normalized)
        ):
            return True

    return False


def load_settings(settings_file: str) -> dict:
    if os.path.exists(settings_file):
        with open(settings_file, "r") as f:
            return json.load(f)
    return {}


def save_permission(settings_file: str, perm: str) -> None:
    settings = load_settings(settings_file)
    allow = settings.setdefault(
        "permissions", {},
    ).setdefault("allow", [])
    if perm not in allow:
        allow.append(perm)
    with open(settings_file, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")


def output_decision(decision: str, reason: str = "") -> None:
    result = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": decision,
        },
    }
    if reason:
        result["hookSpecificOutput"][
            "permissionDecisionReason"
        ] = reason
    print(json.dumps(result))


def prompt_user(
    tool_name: str,
    group_perm: str | None,
    tool_input: dict,
) -> str:
    """Prompt user via macOS osascript dialog."""
    # Build display string
    if tool_name == "Bash":
        cmd = tool_input.get("command", tool_name)
        # Truncate long commands for dialog display
        display = cmd if len(cmd) <= 80 else cmd[:77] + "..."
    elif tool_name in ("Edit", "Write", "Read"):
        fp = tool_input.get("file_path", "")
        display = f"{tool_name}({fp})" if fp else tool_name
    elif tool_name == "WebFetch":
        url = tool_input.get("url", "")
        display = f"WebFetch({url})" if url else "WebFetch"
    else:
        display = tool_name

    # Build option list
    if group_perm is None:
        options = [
            f"1) Allow ALL '{tool_name}'",
            "2) No, ask me this time",
        ]
        default = options[-1]
    else:
        options = [
            f"1) Allow ALL '{tool_name}'",
            f"2) Allow: {group_perm}",
            "3) No, ask me this time",
        ]
        default = options[-1]

    # Escape for AppleScript
    display_escaped = display.replace('"', '\\"')
    items = ", ".join(
        f'"{o.replace(chr(34), chr(92) + chr(34))}"'
        for o in options
    )

    script = (
        f'choose from list {{{items}}} '
        f'with prompt "Save Permission?\\n\\n'
        f'Tool: {display_escaped}" '
        f'default items {{"{default}"}}'
    )

    result = subprocess.run(
        ["osascript", "-e", script],
        capture_output=True,
        text=True,
    )

    choice = result.stdout.strip()

    if choice.startswith("1)"):
        return "all"
    elif choice.startswith("2)") and group_perm is not None:
        return "group"
    return "skip"


def main():
    raw_input = sys.argv[1]
    settings_file = sys.argv[2]

    data = json.loads(raw_input)
    tool_name = data.get("tool_name", "")
    tool_input = data.get("tool_input", {})

    # Skip if targeting settings.json
    if should_skip(tool_name, tool_input, settings_file):
        sys.exit(0)

    settings = load_settings(settings_file)

    # Skip if already allowed
    if is_already_allowed(tool_name, tool_input, settings):
        sys.exit(0)

    group_perm = build_group_permission(tool_name, tool_input)

    # Ask user
    choice = prompt_user(tool_name, group_perm, tool_input)

    if choice == "all":
        save_permission(settings_file, tool_name)
        output_decision("allow", "Saved to settings.json")
    elif choice == "group":
        save_permission(settings_file, group_perm)
        output_decision("allow", "Saved to settings.json")
    else:
        output_decision("ask")


if __name__ == "__main__":
    main()
PYTHON_SCRIPT
