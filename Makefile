GH_USER := deild
GH_REPO := photography-gear
V_MAJEURE := 0
V_MINEURE := 1
V_CORRECTIF := 1
V_PREFIX := v
VERSION := $(V_PREFIX)$(V_MAJEURE).$(V_MINEURE).$(V_CORRECTIF)

# use https://github.com/git-chglog/git-chglog
.PHONY: changelog
changelog:
	git-chglog -o CHANGELOG.md --silent --next-tag $(VERSION)
	git add CHANGELOG.md

.PHONY: pre-release
pre-release: changelog
	git commit -m "chore(release): $(VERSION)" 

# use https://github.com/deild/gothub
.PHONY: post-release
post-release:
	gothub edit \
    --user $(GH_USER) \
    --repo $(GH_REPO) \
    --tag $(VERSION) \
    --name $(VERSION) \
	--description "$$(git-chglog --silent $(VERSION))"

