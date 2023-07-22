#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Board and OS definitions for Raspberry PI boards.
#----------------------------------------------------------------------------
# The prefix rpi must be unique for all files.
# +++++
# Preamble
ifndef rpiSegId
$(call Enter-Segment,rpi)
# -----

# This is important for emulation.
GW_OS_ARCH = arm

# Octopi prebuilt OS running on a Raspberry PI 3 or 4.
# This used when USE_OCTOPI=YES.
octopi_LOI_VARIANT = 0.18.0-1.7.3-20220323100241
octopi_LOI_IMAGE = octopi-${octopi_LOI_VARIANT}.img
octopi_LOI_IMAGE_FILE = octopi-${octopi_LOI_VARIANT}.zip
octopi_LOI_IMAGE_URL = https://github.com/OctoPrint/OctoPi-UpToDate/releases/download/${octopi_LOI_VARIANT}/${octopi_LOI_IMAGE_FILE}
octopi_LOI_UNPACK = ZIP
octopi_LOI_P1_NAME = boot
octopi_LOI_P2_NAME = root
octopi_LOI_BOOT_PATH = ${octopi_LOI_P1_NAME}
octopi_LOI_ROOT_PATH = ${octopi_LOI_P2_NAME}

# Raspberry PI OS (formerly Raspbian now Raspios) on a Raspberry PI 3 or 4.
raspios_LOI_RELEASE = 2022-04-07
raspios_LOI_VARIANT = 2022-04-04-raspios-bullseye
raspios_LOI_IMAGE = ${raspios_LOI_VARIANT}-armhf-lite.img
raspios_LOI_IMAGE_FILE = ${raspios_LOI_IMAGE}.xz
raspios_LOI_IMAGE_URL = https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-${raspios_LOI_RELEASE}/${raspios_LOI_IMAGE_FILE}
raspios_LOI_UNPACK = XZ
raspios_LOI_P1_NAME = boot
raspios_LOI_P2_NAME = root
raspios_LOI_BOOT_PATH = ${raspios_LOI_P1_NAME}
raspios_LOI_ROOT_PATH = ${raspios_LOI_P2_NAME}

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${rpiSeg}),)
$(info Help message variable: help_${rpiSegN}_msg)
define help_${rpiSegN}_msg
Make segment: ${rpiSeg}.mk

Supported OS variants for Raspberry PI 3 or 4:
  raspios   The official Raspberry PI OS.
  octopi    Raspberry PI OS pre-configured for Octoprint

Command line goals:
  help-${rpiSeg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment,rpi)
else # rpiSegId exists
$(call Check-Segment-Conflicts,rpi)
endif # rpiSegId
# -----
