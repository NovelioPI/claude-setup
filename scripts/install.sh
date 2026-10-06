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

ALL_LANGS="python typescript go cpp kotlin dart"

usage() {
  cat <<EOF
Usage: scripts/install.sh [--lsp LANGS]

  --lsp LANGS   Install language servers and their Claude Code plugins.
                LANGS is a comma list of: ${ALL_LANGS// /, }; or "all".
                Without --lsp, no language server is installed.
EOF
}

LSP_LANGS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --lsp)     [ $# -ge 2 ] || { usage >&2; exit 1; }; LSP_LANGS=$2; shift 2 ;;
    --lsp=*)   LSP_LANGS=${1#--lsp=}; shift ;;
    -h|--help) usage; exit 0 ;;
    *)         echo "Unknown argument: $1" >&2; usage >&2; exit 1 ;;
  esac
done
[ "$LSP_LANGS" = all ] && LSP_LANGS=$ALL_LANGS
LSP_LANGS=${LSP_LANGS//,/ }
for lang in $LSP_LANGS; do
  case " $ALL_LANGS " in
    *" $lang "*) ;;
    *) echo "Unknown language: $lang" >&2; usage >&2; exit 1 ;;
  esac
done

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

NODE_MIN_MAJOR=20
node_major=$(node -v 2>/dev/null | sed 's/^v//; s/\..*//')
if have npm && [ "${node_major:-0}" -ge "$NODE_MIN_MAJOR" ] 2>/dev/null; then
  say "node/npm" "present  $(node -v) / npm $(npm -v)"
else
  block "node/npm" "install Node $NODE_MIN_MAJOR or newer, then re-run"
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

# Prints "<os> <arch>" in Go's naming, or fails on a platform with no builds.
platform() {
  case "$(uname -s)/$(uname -m)" in
    Linux/x86_64)                echo "linux amd64" ;;
    Linux/aarch64 | Linux/arm64) echo "linux arm64" ;;
    Darwin/x86_64)               echo "darwin amd64" ;;
    Darwin/arm64)                echo "darwin arm64" ;;
    MINGW*/x86_64 | MSYS*/x86_64 | CYGWIN*/x86_64) echo "windows amd64" ;;
    *) return 1 ;;
  esac
}

# Downloads $1 to $3 and fails unless its SHA256 equals $2.
fetch_checked() {
  [ -n "$2" ] && curl -fsSL "$1" -o "$3" && [ "$2" = "$(sha256 "$3")" ]
}

unpack() {
  case "$1" in
    *.zip) unzip -oq "$1" -d "$2" ;;
    *)     tar -xzf "$1" -C "$2" ;;
  esac
}

install_go() (
  plat=$(platform) || exit 1
  read -r os arch <<< "$plat"
  [ "$os" != windows ] || exit 1
  json=$(curl -fsSL 'https://go.dev/dl/?mode=json') || exit 1
  pick='.[0].files[] | select(.os == $o and .arch == $a and .kind == "archive")'
  file=$(jq -r --arg o "$os" --arg a "$arch" "$pick | .filename" <<< "$json")
  sum=$(jq -r --arg o "$os" --arg a "$arch" "$pick | .sha256" <<< "$json")
  tmp=$(mktemp -d) || exit 1
  trap 'rm -rf "$tmp"' EXIT
  fetch_checked "https://go.dev/dl/$file" "$sum" "$tmp/$file" || exit 1
  mkdir -p "$HOME/.local/bin" && unpack "$tmp/$file" "$HOME/.local" &&
    ln -sf "$HOME/.local/go/bin/go" "$HOME/.local/bin/go"
)

