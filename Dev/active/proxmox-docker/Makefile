.PHONY: help setup build run test clean logs shell logs-clean

help:
	@echo "Proxmox Docker Platform - Available Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup              - Initial setup (create .env, build image)"
	@echo "  make build              - Build Docker image"
	@echo "  make rebuild            - Rebuild Docker image (no cache)"
	@echo ""
	@echo "Running:"
	@echo "  make up                 - Start services in background"
	@echo "  make down               - Stop and remove services"
	@echo "  make ps                 - Show running containers"
	@echo ""
	@echo "Testing:"
	@echo "  make test               - Test Proxmox connection"
	@echo "  make health             - Run health checks"
	@echo "  make selftest           - Run comprehensive self-test"
	@echo ""
	@echo "Commands:"
	@echo "  make node-list          - List Proxmox nodes"
	@echo "  make vm-list            - List VMs"
	@echo "  make status             - Show cluster status"
	@echo "  make shell              - Interactive bash shell"
	@echo "  make python             - Interactive Python REPL"
	@echo ""
	@echo "Utilities:"
	@echo "  make logs               - View container logs"
	@echo "  make logs-tail          - Tail logs (follow mode)"
	@echo "  make logs-clean         - Clear log files"
	@echo "  make clean              - Remove containers and logs"
	@echo "  make clean-all          - Remove everything (images, volumes)"
	@echo ""

setup:
	@echo "Running initial setup..."
	@which bash > /dev/null && bash setup.sh || cmd /c setup.bat
	@echo "Setup complete!"

build:
	docker-compose build

rebuild:
	docker-compose build --no-cache

up:
	docker-compose up -d
	@echo "Services started. Run 'make logs' to view logs."

down:
	docker-compose down

ps:
	docker-compose ps

test:
	docker-compose run --rm proxmox-platform selftest

health:
	docker-compose run --rm proxmox-platform health

selftest:
	docker-compose run --rm proxmox-platform pxmgr selftest --verbose

node-list:
	docker-compose run --rm proxmox-platform node list

vm-list:
	docker-compose run --rm proxmox-platform vm list

status:
	docker-compose run --rm proxmox-platform status

shell:
	docker-compose run --rm -it proxmox-platform shell

python:
	docker-compose run --rm -it proxmox-platform python

logs:
	docker-compose logs proxmox-platform

logs-tail:
	docker-compose logs -f proxmox-platform

logs-clean:
	rm -rf logs/*
	mkdir -p logs
	@echo "Logs cleared"

clean: down logs-clean
	@echo "Containers and logs cleaned"

clean-all: clean
	docker-compose down -v --rmi all
	@echo "All Docker artifacts removed"

# Development/debugging targets
.PHONY: debug bash-debug validate

debug:
	docker-compose run --rm -it proxmox-platform bash -x /usr/local/bin/docker-entrypoint.sh

bash-debug:
	docker-compose run --rm -it --entrypoint /bin/bash proxmox-platform

validate:
	@echo "Validating setup..."
	@docker-compose run --rm proxmox-platform pxmgr selftest --verbose
	@echo "Validation complete!"
