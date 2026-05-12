# n8n Lab (Local Automation Stack)

Local n8n automation environment with:

- Docker-based n8n + Postgres
- Cloudflare Tunnel for public webhooks
- Script-driven lifecycle management
- Optional Makefile shortcuts

Designed for:

- webhook testing
- API automation workflows
- local integration development
- freelance automation prototyping

## Requirements

- Docker
- cloudflared (Homebrew recommended on macOS)
- jq (used for tunnel URL extraction)

Optional:

- make (for convenience shortcuts)

## Platform Support

### macOS / Linux

Fully supported.

### Windows

Not supported natively.

Use **WSL2 (recommended)**:

- Docker Desktop with WSL2 backend
- Ubuntu or similar WSL distribution
- cloudflared installed inside WSL

## Usage

### Start the environment

#### Script-based (recommended)

```bash
./scripts/up.sh
```

This will:

- start Cloudflare tunnel
- start n8n + Postgres
- inject webhook + editor URLs
- output public webhook URL

#### Makefile (optional)

```bash
make up
```

### Stop the environment

#### Script

```bash
./scripts/down.sh
```

#### Make

```bash
make down
```

## Access

### Local UI

```
http://localhost:5678
```

### Public webhook URL

Provided at runtime by Cloudflare tunnel:

```
https://<random>.trycloudflare.com
```

## Webhook Testing

Example:

```bash
curl -X POST https://<cloudflare-url>/webhook/test-webhook \
  -H "Content-Type: application/json" \
  -d '{"test":"hello"}'
```

## Scripts

- `scripts/up.sh` → starts full stack + tunnel
- `scripts/down.sh` → stops everything
- `tests.sh` → manual webhook test helper (optional)

## Make Targets (optional)

```bash
make up      # start stack
make down    # stop stack
make logs    # view n8n logs
```

## Design Notes

- Postgres used for persistence
- Bind mounts used for local data visibility
- Cloudflare quick tunnel used for temporary public access
- Webhook URLs are injected at runtime (no manual editing)
- Minimal environment configuration

## Limitations

- Cloudflare quick tunnels are ephemeral (URL changes on restart)
- Not intended for production workloads
- Requires manual restart after dependency changes

## Future Enhancements (optional)

- Named Cloudflare Tunnel (stable URL)
- CI-style webhook testing suite
- reusable workflow templates
- OpenAI integration workflows
