.PHONY: changelog release

SEMTAG=tools/semtag
OLD_CHANGELOG_LAST_TAG=v10.0.0
CHANGELOG_FILE=CHANGELOG.md
BEGIN_PLACEHOLDER:=<!-- BEGIN GIT-CHGLOG -->
END_PLACEHOLDER:=<!-- END GIT-CHGLOG -->
TAG_QUERY=$(OLD_CHANGELOG_LAST_TAG)..
TMPFILE:=$(shell mktemp /tmp/terraform-aws-eks.XXXXXX)
TMPFILE_CHANGELOG:=$(shell mktemp /tmp/terraform-aws-eks.XXXXXX)

# DARWIN:=$(shell uname -a | head -1 | grep -c Darwin && true)

# ToDo: Make compatible with sed and GNUsed (or test if GNU sed is present)
SED:=$(shell which gsed)
scope ?= "minor"

changelog-unrelease:
	git-chglog $(TAG_QUERY) | grep -v $(OLD_CHANGELOG_LAST_TAG) > $(TMPFILE)
	$(SED) '/$(BEGIN_PLACEHOLDER)/,/$(END_PLACEHOLDER)/{//!d}' $(CHANGELOG_FILE) > $(TMPFILE_CHANGELOG)
	$(SED) -i '/$(BEGIN_PLACEHOLDER)/r $(TMPFILE)' $(TMPFILE_CHANGELOG)
	mv $(TMPFILE_CHANGELOG) $(CHANGELOG_FILE)

changelog:
	git-chglog --next-tag `$(SEMTAG) final -s $(scope) -o -f` $(TAG_QUERY) | grep -v $(OLD_CHANGELOG_LAST_TAG) > $(TMPFILE)
	$(SED) '/$(BEGIN_PLACEHOLDER)/,/$(END_PLACEHOLDER)/{//!d}' $(CHANGELOG_FILE) > $(TMPFILE_CHANGELOG)
	$(SED) -i '/$(BEGIN_PLACEHOLDER)/r $(TMPFILE)' $(TMPFILE_CHANGELOG)
	mv $(TMPFILE_CHANGELOG) $(CHANGELOG_FILE)

release:
	$(SEMTAG) final -s $(scope)

clean:
	rm -f $(TMPFILE) $(TMPFILE_CHANGELOG)
	$(SED) -i '/$(BEGIN_PLACEHOLDER)/,/$(END_PLACEHOLDER)/{//!d}' $(CHANGELOG_FILE)
