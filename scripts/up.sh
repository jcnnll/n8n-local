#!/usr/bin/env bash
set -Eeuo pipefail

CF_LOG=/tmp/cloudflared.log
CF_PID=/tmp/cloudflared.pid

cleanup() {
  if [[ -f "$CF_PID" ]]; then
    PID=$(cat "$CF_PID" || true)

    if kill -0 "$PID" 2>/dev/null; then
      kill "$PID" || true
    fi

    rm -f "$CF_PID"
  fi
}

start_tunnel() {
  rm -f "$CF_LOG"

  nohup cloudflared tunnel \
    --url http://localhost:5678 \
    >"$CF_LOG" 2>&1 &

  echo $! >"$CF_PID"

  sleep 2

  PID=$(cat "$CF_PID")

  if ! kill -0 "$PID" 2>/dev/null; then
    echo "cloudflared exited immediately"
    cat "$CF_LOG"
    return 1
  fi
}

wait_for_url() {
  local url=""

  for _ in {1..30}; do

    # hard fail if cloudflared errored
    if grep -qE 'ERR|failed to unmarshal' "$CF_LOG"; then
      cat "$CF_LOG"
      return 1
    fi

    url=$(grep -oE 'https://[-a-zA-Z0-9]+\.trycloudflare\.com' "$CF_LOG" \
      | head -n1 || true)

    if [[ -n "$url" ]]; then
      echo "$url"
      return 0
    fi

    sleep 1
  done

  return 1
}

echo "Starting Cloudflare tunnel..."

cleanup

CF_URL=""

for attempt in {1..5}; do
  echo "Attempt $attempt..."

  if start_tunnel; then
    CF_URL=$(wait_for_url || true)

    if [[ -n "$CF_URL" ]]; then
      break
    fi
  fi

  cleanup
  sleep 3
done

if [[ -z "$CF_URL" ]]; then
  echo "Failed to create Cloudflare tunnel"
  exit 1
fi

echo "Tunnel URL: $CF_URL"

export WEBHOOK_URL="$CF_URL"
export N8N_EDITOR_BASE_URL="$CF_URL"
export N8N_BASE_URL="$CF_URL"

echo "Starting docker compose..."
docker compose up -d

echo ""
echo "n8n"
echo "  Local:  http://localhost:5678"
echo "  Public: $CF_URL"