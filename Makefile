# Realethia local development bootstrap
#
# Typical first-time setup:
#   git clone https://github.com/realethia/realethia-start.git
#   cd realethia-start
#   make setup
#   make start

export REALETHIA_WORKSPACE ?= $(abspath $(CURDIR)/..)
SCRIPT_DIR := $(CURDIR)/scripts
TARGET ?= ethia

.PHONY: help install setup check clone bootstrap start workspace workspace-open \
	dev-ethia dev-dashboard dev-app dev-all status

help:
	@echo "Realethia dev bootstrap — workspace: $(REALETHIA_WORKSPACE)"
	@echo ""
	@echo "  make install          Clone realethia-start (if needed), setup, open Cursor"
	@echo "  make setup            Clone repos, prepare deps and env files (no start)"
	@echo "  make start            Build and start local services (default: Ethia)"
	@echo "  make check            Verify prerequisites (git, docker, go, node, ...)"
	@echo "  make clone            Clone/update all repos from repos.yaml"
	@echo "  make bootstrap        Prepare all repos (npm, .env files)"
	@echo "  make workspace        Regenerate realethia.code-workspace"
	@echo "  make workspace-open   Open workspace + README (Cursor, else VS Code)"
	@echo ""
	@echo "  make dev-ethia        Start Ethia stack only (alias for: make start)"
	@echo "  make dev-dashboard    Mock API + Next.js dashboard"
	@echo "  make dev-app          Expo mobile app"
	@echo "  make dev-all          Print commands to run full local stack"
	@echo "  make status           Show clone state of each repo"

install:
	@bash "$(SCRIPT_DIR)/install.sh" "$(REALETHIA_WORKSPACE)"

setup: check clone bootstrap workspace
	@echo ""
	@echo "Setup complete (nothing started)."
	@echo "  make start          # build and start Ethia"
	@echo "  make workspace-open # open multi-root workspace"

check:
	@bash "$(SCRIPT_DIR)/check-prereqs.sh"

clone:
	@bash "$(SCRIPT_DIR)/clone-repos.sh"

bootstrap:
	@bash "$(SCRIPT_DIR)/bootstrap.sh"

start:
	@bash "$(SCRIPT_DIR)/start.sh" "$(TARGET)"

workspace:
	@bash "$(SCRIPT_DIR)/generate-workspace.sh"

workspace-open: workspace
	@REALETHIA_EDITOR=cursor bash "$(SCRIPT_DIR)/open-workspace.sh"

dev-ethia: start

dev-dashboard:
	@test -d "$(REALETHIA_WORKSPACE)/realethia-dashboard" || (echo "Run: make setup" && exit 1)
	@echo "Start mock API in one terminal: cd realethia-dashboard && npm run mock"
	@echo "Start frontend in another:       cd realethia-dashboard && npm run dev"
	cd "$(REALETHIA_WORKSPACE)/realethia-dashboard" && npm run mock &
	cd "$(REALETHIA_WORKSPACE)/realethia-dashboard" && npm run dev

dev-app:
	@test -d "$(REALETHIA_WORKSPACE)/realethia-app" || (echo "Run: make setup" && exit 1)
	cd "$(REALETHIA_WORKSPACE)/realethia-app" && npx expo start

dev-all:
	@bash "$(SCRIPT_DIR)/start.sh" all

status:
	@for repo in $$(awk '/^  - name:/ { print $$3 }' repos.yaml); do \
		path="$(REALETHIA_WORKSPACE)/$$repo"; \
		if [ -d "$$path/.git" ]; then \
			branch=$$(git -C "$$path" rev-parse --abbrev-ref HEAD 2>/dev/null); \
			printf "  %-28s %s (%s)\n" "$$repo" "cloned" "$$branch"; \
		else \
			printf "  %-28s %s\n" "$$repo" "missing"; \
		fi; \
	done
