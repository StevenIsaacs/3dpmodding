#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Defines variables, targets, and functions for configuring an OS for ssh
# access.
#----------------------------------------------------------------------------
# The prefix $(call This-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call This-Segment-Basename)SegId
$(call Enter-Segment)
# -----

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
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
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
