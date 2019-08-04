GH_USER := deild
GH_REPO := photography-gear
BASE_STRING ?= $(shell cat VERSION)
V_MAJOR = $(shell echo $(BASE_STRING) | cut -d. -f1)
V_MINOR = $(shell echo $(BASE_STRING) | cut -d. -f2)
V_PATCH = $(shell echo $(BASE_STRING) | cut -d. -f3)
V_PREFIX := v
VERSION := $(V_PREFIX)$(BASE_STRING)

.PHONY: build
build: # utilisé pour construire le site
	@hugo --gc --minify --quiet

.PHONY: bump
bump: # incremente la version en fonction de bump=<patch|minor|major>
ifeq ($(bump),major)
    $(eval V_MAJOR := $(shell echo "$$(expr $(V_MAJOR) + 1)"))
    $(eval V_MINOR := 0)
    $(eval V_PATCH := 0)
else ifeq ($(bump),minor)
    $(eval V_MINOR := $(shell echo "$$(expr $(V_MINOR) + 1)"))
    $(eval V_PATCH := 0)
else
    $(eval V_PATCH := $(shell echo "$$(expr $(V_PATCH) + 1)"))
endif

# use https://github.com/git-chglog/git-chglog
.PHONY: prepare-release
prepare-release: build bump ## make release [bump=<patch|minor|major>] [commit=<hash>]
	$(eval VERSION := $(V_PREFIX)$(V_MAJOR).$(V_MINOR).$(V_PATCH))
	@git checkout -b release/$(VERSION) $(commit)
	@echo "$(V_MAJOR).$(V_MINOR).$(V_PATCH)" > VERSION
	@git add -- VERSION
	@git-chglog -o CHANGELOG.md --silent --next-tag $(VERSION)
	@git add -- CHANGELOG.md
	@git commit -m "chore(release): $(VERSION)"

# use https://github.com/deild/gothub
.PHONY: finish-release
finish-release: ## cloture la branche de publication, crée et publie le tag et la release
	@git checkout release/$(VERSION)
	@git tag -a $(VERSION) -m $(VERSION)
	@git checkout master
	@git merge release/$(VERSION)
	@git push --follow-tags origin master
	@gothub release \
    --user $(GH_USER) \
    --repo $(GH_REPO) \
    --tag $(VERSION) \
	--description "$$(git-chglog --silent $(VERSION))"
	@git branch -d release/$(VERSION)
	@echo '    [WARN] vous devez supprimer la branche distante si nécessaire, $$ git push origin :release/$(VERSION)'

.PHONY: version
version: ## affiche la version en cours
	@echo $(VERSION)

.PHONY: help
help: ## affiche la description de chaque cible (Defaut)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

