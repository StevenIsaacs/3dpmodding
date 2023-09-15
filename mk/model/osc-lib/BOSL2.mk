#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# BOSL2 - The Belfry OpenScad Library - A library of tools, shapes, and
# helpers to make OpenScad easier to use.
#----------------------------------------------------------------------------
# The prefix $(call This-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call This-Segment-Basename)SegId
$(call Enter-Segment)
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
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

BOSL2 - The Belfry OpenScad Library - A library of tools, shapes, and
helpers to make OpenScad easier to use.

Command line goals:
  bosl2
    Download and install BOSL2.
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
