.PHONY: up down logs rebuild ps

up:
	./scripts/up.sh

down:
	./scripts/down.sh

logs:
	@trap 'exit 0' INT; docker compose logs -f n8n

rebuild:
	docker compose down
	docker compose build --no-cache
	docker compose up -d

ps:
	docker compose ps
