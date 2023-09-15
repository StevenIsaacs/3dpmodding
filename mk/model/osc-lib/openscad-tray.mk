#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# openscad-tray - Designed to quickly create trays with different
# configurations, for efficient storing of parts, such as hardware, small
# tools, board game inserts, etc.
#----------------------------------------------------------------------------
# The prefix $(call This-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call This-Segment-Basename)SegId
$(call Enter-Segment)
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
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

openscad-tray - Designed to quickly create trays with different
configurations, for efficient storing of parts, such as hardware, small
tools, board game inserts, etc.

Command line goals:
  openscad-tray
    Download and install openscad-tray.
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
