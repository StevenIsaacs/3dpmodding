# BOSL2 - The Belfry OpenScad Library - A library of tools, shapes, and
# helpers to make OpenScad easier to use.
$(info BOSL2 library)

BOSL2_VERSION = revarbat_dev
BOSL2_GIT_URL = https://github.com/revarbat/BOSL2.git
BOSL2_REL_URL = https://github.com/revarbat/BOSL2/releases/tag/$(BOSL2_VERSION)

BOSL2_DIR = ${LIB_DIR}/BOSL2
BOSL2_DEP = ${BOSL2_DIR}/README.md

${BOSL2_DEP}:
> git clone ${BOSL2_GIT_URL} ${BOSL2_DIR}
> cd $(BOSL2_DIR) && \
> git switch ${BOSL2_VERSION} && \
> git switch --detach

bosl2: ${BOSL2_DEP}
