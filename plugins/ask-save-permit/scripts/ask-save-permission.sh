#!/bin/bash
# ask-save-permission.sh
# PermissionRequest hook: when Claude Code is about to show
# a permission dialog, pop a macOS dialog asking whether to
# save the permission to ~/.claude/settings.json allow-list.
#
# The hook never returns a decision — it always exits 0 so
# Claude Code proceeds with its own permission prompt.

set -euo pipefail

SETTINGS_FILE="$HOME/.claude/settings.json"
INPUT=$(cat)

python3 - "$INPUT" "$SETTINGS_FILE" << 'PYTHON_SCRIPT'
import hashlib
import json
import os
import re
import subprocess
import sys
import time

# ── Risk classification ──────────────────────────────────

DANGER_PATTERNS = [
    r"^(rm|rmdir|kill|killall|pkill|mkfs|dd"
    r"|shutdown|reboot)\b",
    r"\bgit\s+push\b",
    r"\bgit\s+reset\s+--hard\b",
    r"\bgit\s+clean\s+-f\b",
    r"\bgit\s+branch\s+-D\b",
    r"\b(drop|truncate)\s+",
    r"\bdelete\s+from\s+",
]

DANGER = "danger"
ALERT = "alert"
WARN_EMOJI = "\u26A0\uFE0F "  # ⚠️


def classify_risk(tool_name, tool_input):
    """Classify risk: only Bash commands can be DANGER."""
    if tool_name == "Bash":
        cmd = tool_input.get("command", "").strip()
        for pat in DANGER_PATTERNS:
            if re.search(pat, cmd, re.IGNORECASE):
                return DANGER
    return ALERT


# ── Dedup lock ───────────────────────────────────────────

LOCK_DIR = "/tmp/ask-save-permit"
POLL_INTERVAL = 0.5
POLL_TIMEOUT = 25


def _lock_path(tool_name, tool_input):
    """Build a lock file path from tool identity."""
    if tool_name == "Bash":
        key = tool_name + tool_input.get("command", "")
    else:
        key = tool_name
    h = hashlib.sha256(key.encode()).hexdigest()[:16]
    return os.path.join(LOCK_DIR, f"{h}.lock")


def acquire_lock(lock_file):
    """Try to create lock file atomically.

    Returns True if we acquired it, False if another
    process holds it.
    """
    os.makedirs(LOCK_DIR, exist_ok=True)
    try:
        fd = os.open(
            lock_file,
            os.O_CREAT | os.O_EXCL | os.O_WRONLY,
        )
        os.close(fd)
        return True
    except FileExistsError:
        return False


def wait_for_lock(lock_file):
    """Poll until lock is released or timeout."""
    elapsed = 0.0
    while elapsed < POLL_TIMEOUT:
        if not os.path.exists(lock_file):
            return
        time.sleep(POLL_INTERVAL)
        elapsed += POLL_INTERVAL


def release_lock(lock_file):
    try:
        os.remove(lock_file)
    except FileNotFoundError:
        pass


# ── Settings I/O ─────────────────────────────────────────

def load_settings(settings_file):
    if os.path.exists(settings_file):
        with open(settings_file, "r") as f:
            return json.load(f)
    return {}


def save_permission(settings_file, perm):
    settings = load_settings(settings_file)
    allow = settings.setdefault(
        "permissions", {},
    ).setdefault("allow", [])
    if perm not in allow:
        allow.append(perm)
    with open(settings_file, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")


# ── macOS dialog ─────────────────────────────────────────

def _escape(text):
    """Escape for AppleScript string literal."""
    return text.replace("\\", "\\\\").replace('"', '\\"')


def show_dialog(title, buttons):
    """Show macOS alert with vertical buttons.

    Returns the button label clicked,
    or None if user closed the dialog or on error.
    """
    btn_list = ", ".join(
        f'"{_escape(b)}"' for b in buttons
    )
    # Default to "No" (first in array = last on screen)
    default = f'"{_escape(buttons[0])}"'
    script = (
        f'display alert "{_escape(title)}" '
        f"buttons {{{btn_list}}} "
        f"default button {default}"
    )
    result = subprocess.run(
        ["osascript", "-e", script],
        capture_output=True,
        text=True,
    )
    output = result.stdout.strip()
    # osascript returns "button returned:ButtonLabel"
    if "button returned:" in output:
        return output.split("button returned:", 1)[1]
    return None


# ── Display helpers ──────────────────────────────────────


# ── Main ─────────────────────────────────────────────────

def main():
    raw_input = sys.argv[1]
    settings_file = sys.argv[2]

    data = json.loads(raw_input)
    tool_name = data.get("tool_name", "")
    tool_input = data.get("tool_input", {})

    # ── Dedup lock ───────────────────────────────────
    lock_file = _lock_path(tool_name, tool_input)
    if not acquire_lock(lock_file):
        wait_for_lock(lock_file)
        sys.exit(0)

    try:
        _run_dialog(tool_name, tool_input, settings_file)
    finally:
        release_lock(lock_file)


def _truncate(text, max_len=30):
    """Truncate text for button display."""
    if len(text) <= max_len:
        return text
    return text[: max_len - 3] + "..."


def _run_dialog(tool_name, tool_input, settings_file):
    risk = classify_risk(tool_name, tool_input)
    prefix = WARN_EMOJI if risk == DANGER else ""
    title = f"{prefix}Add to allow list?"

    if tool_name == "Bash":
        cmd = tool_input.get("command", "").strip()
        first_word = cmd.split()[0] if cmd else ""
        group_perm = (
            f"Bash({first_word} *)" if first_word else None
        )
        exact_perm = f"Bash({cmd})"
        exact_label = f"Bash({_truncate(cmd)})"

        if group_perm and group_perm != exact_perm:
            buttons = [
                "No",
                f"Add '{exact_label}'",
                f"Add '{group_perm}'",
            ]
        else:
            buttons = [
                "No",
                f"Add '{exact_label}'",
            ]

        clicked = show_dialog(title, buttons)
        if clicked is None:
            return

        if group_perm and clicked.endswith(
            f"Add '{group_perm}'"
        ):
            save_permission(settings_file, group_perm)
        elif clicked.endswith(f"Add '{exact_label}'"):
            save_permission(settings_file, exact_perm)
    else:
        perm = tool_name
        buttons = [
            "No",
            f"Add '{perm}'",
        ]
        clicked = show_dialog(title, buttons)
        if clicked is not None and clicked.endswith(
            f"Add '{perm}'"
        ):
            save_permission(settings_file, perm)


if __name__ == "__main__":
    main()
PYTHON_SCRIPT
