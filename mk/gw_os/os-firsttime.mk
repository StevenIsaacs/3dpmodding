#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# OS First Time
#----------------------------------------------------------------------------
# The prefix oft must be unique for all files.
# +++++
# Preamble
ifndef oftSegId
$(call Enter-Segment,oft)
# -----
# Not all variants need a specific os-firsttime.mk
-include ${MK_PATH}/${GW_OS_VARIANT}_os-firsttime.mk

install-os-firsttime:
> $(call mount-os-image)
> echo "$$GenFirstTimeScript" > ${FirstTimePath}
> $(call unmount-os-image)

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${oftSeg}),)
$(info Help message variable: help_${oftSegN}_msg)
define help_${oftSegN}_msg
Make segment: ${oftSeg}.mk

This segment installs a first time script into an OS image. To do so it
uses os_image to mount the image. Each GW_OS_VARIANT requires its own version
of the first time script.

NOTE: The targets are intended to be used explicitly on the command line.
      No other targets should be dependent of any of the targets described
      in this make segment.

Defined in mod.mk:
  See os_image.mk.

Defined in the segment which included this file:
  GW_OS_VARIANT    Which variant of the OS to use. Determined by which USE_<board>
                option was specified in mod.mk.
                Currently - ${GW_OS_VARIANT}
                Selected by USE_${GW_OS_VARIANT}

Defined in config.mk:

Defines:

Command line goals:
  help-${oftSeg}
    Display this help.
  install-os-firsttime
    Mount the OS image, install the first time script and then unmount the
    OS image.

endef
endif # help goal message.

$(call Exit-Segment,oft)
else # oftSegId exists
$(call Check-Segment-Conflicts,oft)
endif # oftSegId
# -----
