#!/bin/bash
# Notification hook. Linux desktop notification, else macOS, else a Windows
# toast through WSL interop, else a terminal bell. Never fails the caller.

msg=$(cat | jq -r '.message // empty' 2>/dev/null)
[ -z "$msg" ] && msg="Claude Code needs your attention"

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Claude Code" "$msg"
  exit 0
fi

if command -v osascript >/dev/null 2>&1; then
  # The message lands inside an AppleScript string literal.
  esc=${msg//\\/\\\\}
  esc=${esc//\"/\\\"}
  osascript -e "display notification \"$esc\" with title \"Claude Code\"" >/dev/null 2>&1
  exit 0
fi

if command -v powershell.exe >/dev/null 2>&1; then
  # The message lands inside a PowerShell string and then inside toast XML.
  esc=${msg//\"/\'}
  esc=${esc//&/ and }
  esc=${esc//</(}
  esc=${esc//>/)}

  # This AppId is the registered Windows Powershell shortcut. A toast needs an
  # AppId that already exists in the notification registry, or it is dropped.
  ps=$(cat <<PS
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] | Out-Null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType=WindowsRuntime] | Out-Null
\$AppId = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"
\$t = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
\$x = \$t.GetElementsByTagName("text")
\$x.Item(0).AppendChild(\$t.CreateTextNode("Claude Code")) | Out-Null
\$x.Item(1).AppendChild(\$t.CreateTextNode("$esc")) | Out-Null
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier(\$AppId).Show([Windows.UI.Notifications.ToastNotification]::new(\$t))
[console]::beep(880,200)
PS
)
  enc=$(printf '%s' "$ps" | iconv -f UTF-8 -t UTF-16LE | base64 -w0)
  powershell.exe -NoProfile -EncodedCommand "$enc" >/dev/null 2>&1
  exit 0
fi

printf '\a'
exit 0
