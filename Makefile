# Realethia local development bootstrap
#
# Typical first-time setup:
#   git clone https://github.com/realethia/realethia-start.git
#   cd realethia-start
#   make setup

export REALETHIA_WORKSPACE ?= $(abspath $(CURDIR)/..)
SCRIPT_DIR := $(CURDIR)/scripts

.PHONY: help setup check clone bootstrap workspace workspace-open \
	dev-ethia dev-dashboard dev-app dev-all status

help:
	@echo "Realethia dev bootstrap — workspace: $(REALETHIA_WORKSPACE)"
	@echo ""
	@echo "  make setup            Clone all repos + bootstrap local-dev stack"
	@echo "  make check            Verify prerequisites (git, docker, go, node, ...)"
	@echo "  make clone            Clone/update all repos from repos.yaml"
	@echo "  make bootstrap        Prepare local-dev repos (npm, ethia stack)"
	@echo "  make workspace        Regenerate realethia.code-workspace"
	@echo "  make workspace-open   Open multi-root workspace in Cursor/VS Code"
	@echo ""
	@echo "  make dev-ethia        Start Ethia (if not running)"
	@echo "  make dev-dashboard    Mock API + Next.js dashboard"
	@echo "  make dev-app          Expo mobile app"
	@echo "  make dev-all          Print commands to run full local stack"
	@echo "  make status           Show clone state of each repo"

setup: check clone bootstrap workspace
	@echo ""
	@echo "Setup complete. Open: make workspace-open"

check:
	@bash "$(SCRIPT_DIR)/check-prereqs.sh"

clone:
	@bash "$(SCRIPT_DIR)/clone-repos.sh"

bootstrap:
	@bash "$(SCRIPT_DIR)/bootstrap.sh"

bootstrap-env-only:
	@bash "$(SCRIPT_DIR)/bootstrap.sh" --skip-ethia-build

workspace:
	@bash "$(SCRIPT_DIR)/generate-workspace.sh"

workspace-open: workspace
	@cursor "$(CURDIR)/realethia.code-workspace" 2>/dev/null \
		|| code "$(CURDIR)/realethia.code-workspace" 2>/dev/null \
		|| echo "Open manually: $(CURDIR)/realethia.code-workspace"

dev-ethia:
	@test -d "$(REALETHIA_WORKSPACE)/ethia" || (echo "Run: make clone" && exit 1)
	cd "$(REALETHIA_WORKSPACE)/ethia" && make start

dev-dashboard:
	@test -d "$(REALETHIA_WORKSPACE)/realethia-dashboard" || (echo "Run: make clone" && exit 1)
	@echo "Start mock API in one terminal: cd realethia-dashboard && npm run mock"
	@echo "Start frontend in another:       cd realethia-dashboard && npm run dev"
	cd "$(REALETHIA_WORKSPACE)/realethia-dashboard" && npm run mock &
	cd "$(REALETHIA_WORKSPACE)/realethia-dashboard" && npm run dev

dev-app:
	@test -d "$(REALETHIA_WORKSPACE)/realethia-app" || (echo "Run: make clone" && exit 1)
	cd "$(REALETHIA_WORKSPACE)/realethia-app" && npx expo start

dev-all:
	@echo "# Full local stack (run in separate terminals):"
	@echo ""
	@echo "# 1. Ethia backend (Docker Compose)"
	@echo "cd $(REALETHIA_WORKSPACE)/ethia && make build-start"
	@echo "#   Console: http://localhost:8080"
	@echo ""
	@echo "# 2. Dashboard mock API"
	@echo "cd $(REALETHIA_WORKSPACE)/realethia-dashboard && npm run mock"
	@echo "#   API: http://localhost:3001"
	@echo ""
	@echo "# 3. Dashboard frontend"
	@echo "cd $(REALETHIA_WORKSPACE)/realethia-dashboard && npm run dev"
	@echo "#   Web: http://localhost:4000"
	@echo ""
	@echo "# 4. Mobile app (optional)"
	@echo "cd $(REALETHIA_WORKSPACE)/realethia-app && npx expo start"

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
