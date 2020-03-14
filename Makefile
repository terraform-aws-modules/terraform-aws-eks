.PHONY: changelog release

SEMTAG=tools/semtag

CHANGELOG_FILE=CHANGELOG.md
OLD_CHANGELOG_LAST_TAG=v10.0.0
OLD_CHANGELOG_LAST_TAG_REGEX='\[$(OLD_CHANGELOG_LAST_TAG)\]|name="$(OLD_CHANGELOG_LAST_TAG)"'
TAG_QUERY=$(OLD_CHANGELOG_LAST_TAG)..

BEGIN_PLACEHOLDER:=<!-- BEGIN GIT-CHGLOG -->
END_PLACEHOLDER:=<!-- END GIT-CHGLOG -->

TMPFILE:=$(shell mktemp /tmp/terraform-aws-eks.XXXXXX)
TMPFILE_CHANGELOG:=$(shell mktemp /tmp/terraform-aws-eks.XXXXXX)
# ToDo: Make compatible with sed and GNUsed (or test if GNU sed is present)
SED:=$(shell which gsed)

scope ?= "minor"

changelog-unrelease:
	git-chglog $(TAG_QUERY) | grep -vE $(OLD_CHANGELOG_LAST_TAG_REGEX) | $(SED) 'N;s/\n$$//g;P;D' > $(TMPFILE)
	$(SED) '/$(BEGIN_PLACEHOLDER)/,/$(END_PLACEHOLDER)/{//!d}' $(CHANGELOG_FILE) > $(TMPFILE_CHANGELOG)
	$(SED) -i '/$(BEGIN_PLACEHOLDER)/r $(TMPFILE)' $(TMPFILE_CHANGELOG)
	mv $(TMPFILE_CHANGELOG) $(CHANGELOG_FILE) && rm -f $(TMPFILE)

changelog:
	git-chglog --next-tag `$(SEMTAG) final -s $(scope) -o -f` $(TAG_QUERY) | grep -vE $(OLD_CHANGELOG_LAST_TAG_REGEX) | $(SED) 'N;s/\n$$//g;P;D' > $(TMPFILE)
	$(SED) '/$(BEGIN_PLACEHOLDER)/,/$(END_PLACEHOLDER)/{//!d}' $(CHANGELOG_FILE) > $(TMPFILE_CHANGELOG)
	$(SED) -i '/$(BEGIN_PLACEHOLDER)/r $(TMPFILE)' $(TMPFILE_CHANGELOG)
	mv $(TMPFILE_CHANGELOG) $(CHANGELOG_FILE) && rm -f $(TMPFILE)

release:
	$(SEMTAG) final -s $(scope)

clean:
	rm -f $(TMPFILE) $(TMPFILE_CHANGELOG)
	$(SED) -i '/$(BEGIN_PLACEHOLDER)/,/$(END_PLACEHOLDER)/{//!d}' $(CHANGELOG_FILE)
