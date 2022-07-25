#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# OS First Time
#----------------------------------------------------------------------------
# Not all variants need a specific os-firsttime.mk
-include ${MK_DIR}/${HUI_OS_VARIANT}_os-firsttime.mk

install-os-firsttime:
> $(call mount-os-image)
> echo "$$GenFirstTimeScript" > ${FirstTimeDir}
> $(call unmount-os-image)

ifeq (${MAKECMDGOALS},help-os-firsttime)
define FirstTimeHelp
Make segment: os-firsttime.mk

This segment installs a first time script into an OS image. To do so it
uses os_image to mount the image. Each HUI_OS_VARIANT requires its own version
of the first time script.

NOTE: The targets are intended to be used explicitly on the command line.
      No other targets should be dependent of any of the targets described
>   in this make segment.

Defined in mod.mk:
  See os_image.mk.

Defined in the segment which included this file:
  HUI_OS_VARIANT    Which variant of the OS to use. Determined by which USE_<board>
                option was specified in mod.mk.
                Currently - ${HUI_OS_VARIANT}
                Selected by USE_${HUI_OS_VARIANT}

Defined in config.mk:

Defines:

Command line targets:
  help-os-firsttime    Display this help.
  install-os-firsttime Mount the OS image, install the first time script and then
                    unmount the OS image.

Uses:
  ${HUI_OS_VARIANT}_os-firsttime.mk
  mount-os-image in os_image.mk
  unmount-os-image in os_image.mk
endef

export FirstTimeHelp
help-os-firsttime:
> @echo "$$FirstTimeHelp" | less

endif
