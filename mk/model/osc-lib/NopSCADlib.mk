#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# NopSCADlib - An ever expanding library of parts useful for 3D printers
# and enclosures for electronics.
#----------------------------------------------------------------------------
# The prefix $(call This-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call This-Segment-Basename)SegId
$(call Enter-Segment)
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
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

NopSCADlib - An ever expanding library of parts useful for 3D printers
and enclosures for electronics.

Command line goals:
  nopscadlib
    Download and install NopSCADlib.
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
