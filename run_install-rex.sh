#!/usr/bin/env bash
# Rex on Linux (the terminal on Hyper+Enter). Rex is a closed beta whose download
# link must never be in this public repo, so this asks for it. Runs on every apply
# (no run_once) but exits at once when ~/.local/bin/rex exists, so it only asks
# until Rex is installed; Enter skips until the next apply.
# Rex lands in ~/.local/bin/rex either way, which is what Hyprland's mod+Return
# runs. Handles a single binary or AppImage (AppImages also need fuse2) and a
# tarball; anything else gets a message to install it by hand.

[[ "$(uname -s)" == "Linux" ]] || exit 0
[[ -x "$HOME/.local/bin/rex" ]] && exit 0

REX_URL=""
read -r -p "Rex download URL for Linux (from the beta invite; Enter skips): " REX_URL < /dev/tty 2>/dev/null || true
if [[ -z "$REX_URL" ]]; then
  echo "Rex not installed: Hyper+Enter needs ~/.local/bin/rex. The next chezmoi apply asks again." >&2
  exit 0
fi

mkdir -p "$HOME/.local/bin"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$REX_URL" -o "$tmp/rex.download" || { echo "Rex download failed. Rerun chezmoi apply." >&2; exit 0; }

kind=$(file -b "$tmp/rex.download")
case "$kind" in
  *ELF*)   # a single binary or an AppImage
    install -m 755 "$tmp/rex.download" "$HOME/.local/bin/rex" ;;
  *gzip*|*XZ*|*Zstandard*|*bzip2*|*tar\ archive*)
    rm -rf "$HOME/.local/opt/rex" && mkdir -p "$HOME/.local/opt/rex" \
      && tar -xf "$tmp/rex.download" -C "$HOME/.local/opt/rex"
    bin=$(find "$HOME/.local/opt/rex" -type f -perm -u+x -iname rex | head -1)
    if [[ -n "$bin" ]]; then
      ln -sf "$bin" "$HOME/.local/bin/rex"
    else
      echo "Rex: unpacked to ~/.local/opt/rex, but no 'rex' executable in it. Link it to ~/.local/bin/rex by hand." >&2
    fi ;;
  *)
    echo "Rex: unexpected download ($kind). Install it by hand so ~/.local/bin/rex runs it." >&2 ;;
esac
[[ -x "$HOME/.local/bin/rex" ]] && echo "Rex installed: ~/.local/bin/rex"
exit 0
