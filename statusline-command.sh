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

# Graft context-graph indicator: graph size, freshness, and the tokens the graph
# saved this session. Reason: the status line refreshes every second, so this
# reads the cache JSON directly instead of starting a node process per refresh.
graft_indicator=""
project_dir="${CLAUDE_PROJECT_DIR:-$(printf '%s' "$input" | jq -r '.workspace.project_dir // .cwd // empty')}"
graft_stats="$project_dir/graft/.cache/stats.json"
if [ -n "$project_dir" ] && [ -f "$graft_stats" ]; then
  IFS=$'\t' read -r g_nodes g_edges g_dirty g_stale g_syncing <<<"$(jq -r '[(.nodeCount//0),(.edgeCount//0),(.dirty//false),(.staleCount//0),(.syncing//false)]|@tsv' "$graft_stats" 2>/dev/null)"
  if [ -n "$g_nodes" ]; then
    if [ "$g_syncing" = "true" ]; then
      g_state="syncing"
    elif [ "$g_dirty" = "true" ] || [ "${g_stale:-0}" -gt 0 ]; then
      g_state="stale"
    else
      g_state="synced"
    fi

    session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')
    graft_session="$project_dir/graft/.cache/session/$session_id.json"
    g_saved=0
    if [ -n "$session_id" ] && [ -f "$graft_session" ]; then
      g_saved=$(jq -r '.savedTokens // 0' "$graft_session" 2>/dev/null)
    fi

    g_seg="◤ graft ${g_nodes}n/${g_edges}e · ${g_state}"
    if [ "${g_saved:-0}" -gt 0 ]; then
      g_saved_fmt=$(printf '%s' "$g_saved" | awk '{n=$1;s="";while(n>999){s=sprintf(",%03d",n%1000) s;n=int(n/1000)}printf "%d%s",n,s}')
      g_seg="${g_seg} · ~${g_saved_fmt} tok saved"
    fi

    if [ "$g_state" = "synced" ]; then
      gcolor="$DIM"
    else
      gcolor=$(color_for 85)
    fi
    graft_indicator="${gcolor}${g_seg}${RESET}"
  fi
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
if [ -n "$graft_indicator" ]; then
  header="${header}  ${graft_indicator}"
fi
if [ -n "$cache_indicator" ]; then
  header="${header}  ${cache_indicator}"
fi

printf "%b\n\xe2\x80\x8b\n%b" "$header" "$lines"
