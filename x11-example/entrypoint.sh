#!/bin/bash
set -eu

export DISPLAY=:1

# A restarted container keeps its filesystem, so clear the previous X server's lock.
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

if [ -n "${VNC_PASSWORD:-}" ]; then
  mkdir -p "$HOME/.vnc"
  (umask 077 && vncpasswd -f <<<"$VNC_PASSWORD" > "$HOME/.vnc/passwd")
  auth=(-SecurityTypes VncAuth -PasswordFile "$HOME/.vnc/passwd")
else
  auth=(-SecurityTypes None)
fi

# Stop every process when the container stops or when any one of them exits.
trap 'exit 0' TERM INT
trap 'kill $(jobs -p) 2>/dev/null || true' EXIT

# -localhost keeps raw VNC private to the container; only noVNC is reachable.
Xvnc "$DISPLAY" -geometry "$VNC_RESOLUTION" -depth 24 -rfbport 5901 -localhost "${auth[@]}" &

for _ in $(seq 50); do
  [ -S /tmp/.X11-unix/X1 ] && break
  sleep 0.1
done

openbox-session &
websockify --web=/usr/share/novnc 6080 127.0.0.1:5901 &

wait -n
