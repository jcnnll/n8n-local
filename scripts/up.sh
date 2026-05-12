#!/usr/bin/env bash

set -euo pipefail

CF_LOG=/tmp/cloudflared.log
CF_PID=/tmp/cloudflared.pid

echo "Starting Cloudflare tunnel..."

# Prevent duplicate processes
if [[ -f "$CF_PID" ]] && kill -0 "$(cat "$CF_PID")" 2>/dev/null; then
  echo "Cloudflared already running"
else
  nohup cloudflared tunnel --url http://localhost:5678 \
    >"$CF_LOG" 2>&1 &

  echo $! >"$CF_PID"

  sleep 5
fi

echo "Fetching Cloudflare tunnel URL..."

CF_URL=""

for i in {1..20}; do
  CF_URL=$(grep -o 'https://[-a-zA-Z0-9]*\.trycloudflare\.com' "$CF_LOG" | head -n 1 || true)

  if [[ -n "$CF_URL" ]]; then
    break
  fi

  sleep 1
done

if [[ -z "$CF_URL" ]]; then
  echo "Failed to retrieve Cloudflare URL"
  echo "Check logs: $CF_LOG"
  exit 1
fi

echo "Tunnel URL: ${CF_URL}"

echo "Starting n8n stack..."

WEBHOOK_URL="${CF_URL}" \
  N8N_EDITOR_BASE_URL="${CF_URL}" \
  docker compose up -d

echo ""
echo "n8n is running"
echo ""
echo "Local:"
echo "  http://localhost:5678"
echo ""
echo "Public:"
echo "  ${CF_URL}"
