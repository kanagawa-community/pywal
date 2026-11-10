# Window hook for .github/scripts/capture-windows.sh: foot replays the escape
# sequences that pywal writes for each theme, as pywal documents, then runs the
# shared session from docs/PREVIEWS.md.
# Requires: foot, pywal, fastfetch, eza.
# shellcheck shell=bash
name=pywal

launch() {
  local home="$work/wal-$1"
  mkdir -p "$home"
  HOME=$home XDG_CACHE_HOME=$home/.cache XDG_CONFIG_HOME=$home/.config \
    wal -q -n -s -t -e --theme "$root/themes/kanagawa-$1.json" >/dev/null
  printf '[main]\nfont=%s:size=11\npad=8x8\n' "$font" >"$work/foot-$1.ini"
  printf 'foot -c %s -T kanagawa sh -c "cat %s; exec %s %s"' \
    "$work/foot-$1.ini" "$home/.cache/wal/sequences" "$session" "$1"
}
