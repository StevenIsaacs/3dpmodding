#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# NopSCADlib - An ever expanding library of parts useful for 3D printers
# and enclosures for electronics.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,\
NopSCADlib - A library useful for 3D printers and enclosures for electronics.)
# -----

NOPSCADLIB_VERSION = v18.3.1
NOPSCADLIB_GIT_URL = https://github.com/nophead/NOPSCADLIB.git

NOPSCADLIB_PATH = ${LIB_PATH}/NopSCADlib
NOPSCADLIB_DEP = ${NOPSCADLIB_PATH}/readme.md

${NOPSCADLIB_DEP}:
> git clone ${NOPSCADLIB_GIT_URL} ${NOPSCADLIB_PATH}
> cd $(NOPSCADLIB_PATH) && \
> git switch --detach ${NOPSCADLIB_VERSION}

nopscadlib: ${NOPSCADLIB_DEP}

# +++++
# Postamble
# Define help only if needed.
__h := $(or $(call Is-Goal,help-${SegUN}),$(call Is-Goal,help-${SegID}))
ifneq (${__h},)
$(call Attention,Generating help for:${Seg})
define __help
Make segment: ${Seg}.mk

NopSCADlib - An ever expanding library of parts useful for 3D printers
and enclosures for electronics.

Command line goals:
  nopscadlib
    Download and install NopSCADlib.
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
