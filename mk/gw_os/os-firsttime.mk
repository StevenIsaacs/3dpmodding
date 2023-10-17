#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# OS First Time
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----
# Not all variants need a specific os-firsttime.mk
-include ${MK_PATH}/${GW_OS_VARIANT}_os-firsttime.mk

install-os-firsttime:
> $(call mount-os-image)
> echo "$$GenFirstTimeScript" > ${FirstTimePath}
> $(call unmount-os-image)

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

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
  install-os-firsttime
    Mount the OS image, install the first time script and then unmount the
    OS image.
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
