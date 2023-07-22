#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# OS Variant definitions for the Debian OS.
#----------------------------------------------------------------------------
# The prefix deb must be unique for all files.
# +++++
# Preamble
ifndef debSegId
$(call Enter-Segment,deb)
# -----
$(info Using OS variant: ${GW_OS_VARIANT})

$(call Use-Segment,generic)
# +++++
# Postamble
ifneq ($(call Is-Goal,help-${debSeg}),)
$(info Help message variable: help_${debSegN}_msg)
define help_${debSegN}_msg
Make segment: ${debSeg}.mk

OS variant specific initialization and first run of an ${GW_OS_VARIANT} based
OS image.

Command line goals:
  help-${debSeg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment,deb)
else # debSegId exists
$(call Check-Segment-Conflicts,deb)
endif # debSegId
# -----
