#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# BOSL2 - The Belfry OpenScad Library - A library of tools, shapes, and
# helpers to make OpenScad easier to use.
#----------------------------------------------------------------------------
# The prefix bosl2 must be unique for all files.
# +++++
# Preamble
ifndef bosl2SegId
$(call Enter-Segment,bosl2)
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
ifneq ($(call Is-Goal,help-${bosl2Seg}),)
$(info Help message variable: help_${bosl2SegN}_msg)
define help_${bosl2SegN}_msg
Make segment: ${bosl2Seg}.mk

BOSL2 - The Belfry OpenScad Library - A library of tools, shapes, and
helpers to make OpenScad easier to use.

Command line goals:
  help-${bosl2Seg}
    Display this help.
  bosl2
    Download and install BOSL2.
endef
endif # help goal message.

$(call Exit-Segment,bosl2)
else # bosl2SegId exists
$(call Check-Segment-Conflicts,bosl2)
endif # bosl2SegId
# -----
