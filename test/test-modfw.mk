#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Test the ModFW features.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,Test the ModFW features.)
# -----

TESTING := 1

# Where test data is placed.
$(call Overridable,TESTING_DIR,testing)
$(call Overridable,TESTING_PATH,/tmp/modfw/${TESTING_DIR})

# Reroute all output to the testing directory.
STICKY_PATH := ${TESTING_PATH}/sticky
BUILD_DIR := build
BUILD_PATH := ${TESTING_PATH}/${BUILD_DIR}
STAGING_DIR := staging
STAGING_PATH := ${TESTING_PATH}/${STAGING_DIR}
TOOLS_DIR := tools
TOOLS_PATH := ${TESTING_PATH}/${TOOLS_DIR}
BIN_DIR := bin
BIN_PATH := ${TESTING_PATH}/${BIN_DIR}
DOWNLOADS_DIR := downloads
DOWNLOADS_PATH := ${TESTING_PATH}/${DOWNLOADS_DIR}

# This is also loaded in makefile and should trigger a segment conflict at
# that time.
$(call Use-Segment,config)

# Search path for loading segments. This can be extended by kits and mods.
$(call Add-Segment-Path,$(MK_PATH))

# The test-helpers segment will run tests based upon the setting of CASES.
$(call Use-Segment,test-helpers)

$(call Report-Test-Summary)

# +++++
# Postamble
# Define help only if needed.
__h := $(or $(call Is-Goal,help-${SegUN}),$(call Is-Goal,help-${SegID}))
ifneq (${__h},)
define __help
Make segment: ${Seg}.mk

Macros, goals and recipes to test ModFW makefile segments. This is intended to
be run using the PREPEND command line variable (see help).

Defines macros:
${help-report-comp}

${help-verify-comp-vars}

${help-verify-declare}

${help-report-repo}

${help-verify-repo-vars}

${help-verify-repo}

${help-report-mod}

${help-verify-mod-vars}

${help-verify-mod-contents}

Defines:
  TESTING = ${TESTING}
    Shows test mode is active. The projects makefile segment will not be
    loaded in makefile as a result.
  DEBUG = ${DEBUG}
    Debug mode is typically enabled when testing.

Command line goals:
  help-${SegUN}   Display this help.
  test-comps    Test component declaration.
  test-projects Test project, kit, and mod macros.

endef
${__h} := ${__help}
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
