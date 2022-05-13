#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# First Time
#----------------------------------------------------------------------------
define FirstTimeHelp
Make segment: firsttime.mk

This segment installs a first time script into an OS image. To do so it
uses os_image to mount the image. Each OS_VARIANT requires its own version
of the first time script.

NOTE: The targets are intended to be used explicitly on the command line.
      No other targets should be dependent of any of the targets described
	  in this make segment.

Defined in mod.mk:
  See os_image.mk.

Defined in the segment which included this file:
  OS_VARIANT    Which variant of the OS to use. Determined by which USE_<board>
                option was specified in mod.mk.
                Currently - ${OS_VARIANT}
                Selected by USE_${OS_VARIANT}

Defined in options.mk:

Defines:

Command line targets:
  help-firsttime    Display this help.
  install-firsttime Mount the OS image, install the first time script and then
                    unmount the OS image.

Uses:
  ${OS_VARIANT}_firsttime.mk
  mount-os-image in os_image.mk
  unmount-os-image in os_image.mk
endef

# Not all variants need a specific firsttime.mk
-include ${mk_dir}/${OS_VARIANT}_firsttime.mk

export FirstTimeHelp
help-firsttime:
	@echo "$$FirstTimeHelp"

install-firsttime:
    $(call mount-os-image)
	echo "$$GenFirstTimeScript" > ${FirstTimeDir}
	$(call unmount-os-image)
