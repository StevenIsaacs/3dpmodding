#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# OS Variant definitions for the Ubuntu OS.
#----------------------------------------------------------------------------
# The prefix ubu must be unique for all files.
# +++++
# Preamble
ifndef ubuSegId
$(call Enter-Segment,ubu)
# -----
$(info Using OS variant: ${GW_OS_VARIANT})

$(call Use-Segment,generic)
# +++++
# Postamble
ifneq ($(call Is-Goal,help-${ubuSeg}),)
$(info Help message variable: help_${ubuSegN}_msg)
define help_${ubuSegN}_msg
Make segment: ${ubuSeg}.mk

OS variant specific initialization and first run of an ${GW_OS_VARIANT} based
OS image.

Command line goals:
  help-${ubuSeg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment,ubu)
else # ubuSegId exists
$(call Check-Segment-Conflicts,ubu)
endif # ubuSegId
# -----
