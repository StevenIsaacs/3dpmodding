#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Defines variables, targets, and functions for configuring an OS for ssh
# access.
#----------------------------------------------------------------------------
# The prefix hdls must be unique for all files.
# +++++
# Preamble
ifndef hdlsSegId
$(call Enter-Segment,hdls)
# -----

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${hdlsSeg}),)
define help_${hdlsSegN}_msg
Make segment: ${hdlsSeg}.mk

This defines the variables, targets, and functions for configuring an OS for
headless access. This generates a script which is designed to be run as part
of the first run initialization. A headless Gateway does not rely upon a
keyboard or display.

The SSH port can be set in mod.mk to something other than the typical port 22.
All other ports are closed using a firewall. Port forwarding is possible.
Root login is disabled. No passwords are allowed meaning the client must have
a key listed in authorized_keys.

Command line goals:
  help-${hdlsSeg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment,hdls)
else # hdlsSegId exists
$(call Check-Segment-Conflicts,hdls)
endif # hdlsSegId
# -----
