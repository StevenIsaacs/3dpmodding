#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Test the ModFW features.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,Test the ModFW features.)
# -----

define _help
Make segment: ${Seg}.mk

This segment controls running tests to verify behavior of the various ModFW
makefile segments. It should be invoked using the PREPEND command line variable
described in makefile.

The TESTING variable is set which disables normal makefile execution.

The CASES variable is used by the test-helpers from helpers.
See help-CASES for more information.

e.g.: make PREPEND=${Seg}.mk CASES=<test_suite> <test_goal>
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

TESTING := 1

# Reroute all output to the testing directory.
PROJECTS_NODE := test-bed
PROJECT := test-project

$(call Use-Segment,$(HELPERS_PATH)/test-helpers.mk)

$(call Info,Running test cases:${CASES})

$(call Run-Suites,${TESTS_NODE},${CASES})

# +++++
# Postamble
# Define help only if needed.
__h := $(or \
  $(call Is-Goal,help-${SegUN}),\
  $(call Is-Goal,help-${SegID}),\
  $(call Is-Goal,help-${Seg}))
ifneq (${__h},)
define __help
$(call Display-Help-List,${SegID})
endef
${__h} := ${__help}
endif # help goal message.

$(call Exit-Segment)
else # SegId exists
$(call Check-Segment-Conflicts)
endif # SegId
# -----
