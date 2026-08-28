#!/bin/bash
msg=$(cat | jq -r '.message // "Claude Code needs your attention"')
osascript -e 'on run argv' -e 'display notification (item 1 of argv) with title "Claude Code"' -e 'end run' "$msg"
afplay /System/Library/Sounds/Ping.aiff &
