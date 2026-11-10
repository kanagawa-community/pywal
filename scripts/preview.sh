# Preview hook for .github/scripts/render-previews.sh: bash runs in a headless
# tmux pane and types the session from docs/PREVIEWS.md. bash does not highlight
# while typing, so only steps 1 and 3 run. termframe draws the capture with the
# variant's background, foreground and 16 terminal colors, the same roles that
# the pywal theme uses.
# Requires: bash, tmux, eza, fastfetch, rsync.
# shellcheck shell=bash
name=pywal

setup() {
  # The listing shows this repository's own files, copied into a fixed home
  # directory with one timestamp, so only the file names and sizes change.
  demo="$work/home/kanagawa-community/$(basename "$root")"
  mkdir -p "$demo"
  rsync -a --exclude=.git "$root"/ "$demo"/
  mkdir "$demo/.git"
  find "$demo" -exec touch -h -d '2026-11-07 11:13' {} +
}

cleanup() {
  tmux -L kanagawa-preview kill-server 2>/dev/null || true
}

send() {
  tmux -L kanagawa-preview send-keys -t s -l "$1"
  tmux -L kanagawa-preview send-keys -t s Enter
  sleep 0.7
}

capture() {
  cleanup
  sleep 0.5
  # User in green, host in blue, path in yellow, as in the fish port.
  ps1="\[\e[32m\]kanagawa\[\e[0m\]@\[\e[34m\]$1\[\e[0m\] \[\e[33m\]\w\[\e[0m\]\n❯ "
  tmux -L kanagawa-preview new-session -d -s s -x 100 -y 30 -c "$demo" \
    -e HOME="$work/home" -e USER=kanagawa -e COLORTERM=truecolor \
    -e TERM=xterm-256color -e LC_ALL=C.UTF-8 -e HISTFILE=/dev/null -e PS1="$ps1" \
    "bash --norc --noprofile"
  sleep 1
  send 'clear'
  send 'fastfetch -l none -s colors'
  send 'eza -alF --icons --group-directories-first --no-user'
  tmux -L kanagawa-preview capture-pane -p -e -t s >"$2"
}
