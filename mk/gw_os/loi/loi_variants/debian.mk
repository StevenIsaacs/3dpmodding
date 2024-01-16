#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# OS Variant definitions for the Debian OS.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment)
# -----
$(info Using OS variant: ${GW_OS_VARIANT})

$(call Use-Segment,generic)
# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

OS variant specific initialization and first run of an ${GW_OS_VARIANT} based
OS image.

Command line goals:
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
