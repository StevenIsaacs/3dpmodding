#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# dimlines - Create dimensioned lines, title blocks and more which are used
# to document parts.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment)
# -----
dimlines_VERSION = master
dimlines_GIT_URL = https://github.com/sidorof/dimlines.git

dimlines_PATH = ${LIB_PATH}/dimlines
dimlines_DEP = ${dimlines_PATH}/README.md

${dimlines_DEP}:
> git clone ${dimlines_GIT_URL} ${dimlines_PATH}
> cd $(dimlines_PATH) && \
> git switch ${dimlines_VERSION} && \
> git switch --detach

dimlines: ${dimlines_DEP}

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

dimlines - Create dimensioned lines, title blocks and more which are used
to document parts.

Command line goals:
  dimlines
    Download and install dimlines.
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
