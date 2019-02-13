GH_USER := deild
GH_REPO := photography-gear
V_MAJEURE := 0
V_MINEURE := 1
V_CORRECTIF := 2
V_PREFIX := v
VERSION := $(V_PREFIX)$(V_MAJEURE).$(V_MINEURE).$(V_CORRECTIF)

# use https://github.com/git-chglog/git-chglog
.PHONY: changelog 
changelog: ## génére le journal de modifications de la version
	git-chglog -o CHANGELOG.md --silent --next-tag $(VERSION)
	git add CHANGELOG.md

.PHONY: pre-release
pre-release: changelog ## génére et commit le journal de mofications de la version
	git commit -m "chore(release): $(VERSION)" 

# use https://github.com/deild/gothub
.PHONY: post-release
post-release: ## met à jour la release-note de la version
	gothub edit \
    --user $(GH_USER) \
    --repo $(GH_REPO) \
    --tag $(VERSION) \
    --name $(VERSION) \
	--description "$$(git-chglog --silent $(VERSION))"

.PHONY: version
version: ## affiche la version en cours 
	@echo $(VERSION)

help: ## Displays the description of each target (Default)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

