.PHONY: changelog release

SEMTAG=tools/semtag

CHANGELOG_FILE=CHANGELOG.md
TAG_QUERY=v11.0.0..

scope ?= "minor"

changelog-unrelease:
	git-chglog -o $(CHANGELOG_FILE) $(TAG_QUERY)

changelog:
	git-chglog -o $(CHANGELOG_FILE) --next-tag `$(SEMTAG) final -s $(scope) -o -f` $(TAG_QUERY)

release:
	$(SEMTAG) final -s $(scope)
