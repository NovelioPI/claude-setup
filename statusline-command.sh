#!/bin/bash
# Claude Code status line: model, context window usage, and rate-limit usage
# (5-hour session limit and 7-day weekly limit) shown as progress bars.

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')
transcript_path=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
effort_level=$(printf '%s' "$input" | jq -r '.effort.level // empty')

used_ctx=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
five_pct=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_reset=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_reset=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

RESET="\033[0m"
DIM="\033[2m"

# Pick a shade of Claude's terracotta brand color based on how "full" a
# percentage is. All shades stay within the terracotta/orange family
# (no green/yellow/red stoplight semantics) -- intensity increases with fill.
color_for() {
  awk -v p="$1" 'BEGIN{
    if (p < 50) printf "\033[2;38;5;180m";      # muted/dim light terracotta
    else if (p < 80) printf "\033[2;38;5;173m"; # dim terracotta (brand-ish)
    else printf "\033[1;38;5;209m";             # bold brighter terracotta
  }'
}

# Build a filled/empty block-character progress bar for a 0-100 percentage.
make_bar() {
  local pct="$1"
  local width=20
  local filled
  filled=$(awk -v p="$pct" -v w="$width" 'BEGIN{
    v=(p/100)*w+0.5; if(v>w)v=w; if(v<0)v=0; printf "%d", v
  }')
  local empty=$((width - filled))
  local bar=""
  local i
  for ((i = 0; i < filled; i++)); do bar="${bar}█"; done
  for ((i = 0; i < empty; i++)); do bar="${bar}░"; done
  printf '%s' "$bar"
}

# Format a Unix epoch seconds value as a local-time string in the given `date`
# format. Tries GNU date (Linux, WSL, Git Bash / MSYS2 on Windows), then falls
# back to BSD date (macOS).
fmt_reset() {
  date -d "@$1" "+$2" 2>/dev/null || date -r "$1" "+$2" 2>/dev/null
}

# Format the timestamp as a short local clock time, e.g. "3:45 PM".
fmt_time() {
  fmt_reset "$1" "%l:%M %p" | sed 's/^ *//'
}

# Format the timestamp as a short local weekday, e.g. "Thu".
fmt_day() {
  fmt_reset "$1" "%a"
}

# Prompt-cache countdown: use the transcript file's last-modified time as a
# proxy for the last API turn, and count down from a 1-hour cache TTL.
CACHE_TTL=3600
cache_indicator=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  last_mtime=$(stat -f %m "$transcript_path" 2>/dev/null || stat -c %Y "$transcript_path" 2>/dev/null)
  if [ -n "$last_mtime" ]; then
    now=$(date +%s)
    remaining=$((CACHE_TTL - (now - last_mtime)))
    if [ "$remaining" -gt 0 ]; then
      mins=$((remaining / 60))
      secs=$((remaining % 60))
      cache_indicator="${DIM}◶ cache ${mins}m ${secs}s${RESET}"
    else
      cache_indicator="\033[1;38;5;209m◶ cache expired — run /compact${RESET}"
    fi
  fi
fi

# Reasoning-effort indicator: map effort level to a fill amount so it uses
# the same terracotta color scale as the other indicators.
effort_indicator=""
if [ -n "$effort_level" ]; then
  case "$effort_level" in
    low) effort_pct=15 ;;
    medium) effort_pct=40 ;;
    high) effort_pct=65 ;;
    xhigh) effort_pct=85 ;;
    max) effort_pct=100 ;;
    *) effort_pct=50 ;;
  esac
  ecolor=$(color_for "$effort_pct")
  effort_indicator="${ecolor}⚙ ${effort_level}${RESET}"
fi

lines=""

if [ -n "$used_ctx" ]; then
  color=$(color_for "$used_ctx")
  bar=$(make_bar "$used_ctx")
  lines="${lines}${DIM}▢ Ctx [${RESET}${color}${bar}${RESET}${DIM}] $(awk -v p="$used_ctx" 'BEGIN{printf "%.0f", p}')%${RESET}\n"
  if awk -v p="$used_ctx" 'BEGIN{exit !(p > 35)}'; then
    lines="${lines}${DIM}  ↳ consider running /compact${RESET}\n"
  fi
fi

if [ -n "$five_pct" ]; then
  color=$(color_for "$five_pct")
  bar=$(make_bar "$five_pct")
  reset_str=""
  if [ -n "$five_reset" ]; then
    reset_str=" (resets $(fmt_time "$five_reset"))"
  fi
  lines="${lines}${DIM}◷ 5h  [${RESET}${color}${bar}${RESET}${DIM}] $(awk -v p="$five_pct" 'BEGIN{printf "%.0f", p}')%${reset_str}${RESET}\n"
fi

if [ -n "$week_pct" ]; then
  color=$(color_for "$week_pct")
  bar=$(make_bar "$week_pct")
  reset_str=""
  if [ -n "$week_reset" ]; then
    reset_str=" (resets $(fmt_day "$week_reset") $(fmt_time "$week_reset"))"
  fi
  lines="${lines}${DIM}▤ 7d  [${RESET}${color}${bar}${RESET}${DIM}] $(awk -v p="$week_pct" 'BEGIN{printf "%.0f", p}')%${reset_str}${RESET}\n"
fi

if [ -z "$lines" ]; then
  lines="${DIM}(no usage data yet)${RESET}\n"
fi

header="${DIM}${model}${RESET}"
if [ -n "$effort_indicator" ]; then
  header="${header}  ${effort_indicator}"
fi
if [ -n "$cache_indicator" ]; then
  header="${header}  ${cache_indicator}"
fi

printf "%b\n\xe2\x80\x8b\n%b" "$header" "$lines"
