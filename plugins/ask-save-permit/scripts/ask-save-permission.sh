#!/bin/bash
# ask-save-permission.sh
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
import re
import subprocess
import sys
import os
import fnmatch
from pathlib import Path


# Risk levels
SAFE = "safe"      # 🟢 read-only operations
ALERT = "alert"    # 🟡 file modifications, network, general bash
DANGER = "danger"  # 🔴 destructive bash commands

RISK_EMOJI = {
    SAFE: "\U0001F7E2",    # 🟢
    ALERT: "\U0001F7E1",   # 🟡
    DANGER: "\U0001F534",  # 🔴
}

RISK_LABEL = {
    SAFE: "Safe",
    ALERT: "Alert",
    DANGER: "Danger",
}

# Patterns that make a Bash command dangerous
DANGER_PATTERNS = [
    # Direct destructive commands (first word)
    r"^(rm|rmdir|kill|killall|pkill|mkfs|dd"
    r"|shutdown|reboot)\b",
    # Git destructive
    r"\bgit\s+push\b",
    r"\bgit\s+reset\s+--hard\b",
    r"\bgit\s+clean\s+-f\b",
    r"\bgit\s+branch\s+-D\b",
    # DB destructive
    r"\b(drop|truncate)\s+",
    r"\bdelete\s+from\s+",
]

SAFE_TOOLS = {"Read", "Glob", "Grep"}


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


def classify_risk(
    tool_name: str,
    tool_input: dict,
) -> str:
    """Classify operation risk level."""
    if tool_name in SAFE_TOOLS:
        return SAFE

    if tool_name == "Bash":
        cmd = tool_input.get("command", "").strip()
        for pattern in DANGER_PATTERNS:
            if re.search(pattern, cmd, re.IGNORECASE):
                return DANGER

    # Edit, Write, WebFetch, non-dangerous Bash
    return ALERT


def build_display(
    tool_name: str,
    tool_input: dict,
) -> str:
    """Build a human-readable display string."""
    if tool_name == "Bash":
        cmd = tool_input.get("command", tool_name)
        return cmd if len(cmd) <= 80 else cmd[:77] + "..."
    if tool_name in ("Edit", "Write", "Read"):
        fp = tool_input.get("file_path", "")
        return f"{tool_name}({fp})" if fp else tool_name
    if tool_name == "WebFetch":
        url = tool_input.get("url", "")
        return f"WebFetch({url})" if url else "WebFetch"
    return tool_name


def prompt_user(
    tool_name: str,
    group_perm: str | None,
    tool_input: dict,
) -> str:
    """Prompt user via macOS display dialog."""
    risk = classify_risk(tool_name, tool_input)
    emoji = RISK_EMOJI[risk]
    label = RISK_LABEL[risk]
    display = build_display(tool_name, tool_input)
    display_escaped = display.replace('"', '\\"')

    prompt = (
        f"{emoji} {label}\\n\\n"
        f"Tool: {display_escaped}\\n\\n"
        f"Save this permission?"
    )

    if risk == DANGER:
        # No allow buttons for danger operations
        script = (
            f'display dialog "{prompt}" '
            f'buttons {{"Ask me this time"}} '
            f'default button "Ask me this time"'
        )
    elif group_perm is None:
        # No meaningful group: 2 buttons
        script = (
            f'display dialog "{prompt}" '
            f'buttons {{"Allow ALL {tool_name}",'
            f' "Ask me this time"}} '
            f'default button "Ask me this time"'
        )
    else:
        group_escaped = group_perm.replace('"', '\\"')
        script = (
            f'display dialog "{prompt}" '
            f'buttons {{"Allow ALL {tool_name}",'
            f' "Allow {group_escaped}",'
            f' "Ask me this time"}} '
            f'default button "Ask me this time"'
        )

    result = subprocess.run(
        ["osascript", "-e", script],
        capture_output=True,
        text=True,
    )

    output = result.stdout.strip()

    if "Allow ALL" in output:
        return "all"
    elif "Allow " in output and group_perm is not None:
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
