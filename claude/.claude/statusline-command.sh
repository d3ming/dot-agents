#!/bin/bash
# Claude Code Custom Statusline
# Shows session and weekly usage with configurable plan limits

set -euo pipefail

# ==============================================================================
# Configuration
# ==============================================================================

CONFIG_FILE="${HOME}/.claude/statusline.conf"
CACHE_FILE="/tmp/claude-statusline-cache-${USER}.json"
CACHE_LOCK="/tmp/claude-statusline-cache-${USER}.lock"

# Load configuration
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    # Defaults if no config file
    PLAN="${CLAUDE_PLAN:-max5}"
    MAX5_SESSION_LIMIT=200000
    MAX5_WEEKLY_LIMIT=2000000
    SHOW_COST=false
    SHOW_GIT=true
    CACHE_TTL=30
    WARN_THRESHOLD=70
    CRITICAL_THRESHOLD=90
fi

# Allow env var overrides
PLAN="${CLAUDE_PLAN:-${PLAN:-max5}}"

# ==============================================================================
# Helper Functions
# ==============================================================================

# Get plan limits based on current plan
get_limits() {
    local plan="${1:-$PLAN}"
    case "$plan" in
        pro)
            echo "${PRO_SESSION_LIMIT:-100000} ${PRO_WEEKLY_LIMIT:-500000}"
            ;;
        max5)
            echo "${MAX5_SESSION_LIMIT:-200000} ${MAX5_WEEKLY_LIMIT:-2000000}"
            ;;
        max20)
            echo "${MAX20_SESSION_LIMIT:-500000} ${MAX20_WEEKLY_LIMIT:-5000000}"
            ;;
        custom)
            echo "${CUSTOM_SESSION_LIMIT:-200000} ${CUSTOM_WEEKLY_LIMIT:-2000000}"
            ;;
        *)
            echo "200000 2000000" # Default to max5
            ;;
    esac
}

# Format large numbers with K/M suffix
format_number() {
    local num=$1
    if (( num >= 1000000 )); then
        echo "$(awk "BEGIN {printf \"%.1fM\", $num/1000000}")"
    elif (( num >= 1000 )); then
        echo "$(awk "BEGIN {printf \"%.0fK\", $num/1000}")"
    else
        echo "$num"
    fi
}

# Get color based on percentage
get_color() {
    local pct=$1
    local warn=${WARN_THRESHOLD:-70}
    local crit=${CRITICAL_THRESHOLD:-90}

    if (( $(awk "BEGIN {print ($pct >= $crit)}") )); then
        echo -e "\033[31m" # Red
    elif (( $(awk "BEGIN {print ($pct >= $warn)}") )); then
        echo -e "\033[33m" # Yellow
    else
        echo -e "\033[32m" # Green
    fi
}

# Reset color
RESET="\033[0m"
GRAY="\033[90m"
CYAN="\033[36m"
MAGENTA="\033[35m"

# ==============================================================================
# Cache Management
# ==============================================================================

is_cache_valid() {
    [[ -f "$CACHE_FILE" ]] || return 1
    local cache_age=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0) ))
    [[ $cache_age -lt ${CACHE_TTL:-30} ]]
}

# ==============================================================================
# Usage Calculation
# ==============================================================================

calculate_usage() {
    local jsonl_dir="${HOME}/.claude/projects"
    local now=$(date +%s)
    local session_cutoff=$(( now - 86400 ))    # 24 hours
    local weekly_cutoff=$(( now - 604800 ))    # 7 days

    # Find all .jsonl files and parse them
    local session_tokens=0
    local weekly_tokens=0
    local seen_messages=()

    # Use Python for efficient parsing
    python3 <<EOF
import json
import os
import glob
from datetime import datetime, timedelta, timezone

jsonl_dir = "$jsonl_dir"
now = datetime.now(timezone.utc)
session_cutoff = now - timedelta(days=1)
weekly_cutoff = now - timedelta(days=7)

session_tokens = 0
weekly_tokens = 0
seen_messages = set()

# Find all .jsonl files modified in the last 7 days (performance optimization)
import time
week_ago_ts = time.time() - (7 * 86400)
jsonl_files = []
for filepath in glob.glob(os.path.join(jsonl_dir, "**/*.jsonl"), recursive=True):
    try:
        if os.path.getmtime(filepath) >= week_ago_ts:
            jsonl_files.append(filepath)
    except OSError:
        continue

for jsonl_file in jsonl_files:
    try:
        with open(jsonl_file, 'r') as f:
            for line in f:
                try:
                    data = json.loads(line)

                    # Get timestamp
                    timestamp_str = data.get('timestamp')
                    if not timestamp_str:
                        continue

                    timestamp = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))

                    # Check if within our time windows
                    is_session = timestamp >= session_cutoff
                    is_weekly = timestamp >= weekly_cutoff

                    if not is_weekly:
                        continue

                    # Get usage data
                    usage = data.get('usage') or data.get('message', {}).get('usage')
                    if not usage:
                        continue

                    # Deduplicate by UUID
                    msg_id = data.get('uuid') or data.get('message_id')
                    if msg_id in seen_messages:
                        continue
                    seen_messages.add(msg_id)

                    # Calculate tokens
                    tokens = (
                        usage.get('input_tokens', 0) +
                        usage.get('cache_creation_input_tokens', 0) +
                        usage.get('cache_read_input_tokens', 0) +
                        usage.get('output_tokens', 0)
                    )

                    if is_session:
                        session_tokens += tokens
                    if is_weekly:
                        weekly_tokens += tokens

                except json.JSONDecodeError:
                    continue
    except Exception:
        continue

