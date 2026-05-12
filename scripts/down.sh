#!/usr/bin/env bash

set -euo pipefail

echo "Stopping n8n..."

docker compose down

if [[ -f /tmp/cloudflared.pid ]]; then
  PID=$(cat /tmp/cloudflared.pid)

  if kill -0 "$PID" 2>/dev/null; then
    echo "Stopping Cloudflared..."
    kill "$PID"
  fi

  rm -f /tmp/cloudflared.pid
fi

echo "Done."
