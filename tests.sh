#!/usr/bin/env bash

set -euo pipefail

# Paste the FULL webhook URL from n8n here
WEBHOOK_URL="https://rings-larger-con-gonna.trycloudflare.com/webhook-test/5489989a-44c4-4f9b-82ed-ccb0c0542354"

# Simple test payload
PAYLOAD='{"test":"hello from curl"}'

echo "Sending request to:"
echo "$WEBHOOK_URL"
echo "--------------------------------------"

curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD"

echo ""
echo "Done."
