#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Defines variables, targets, and functions for configuring an OS for ssh
# access.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,Definitions for configuring an OS for ssh access.)
# -----

# +++++
# Postamble
# Define help only if needed.
__h := $(or $(call Is-Goal,help-${SegUN}),$(call Is-Goal,help-${SegID}))
ifneq (${__h},)
$(call Attention,Generating help for:${Seg})
define __help
Make segment: ${Seg}.mk

This defines the variables, targets, and functions for configuring an OS for
headless access. This generates a script which is designed to be run as part
of the first run initialization. A headless Gateway does not rely upon a
keyboard or display.

The SSH port can be set in mod.mk to something other than the typical port 22.
All other ports are closed using a firewall. Port forwarding is possible.
Root login is disabled. No passwords are allowed meaning the client must have
a key listed in authorized_keys.

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
