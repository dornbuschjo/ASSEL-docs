#!/usr/bin/env bash
set -euo pipefail

# --------
# Config
# --------
DIRENV_BIN="${HOME}/.local/bin/direnv"
DIRENV_CONFIG_DIR="${HOME}/.config/direnv"
DIRENV_TOML="${DIRENV_CONFIG_DIR}/direnv.toml"
BASHRC="${HOME}/.bashrc"

# Detect architecture for downloading direnv binary
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64) DIRENV_ASSET="direnv.linux-amd64" ;;
  aarch64|arm64) DIRENV_ASSET="direnv.linux-arm64" ;;
  *)
    echo "Unsupported architecture: ${ARCH}"
    echo "Please install direnv another way, or add a mapping for your arch."
    exit 1
    ;;
esac

# --------
# 1) Install direnv locally (no sudo)
# --------
mkdir -p "${HOME}/.local/bin"

if [[ ! -x "${DIRENV_BIN}" ]]; then
  echo "[1/4] Installing direnv to ${DIRENV_BIN}"
  curl -L -o "${DIRENV_BIN}" \
    "https://github.com/direnv/direnv/releases/latest/download/${DIRENV_ASSET}"
  chmod +x "${DIRENV_BIN}"
else
  echo "[1/4] direnv already exists at ${DIRENV_BIN} (skipping download)"
fi

# Ensure ~/.local/bin is on PATH (append if missing)
if ! grep -q 'export PATH="\$HOME/.local/bin:\$PATH"' "${BASHRC}" 2>/dev/null; then
  echo "[1/4] Adding ~/.local/bin to PATH in ${BASHRC}"
  {
    echo ""
    echo '# Added for local tools (direnv, etc.)'
    echo 'export PATH="$HOME/.local/bin:$PATH"'
  } >> "${BASHRC}"
else
  echo "[1/4] ~/.local/bin PATH line already present in ${BASHRC}"
fi

# --------
# 2) Configure direnv to hide the noisy env diff
# --------
mkdir -p "${DIRENV_CONFIG_DIR}"

if [[ ! -f "${DIRENV_TOML}" ]]; then
  echo "[2/4] Creating ${DIRENV_TOML}"
  cat > "${DIRENV_TOML}" <<'EOF'
[global]
hide_env_diff = true
EOF
else
  # Ensure hide_env_diff=true exists
  if ! grep -q 'hide_env_diff\s*=\s*true' "${DIRENV_TOML}"; then
    echo "[2/4] Updating ${DIRENV_TOML} to enable hide_env_diff"
    # If [global] exists, insert under it; otherwise append a new block.
    if grep -q '^\[global\]' "${DIRENV_TOML}"; then
      # Insert right after [global]
      awk '
        BEGIN{done=0}
        /^\[global\]$/{
          print
          print "hide_env_diff = true"
          done=1
          next
        }
        {print}
        END{
          if(done==0){
            print ""
            print "[global]"
            print "hide_env_diff = true"
          }
        }' "${DIRENV_TOML}" > "${DIRENV_TOML}.tmp"
      mv "${DIRENV_TOML}.tmp" "${DIRENV_TOML}"
    else
      {
        echo ""
        echo "[global]"
        echo "hide_env_diff = true"
      } >> "${DIRENV_TOML}"
    fi
  else
    echo "[2/4] ${DIRENV_TOML} already has hide_env_diff=true"
  fi
fi

# --------
# 3) Append Pixi+direnv integration block to ~/.bashrc (idempotent)
# --------
BLOCK_BEGIN="# >>> pixi  >>>"
BLOCK_END="# <<< pixi  <<<"

if grep -qF "${BLOCK_BEGIN}" "${BASHRC}" 2>/dev/null; then
  echo "[3/4] Pixi/direnv bashrc block already present (skipping)"
else
  echo "[3/4] Appending Pixi/direnv bashrc block to ${BASHRC}"
  cat >> "${BASHRC}" <<'EOF'

# >>> pixi  >>>
# Show Pixi prompt prefix if active (works with direnv)
__pixi_prompt() {
  if [[ -n "${PIXI_IN_SHELL:-}" ]]; then
    # PIXI_PROMPT is like "(AAPL) "
    printf "%s" "${PIXI_PROMPT:-}"
  fi
}

# Prepend Pixi prompt to PS1; keep existing PS1 intact
if [[ $PS1 == *'__pixi_prompt'* ]]; then
  : # already installed
else
  PS1='$(__pixi_prompt)'"$PS1"
fi

# Enable direnv in bash (loads .envrc on cd)
eval "$(direnv hook bash)"

# Optional: keep logs quiet (the noisy "export +... ~PATH" is handled by hide_env_diff=true)
export DIRENV_LOG_FORMAT=""
# <<< pixi  <<<
EOF
fi

# --------
# 4) Print next steps for project setup
# --------
echo "[4/4] Done."
echo ""
echo "Next steps:"
echo "1) Restart your terminal (or run: source ~/.bashrc)"
echo "2) In each Pixi project, create a .envrc with:"
echo "   watch_file pixi.lock"
echo "   eval \"\$(pixi shell-hook)\""
echo "3) In that project folder run: direnv allow"
echo ""
echo "Tip: In VS Code, open the integrated terminal in the project folder."
echo "direnv will auto-activate Pixi when you are inside the folder and unload it when you leave."