#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# OS Variant definitions for the Armbian OS.
#----------------------------------------------------------------------------
# The prefix armb must be unique for all files.
# +++++
# Preamble
ifndef armbSegId
$(call Enter-Segment,armb)
# -----
$(info Using OS variant: ${GW_OS_VARIANT})

$(call Use-Segment,generic)
# +++++
# Postamble
ifneq ($(call Is-Goal,help-${armbSeg}),)
$(info Help message variable: help_${armbSegN}_msg)
define help_${armbSegN}_msg
Make segment: ${armbSeg}.mk

OS variant specific initialization and first run of an ${GW_OS_VARIANT} based
OS image.

Command line goals:
  help-${armbSeg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment,armb)
else # armbSegId exists
$(call Check-Segment-Conflicts,armb)
endif # armbSegId
# -----
