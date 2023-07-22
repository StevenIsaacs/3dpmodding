#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# NopSCADlib - An ever expanding library of parts useful for 3D printers
# and enclosures for electronics.
#----------------------------------------------------------------------------
# The prefix nscl must be unique for all files.
# +++++
# Preamble
ifndef nsclSegId
$(call Enter-Segment,nscl)
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
ifneq ($(call Is-Goal,help-${nsclSeg}),)
$(info Help message variable: help_${nsclSegN}_msg)
define help_${nsclSegN}_msg
Make segment: ${nsclSeg}.mk

NopSCADlib - An ever expanding library of parts useful for 3D printers
and enclosures for electronics.

Command line goals:
  help-${nsclSeg}
    Display this help.
  nopscadlib
    Download and install NopSCADlib.
endef
endif # help goal message.

$(call Exit-Segment,nscl)
else # nsclSegId exists
$(call Check-Segment-Conflicts,nscl)
endif # nsclSegId
# -----
