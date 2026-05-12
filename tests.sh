#!/usr/bin/env bash

set -euo pipefail

CF_LOG=/tmp/cloudflared.log

echo "Fetching Cloudflare URL..."

CF_URL=$(grep -o 'https://[-a-zA-Z0-9]*\.trycloudflare\.com' "$CF_LOG" | head -n 1 || true)

if [[ -z "$CF_URL" ]]; then
  echo "Failed to retrieve Cloudflare URL"
  exit 1
fi

WEBHOOK_URL="${CF_URL}/webhook-test/5489989a-44c4-4f9b-82ed-ccb0c0542354"

PAYLOAD='{"message":"Are you functioning within normal parameters?"}'

echo "Sending request to:"
echo "$WEBHOOK_URL"
echo "--------------------------------------"

curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"

echo ""
echo "Done."