# Reason: the Windows build needs its own folder on PATH, so only Linux and macOS get a link.
install_clangd() (
  plat=$(platform) || exit 1
  read -r os _ <<< "$plat"
  [ "$os" != windows ] || exit 1
  [ "$os" = darwin ] && os=mac
  release=$(curl -fsSL https://api.github.com/repos/clangd/clangd/releases/latest) || exit 1
  version=$(jq -r .tag_name <<< "$release")
  file="clangd-$os-$version.zip"
  sum=$(jq -r --arg f "$file" '.assets[] | select(.name == $f) | .digest' <<< "$release")
  tmp=$(mktemp -d) || exit 1
  trap 'rm -rf "$tmp"' EXIT
  url="https://github.com/clangd/clangd/releases/download/$version/$file"
  fetch_checked "$url" "${sum#sha256:}" "$tmp/$file" || exit 1
  mkdir -p "$HOME/.local/bin" && unpack "$tmp/$file" "$HOME/.local" &&
    ln -sf "$HOME/.local/clangd_$version/bin/clangd" "$HOME/.local/bin/clangd"
)

# Reason: JetBrains ships macOS as a .sit archive, which this script cannot unpack.
install_kotlin() (
  plat=$(platform) || exit 1
  read -r os arch <<< "$plat"
  [ "$os" = linux ] || exit 1
  tag=$(curl -fsSL https://api.github.com/repos/Kotlin/kotlin-lsp/releases/latest | jq -r .tag_name) || exit 1
  version=${tag#kotlin-lsp/v}
  suffix=""
  [ "$arch" = arm64 ] && suffix="-aarch64"
  file="kotlin-server-$version$suffix.tar.gz"
  url="https://download.jetbrains.com/language-server/kotlin-server/$version/$file"
  sum=$(curl -fsSL "$url.sha256" | cut -d' ' -f1)
  tmp=$(mktemp -d) || exit 1
  trap 'rm -rf "$tmp"' EXIT
  fetch_checked "$url" "$sum" "$tmp/$file" || exit 1
  mkdir -p "$HOME/.local/bin" && unpack "$tmp/$file" "$HOME/.local" &&
    ln -sf "$HOME/.local/kotlin-server-$version/bin/intellij-server" "$HOME/.local/bin/kotlin-lsp"
)

npm_server() {
  local bin=$1
  shift
  if have "$bin"; then say "$bin" "present"; return 0; fi
  have npm || { block "$bin" "install Node and npm, then re-run"; return 1; }
  npm install -g "$@" >/dev/null 2>&1 && have "$bin" && say "$bin" "installed" ||
    { block "$bin" "npm install -g $*"; return 1; }
}

lsp_python()     { npm_server pyright-langserver pyright; }
lsp_typescript() { npm_server typescript-language-server typescript-language-server typescript; }

lsp_go() {
  if have gopls; then say "gopls" "present"; return 0; fi
  if ! have go; then
    if have brew; then brew install go >/dev/null 2>&1
    else install_go
    fi
    have go || { block "go" "install Go from https://go.dev/dl, then re-run"; return 1; }
  fi
  GOBIN="$HOME/.local/bin" go install golang.org/x/tools/gopls@latest >/dev/null 2>&1 &&
    have gopls && say "gopls" "installed" ||
    { block "gopls" "go install golang.org/x/tools/gopls@latest"; return 1; }
}

lsp_cpp() {
  if have clangd; then say "clangd" "present"; return 0; fi
  install_clangd && have clangd && say "clangd" "installed" ||
    { block "clangd" "download from https://github.com/clangd/clangd/releases and put clangd on PATH"; return 1; }
}

lsp_kotlin() {
  if have kotlin-lsp; then say "kotlin-lsp" "present"; return 0; fi
  install_kotlin && have kotlin-lsp && say "kotlin-lsp" "installed" ||
    { block "kotlin-lsp" "download from https://github.com/Kotlin/kotlin-lsp/releases and put it on PATH"; return 1; }
}

lsp_dart() {
  have dart && { say "dart" "present"; return 0; }
  block "dart" "install the Flutter or Dart SDK"
  return 1
}

plugin_for() {
  case "$1" in
    python)     echo pyright-lsp@claude-plugins-official ;;
    typescript) echo typescript-lsp@claude-plugins-official ;;
    go)         echo gopls-lsp@claude-plugins-official ;;
    cpp)        echo clangd-lsp@claude-plugins-official ;;
    kotlin)     echo kotlin-lsp@claude-plugins-official ;;
    dart)       echo dart-lsp@local-lsp ;;
  esac
}

if [ -n "$LSP_LANGS" ]; then
  echo
  echo "Language servers"
  # Reason: both commands do nothing when the marketplace or plugin is already present.
  if have claude; then
    claude plugin marketplace add anthropics/claude-plugins-official >/dev/null 2>&1
    claude plugin marketplace add "$REPO/lsp-plugins" >/dev/null 2>&1
  else
    say "plugins" "claude CLI not found; plugins are not installed"
  fi
  for lang in $LSP_LANGS; do
    "lsp_$lang" && have claude || continue
    plugin=$(plugin_for "$lang")
    claude plugin install "$plugin" >/dev/null 2>&1 && say "plugin" "$plugin" ||
      block "plugin" "claude plugin install $plugin"
  done
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
