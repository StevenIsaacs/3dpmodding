#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Defines variables, targets, and functions for configuring an OS for console
# access.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----

$(call Info,Standalone access method not implemented.)

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

This defines the variables, targets, and functions for configuring an OS to run on an SBC for console access. Root access is disabled but console and ssh access using passwords and sudo is possible. This generates a script which is designed to be run as part of the first run initialization.

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
