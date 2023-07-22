#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# openscad-tray - Designed to quickly create trays with different
# configurations, for efficient storing of parts, such as hardware, small
# tools, board game inserts, etc.
#----------------------------------------------------------------------------
# The prefix osct must be unique for all files.
# +++++
# Preamble
ifndef osctSegId
$(call Enter-Segment,osct)
# -----

OPENSCAD_TRAY_VERSION = master
OPENSCAD_TRAY_GIT_URL = https://github.com/sofian/openscad-tray.git

OPENSCAD_TRAY_PATH = ${LIB_PATH}/openscad-tray
OPENSCAD_TRAY_DEP = ${OPENSCAD_TRAY_PATH}/readme.md

${OPENSCAD_TRAY_DEP}:
> git clone ${OPENSCAD_TRAY_GIT_URL} ${OPENSCAD_TRAY_PATH}
> cd $(OPENSCAD_TRAY_PATH) && \
> git switch --detach ${OPENSCAD_TRAY_VERSION}

openscad-tray: ${OPENSCAD_TRAY_DEP}

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${osctSeg}),)
$(info Help message variable: help_${osctSegN}_msg)
define help_${osctSegN}_msg
Make segment: ${osctSeg}.mk

openscad-tray - Designed to quickly create trays with different
configurations, for efficient storing of parts, such as hardware, small
tools, board game inserts, etc.

Command line goals:
  help-${osctSeg}
    Display this help.
  openscad-tray
    Download and install openscad-tray.
endef
endif # help goal message.

$(call Exit-Segment,osct)
else # osctSegId exists
$(call Check-Segment-Conflicts,osct)
endif # osctSegId
# -----
