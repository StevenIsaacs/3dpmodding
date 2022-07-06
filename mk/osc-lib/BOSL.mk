# BOSL - The Belfry OpenScad Library - A library of tools, shapes, and
# helpers to make OpenScad easier to use.
$(info BOSL library)

BOSL_VERSION = v1.0.3
BOSL_GIT_URL = https://github.com/revarbat/BOSL.git
BOSL_REL_URL = https://github.com/revarbat/BOSL/releases/tag/$(BOSL_VERSION)

BOSL_DIR = ${LIB_DIR}/BOSL
BOSL_DEP = ${BOSL_DIR}/README.md

${BOSL_DEP}:
	git clone ${BOSL_GIT_URL} ${BOSL_DIR}
	cd $(BOSL_DIR) && \
	git switch --detach ${BOSL_VERSION}

bosl: ${BOSL_DEP}
