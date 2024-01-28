#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# BOSL2 - The Belfry OpenScad Library - A library of tools, shapes, and
# helpers to make OpenScad easier to use.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,BOSL2 - The Belfry OpenScad Library)
# -----

BOSL2_VERSION = revarbat_dev
BOSL2_GIT_URL = https://github.com/revarbat/BOSL2.git
BOSL2_REL_URL = https://github.com/revarbat/BOSL2/releases/tag/$(BOSL2_VERSION)

BOSL2_PATH = ${LIB_PATH}/BOSL2
BOSL2_DEP = ${BOSL2_PATH}/README.md

${BOSL2_DEP}:
> git clone ${BOSL2_GIT_URL} ${BOSL2_PATH}
> cd $(BOSL2_PATH) && \
> git switch ${BOSL2_VERSION} && \
> git switch --detach

bosl2: ${BOSL2_DEP}
# +++++
# Postamble
# Define help only if needed.
__h := $(or $(call Is-Goal,help-${SegUN}),$(call Is-Goal,help-${SegID}))
ifneq (${__h},)
$(call Attention,Generating help for:${Seg})
define __help
Make segment: ${Seg}.mk

BOSL2 - The Belfry OpenScad Library - A library of tools, shapes, and
helpers to make OpenScad easier to use.

Command line goals:
  bosl2
    Download and install BOSL2.
  help-${SegUN}
    Display this help.
endef
${__h} := ${__help}
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
