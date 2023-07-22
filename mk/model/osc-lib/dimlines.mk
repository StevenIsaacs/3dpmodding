#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# dimlines - Create dimensioned lines, title blocks and more which are used
# to document parts.
#----------------------------------------------------------------------------
# The prefix diml must be unique for all files.
# +++++
# Preamble
ifndef dimlSegId
$(call Enter-Segment,diml)
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
ifneq ($(call Is-Goal,help-${dimlSeg}),)
$(info Help message variable: help_${dimlSegN}_msg)
define help_${dimlSegN}_msg
Make segment: ${dimlSeg}.mk

dimlines - Create dimensioned lines, title blocks and more which are used
to document parts.

Command line goals:
  help-${dimlSeg}
    Display this help.
  dimlines
    Download and install dimlines.
endef
endif # help goal message.

$(call Exit-Segment,diml)
else # dimlSegId exists
$(call Check-Segment-Conflicts,diml)
endif # dimlSegId
# -----
