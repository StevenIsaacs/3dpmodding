#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Defines variables, targets, and functions for configuring an OS for direct
# access.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment)
# -----
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

In direct access there is no GW because in this case the workstation is also
the gateway to the controller.

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
