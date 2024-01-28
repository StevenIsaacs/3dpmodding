#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Defines variables, targets, and functions for configuring an OS for direct
# access.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,Definitions for configuring an OS for direct access.)
# -----
# Postamble
# Define help only if needed.
__h := $(or $(call Is-Goal,help-${SegUN}),$(call Is-Goal,help-${SegID}))
ifneq (${__h},)
$(call Attention,Generating help for:${Seg})
define __help
Make segment: ${Seg}.mk

In direct access there is no GW because in this case the workstation is also
the gateway to the controller.

Command line goals:
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
