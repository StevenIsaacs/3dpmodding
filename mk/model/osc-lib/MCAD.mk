#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# MCAD - components commonly used in designing and mocking up mechanical
# designs.
#----------------------------------------------------------------------------
# The prefix mcad must be unique for all files.
# +++++
# Preamble
ifndef mcadSegId
$(call Enter-Segment,mcad)
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
ifneq ($(call Is-Goal,help-${mcadSeg}),)
$(info Help message variable: help_${mcadSegN}_msg)
define help_${mcadSegN}_msg
Make segment: ${mcadSeg}.mk

MCAD - components commonly used in designing and mocking up mechanical
designs.

Command line goals:
  help-${mcadSeg}
    Display this help.
  mcad
    Download and install mcad.
endef
endif # help goal message.

$(call Exit-Segment,mcad)
else # mcadSegId exists
$(call Check-Segment-Conflicts,mcad)
endif # mcadSegId
# -----