print(f"{session_tokens} {weekly_tokens}")
EOF
}

# ==============================================================================
# Git Status
# ==============================================================================

get_git_status() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo ""
        return
    fi

    local branch=$(git branch --show-current 2>/dev/null || echo "detached")
    local status=""

    # Check if dirty
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        status="${MAGENTA}${branch}*${RESET}"
    else
        status="${MAGENTA}${branch}${RESET}"
    fi

    # Check unpushed commits
    local unpushed=$(git log @{u}.. --oneline 2>/dev/null | wc -l || echo 0)
    if [[ $unpushed -gt 0 ]]; then
        status="${status} ${CYAN}↑${unpushed}${RESET}"
    fi

    echo "on $status"
}

# ==============================================================================
# Main Display
# ==============================================================================

main() {
    # Try to use cache
    if is_cache_valid; then
        cat "$CACHE_FILE"
        return
    fi

    # Acquire lock for cache update (macOS compatible)
    if ! mkdir "$CACHE_LOCK" 2>/dev/null; then
        # Another process is updating, use cached data if available
        [[ -f "$CACHE_FILE" ]] && cat "$CACHE_FILE" || echo -e "${CYAN}$(basename "$PWD")${RESET} ${GRAY}|${RESET} calculating..."
        return
    fi

    # Ensure lock is cleaned up
    trap "rmdir '$CACHE_LOCK' 2>/dev/null" EXIT

    # Read stdin from Claude Code
    local stdin_data=$(cat)

        # Get current directory
        local cwd=$(echo "$stdin_data" | jq -r '.workspace.current_dir // env.PWD' 2>/dev/null || pwd)
        local dir_name=$(basename "$cwd")

        # Calculate usage
        read -r session_tokens weekly_tokens < <(calculate_usage)

        # Get limits
        read -r session_limit weekly_limit < <(get_limits "$PLAN")

        # Calculate percentages
        local session_pct=$(awk "BEGIN {printf \"%.0f\", ($session_tokens / $session_limit) * 100}")
        local weekly_pct=$(awk "BEGIN {printf \"%.0f\", ($weekly_tokens / $weekly_limit) * 100}")

        # Get colors
        local session_color=$(get_color "$session_pct")
        local weekly_color=$(get_color "$weekly_pct")

        # Format usage
        local session_display="${session_color}S:${session_pct}%${RESET}"
        local weekly_display="${weekly_color}W:${weekly_pct}%${RESET}"

        # Build status line
        local output=""

        # Add directory
        output="${CYAN}${dir_name}${RESET}"

        # Add git status if enabled
        if [[ "${SHOW_GIT:-true}" == "true" ]]; then
            local git_status=$(get_git_status)
            if [[ -n "$git_status" ]]; then
                output="$output $git_status"
            fi
        fi

        # Add usage
        output="$output ${GRAY}|${RESET} $session_display $weekly_display"

        # Add raw numbers in gray
        local session_fmt=$(format_number "$session_tokens")
        local weekly_fmt=$(format_number "$weekly_tokens")
        output="$output ${GRAY}(${session_fmt}/${weekly_fmt})${RESET}"

    # Output and cache
    echo -e "$output" | tee "$CACHE_FILE"

    # Clean up lock
    rmdir "$CACHE_LOCK" 2>/dev/null
}

main
