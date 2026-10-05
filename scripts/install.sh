#!/bin/bash
# Set up this config on a new device. Safe to re-run: every step is idempotent.
# Installs what it can without sudo, and prints the command for anything else.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
REPO=$(pwd)
BLOCKERS=0

say()   { printf '  %-12s %s\n' "$1" "$2"; }
block() { say "$1" "MISSING  -> $2"; BLOCKERS=$((BLOCKERS + 1)); }
have()  { command -v "$1" >/dev/null 2>&1; }

# Reason: the install command differs per platform, and wrong advice is worse
# than none.
pkg() {
  if   have brew;    then echo "brew install $1"
  elif have apt-get; then echo "sudo apt install -y $1"
  elif have dnf;     then echo "sudo dnf install -y $1"
  elif have pacman;  then echo "sudo pacman -S --noconfirm $1"
  elif have zypper;  then echo "sudo zypper install -y $1"
  else               echo "install $1 with your package manager"
  fi
}

if [ "$REPO" != "$HOME/.claude" ]; then
  echo "This repo must live at ~/.claude, not $REPO." >&2
  echo "Claude Code reads ~/.claude directly; a copy elsewhere drifts." >&2
  exit 1
fi

echo "Tools"
for t in git jq; do
  have "$t" && say "$t" "present" || block "$t" "$(pkg "$t")"
done
for t in gh rg; do
  have "$t" && say "$t" "present" || say "$t" "absent (optional)"
done

if have node && have npm; then
  say "node/npm" "present  $(node -v) / npm $(npm -v)"
else
  block "node/npm" "install Node 20 or newer, then re-run"
fi

if have uvx; then
  say "uv" "present"
elif have curl; then
  say "uv" "installing..."
  curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1
  have uvx && say "uv" "installed" || block "uv" "curl -LsSf https://astral.sh/uv/install.sh | sh"
else
  block "uv" "curl -LsSf https://astral.sh/uv/install.sh | sh"
fi

rtk_asset() {
  case "$1/$2" in
    Linux/x86_64)                 echo rtk-x86_64-unknown-linux-musl.tar.gz ;;
    Linux/aarch64 | Linux/arm64)  echo rtk-aarch64-unknown-linux-gnu.tar.gz ;;
    Darwin/x86_64)                echo rtk-x86_64-apple-darwin.tar.gz ;;
    Darwin/arm64)                 echo rtk-aarch64-apple-darwin.tar.gz ;;
    MINGW*/x86_64 | MSYS*/x86_64 | CYGWIN*/x86_64) echo rtk-x86_64-pc-windows-msvc.zip ;;
    *) return 1 ;;
  esac
}

sha256() {
  if have sha256sum; then sha256sum "$1"
  elif have shasum;  then shasum -a 256 "$1"
  else return 1
  fi | cut -d' ' -f1
}

# Reason: the subshell runs the EXIT trap, so the temp folder is removed on every path.
install_rtk() (
  asset=$(rtk_asset "$(uname -s)" "$(uname -m)") || exit 1
  url=https://github.com/rtk-ai/rtk/releases/latest/download
  tmp=$(mktemp -d) || exit 1
  trap 'rm -rf "$tmp"' EXIT
  curl -fsSL "$url/$asset" -o "$tmp/$asset" || exit 1
  curl -fsSL "$url/checksums.txt" -o "$tmp/checksums.txt" || exit 1
  want=$(awk -v a="$asset" '$2 == a { print $1 }' "$tmp/checksums.txt")
  [ -n "$want" ] && [ "$want" = "$(sha256 "$tmp/$asset")" ] || exit 1
  case "$asset" in
    *.zip) unzip -oq "$tmp/$asset" -d "$tmp" && bin=rtk.exe ;;
    *)     tar -xzf "$tmp/$asset" -C "$tmp" && bin=rtk ;;
  esac || exit 1
  mkdir -p "$HOME/.local/bin" && install -m 755 "$tmp/$bin" "$HOME/.local/bin/$bin"
)

# Reason: crates.io `rtk` is a different tool, and only the right one has `rtk gain`.
if have rtk && rtk gain >/dev/null 2>&1; then
  say "rtk" "present"
elif have rtk; then
  block "rtk" "a different program named rtk is on PATH; remove it, then re-run"
elif have brew; then
  say "rtk" "installing with brew..."
  brew install rtk >/dev/null 2>&1 && say "rtk" "installed" || block "rtk" "brew install rtk"
elif have curl && install_rtk; then
  have rtk && say "rtk" "installed to ~/.local/bin" ||
    block "rtk" "installed to ~/.local/bin, which is not on PATH; add it to PATH"
else
  block "rtk" "download a build from https://github.com/rtk-ai/rtk/releases into ~/.local/bin"
fi

if have notify-send || have powershell.exe; then
  say "notify" "present"
else
  say "notify" "absent — the hook falls back to a terminal bell"
fi

echo
echo "Permissions"
chmod +x hooks/*.sh statusline-command.sh scripts/*.sh 2>/dev/null
say "chmod +x" "hooks, status line, scripts"

echo
echo "Check"
if have jq; then
  out=$(printf '%s' '{"tool_input":{"command":"ls"}}' | ./hooks/block-dangerous-git.sh 2>&1; echo "rc=$?")
  case "$out" in
    *rc=0*) say "git guard" "allows a safe command" ;;
    *)      say "git guard" "FAILED: $out"; BLOCKERS=$((BLOCKERS + 1)) ;;
  esac
  out=$(printf '%s' '{"tool_input":{"command":"git reset --hard"}}' | ./hooks/block-dangerous-git.sh 2>&1; echo "rc=$?")
  case "$out" in
    *rc=2*) say "git guard" "blocks git reset --hard" ;;
    *)      say "git guard" "FAILED to block: $out"; BLOCKERS=$((BLOCKERS + 1)) ;;
  esac
fi
if have rtk; then
  out=$(printf '%s' '{"tool_input":{"command":"git status"}}' | rtk hook claude 2>&1)
  case "$out" in
    *'rtk git status'*) say "rtk hook" "rewrites git status" ;;
    *)                  say "rtk hook" "FAILED: $out"; BLOCKERS=$((BLOCKERS + 1)) ;;
  esac
fi

echo
./scripts/probe-context-floor.sh
case $? in
  0|2) ;;
  *)   BLOCKERS=$((BLOCKERS + 1)) ;;
esac

echo
if [ "$BLOCKERS" -eq 0 ]; then
  echo "Ready. Restart Claude Code so it loads settings, CLAUDE.md, rules, and the style."
else
  echo "$BLOCKERS blocker(s) above. Fix them, then re-run this script."
  exit 1
fi
