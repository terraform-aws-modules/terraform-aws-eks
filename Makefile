.PHONY: changelog release

SEMTAG="tools/semtag"
TAG_QUERY="v10.0.1.."
scope ?= "minor"

changelog-unrelease:
	git-chglog -o CHANGELOG.md $(TAG_QUERY)

changelog:
	git-chglog -o CHANGELOG.md --next-tag `$(SEMTAG) final -s $(scope) -o -f` $(TAG_QUERY)

