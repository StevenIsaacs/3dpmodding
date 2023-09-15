#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# MCAD - components commonly used in designing and mocking up mechanical
# designs.
#----------------------------------------------------------------------------
# The prefix $(call This-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call This-Segment-Basename)SegId
$(call Enter-Segment)
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
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

MCAD - components commonly used in designing and mocking up mechanical
designs.

Command line goals:
  mcad
    Download and install mcad.
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
