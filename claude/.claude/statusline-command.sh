#!/bin/bash
# StatusLine for Claude Code - based on zsh prompt configuration
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

battery_status() {
  [[ "$(uname)" != "Darwin" ]] && return
  [[ $(sysctl -n hw.model 2>/dev/null) == *"Book"* ]] || return
  local battstat=$(pmset -g batt 2>/dev/null)
  local time_left=$(echo "$battstat" | tail -1 | cut -f2 | awk -F"; " '{print $3}' | cut -d' ' -f1)
  local emoji=$([[ $(pmset -g ac 2>/dev/null) == *"No adapter"* ]] && echo '🔋' || echo '🔌')
  [[ $time_left == *"(no"* || $time_left == *"not"* ]] && time_left='⌛️ '
  [[ $time_left == *"0:00"* ]] && time_left='⚡️ '
  printf "\033[1;92m$emoji  $time_left \033[0m"
}

directory_name() { printf "\033[1;36m$(basename "$cwd")/\033[0m"; }

git_dirty() {
  git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1 || return
  local branch=$(git -C "$cwd" symbolic-ref HEAD 2>/dev/null | awk -F/ '{print $NF}')
  [[ -z "$branch" ]] && return
  local status=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  [[ -z "$status" ]] && printf "on \033[1;32m$branch\033[0m" || printf "on \033[1;31m$branch\033[0m"
}

need_push() {
  git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1 || return
  local branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return
  local n=$(git -C "$cwd" --no-optional-locks cherry -v origin/"$branch" 2>/dev/null | wc -l | xargs)
  [[ "$n" -gt 0 ]] && printf " with \033[1;35m$n unpushed\033[0m"
}

echo "$(battery_status)in $(directory_name) $(git_dirty)$(need_push)"
