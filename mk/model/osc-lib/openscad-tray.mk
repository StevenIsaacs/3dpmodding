#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# openscad-tray - Designed to quickly create trays with different
# configurations, for efficient storing of parts, such as hardware, small
# tools, board game inserts, etc.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,openscad-tray - parts storage trays.)
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
# Define help only if needed.
__h := $(or $(call Is-Goal,help-${SegUN}),$(call Is-Goal,help-${SegID}))
ifneq (${__h},)
$(call Attention,Generating help for:${Seg})
define __help
Make segment: ${Seg}.mk

openscad-tray - Designed to quickly create trays with different
configurations, for efficient storing of parts, such as hardware, small
tools, board game inserts, etc.

Command line goals:
  openscad-tray
    Download and install openscad-tray.
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
