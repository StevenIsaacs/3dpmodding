#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Defines variables, targets, and functions for configuring an OS for console
# access.
#----------------------------------------------------------------------------
# The prefix saacm must be unique for all files.
# +++++
# Preamble
ifndef saacmSegId
$(call Enter-Segment,saacm)
# -----

$(call Add-Message,Standalone access method not implemented.)

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${saacmSeg}),)
define help_${saacmSegN}_msg
Make segment: ${saacmSeg}.mk

This defines the variables, targets, and functions for configuring an OS to run on an SBC for console access. Root access is disabled but console and ssh access using passwords and sudo is possible. This generates a script which is designed to be run as part of the first run initialization.

Command line goals:
  help-${saacmSeg}   Display this help.
endef
$(info Help message variable: help_${saacmSegN}_msg)
# -----
