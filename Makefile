GH_USER=deild
GH_REPO=photography-gear
V_MAJEURE=0
V_MINEURE=1
V_CORRECTIF=0
V_PREFIX=v
VERSION=${V_PREFIX}${V_MAJEURE}.${V_MINEURE}.${V_CORRECTIF}

# use https://github.com/git-chglog/git-chglog
changelog:
	git-chglog -o CHANGELOG.md --silent --next-tag ${VERSION}

# use https://github.com/deild/gothub
edit-release:
	gothub edit \
    --user ${GH_USER} \
    --repo ${GH_REPO} \
    --tag ${VERSION} \
    --name ${VERSION} \
    --description "$(git-chglog --silent ${VERSION})"
