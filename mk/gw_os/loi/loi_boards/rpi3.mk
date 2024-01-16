#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Board and OS definitions for Raspberry PI boards.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment)
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
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

Supported OS variants for Raspberry PI 3 or 4:
  raspios   The official Raspberry PI OS.
  octopi    Raspberry PI OS pre-configured for Octoprint

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
