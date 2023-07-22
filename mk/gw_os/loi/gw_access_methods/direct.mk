#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Defines variables, targets, and functions for configuring an OS for direct
# access.
#----------------------------------------------------------------------------
# The prefix dacm must be unique for all files.
# +++++
# Preamble
ifndef dacmSegId
$(call Enter-Segment,dacm)
# +++++
# Postamble
ifneq ($(call Is-Goal,help-${dacmSeg}),)
define help_${dacmSegN}_msg
Make segment: ${dacmSeg}.mk

In direct access there is no GW because in this case the workstation is also
the gateway to the controller.

Command line goals:
  help-${dacmSeg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment,dacm)
else # dacmSegId exists
$(call Check-Segment-Conflicts,dacm)
endif # dacmSegId
# -----
