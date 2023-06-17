# BOSL - The Belfry OpenScad Library - A library of tools, shapes, and
# helpers to make OpenScad easier to use.
$(info BOSL library)

BOSL_VERSION = v1.0.3
BOSL_GIT_URL = https://github.com/revarbat/BOSL.git
BOSL_REL_URL = https://github.com/revarbat/BOSL/releases/tag/$(BOSL_VERSION)

BOSL_PATH = ${LIB_PATH}/BOSL
BOSL_DEP = ${BOSL_PATH}/README.md

${BOSL_DEP}:
> git clone ${BOSL_GIT_URL} ${BOSL_PATH}
> cd $(BOSL_PATH) && \
> git switch --detach ${BOSL_VERSION}

bosl: ${BOSL_DEP}
