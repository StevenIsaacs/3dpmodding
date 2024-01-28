#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# MCAD - components commonly used in designing and mocking up mechanical
# designs.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,\
  MCAD - components  used in designing and mocking up mechanical designs.)
# -----
$(info MCAD library)

MCAD_VERSION = openscad-2019.05
MCAD_GIT_URL = https://github.com/openscad/MCAD.git

MCAD_PATH = ${LIB_PATH}/MCAD
MCAD_DEP = ${MCAD_PATH}/README.markdown

${MCAD_DEP}:
> git clone ${MCAD_GIT_URL} ${MCAD_PATH}
> cd $(MCAD_PATH) && \
> git switch --detach ${MCAD_VERSION}

mcad: ${MCAD_DEP}

# +++++
# Postamble
# Define help only if needed.
__h := $(or $(call Is-Goal,help-${SegUN}),$(call Is-Goal,help-${SegID}))
ifneq (${__h},)
$(call Attention,Generating help for:${Seg})
define __help
Make segment: ${Seg}.mk

MCAD - components commonly used in designing and mocking up mechanical
designs.

Command line goals:
  mcad
    Download and install mcad.
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
