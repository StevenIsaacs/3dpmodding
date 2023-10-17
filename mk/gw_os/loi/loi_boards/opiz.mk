#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# <purpose for this segment>
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----
$(info Using OS board: ${GW_OS_BOARD})

# This is important for emulation.
GW_OS_ARCH = arm

# Bullseye is Debian based.
ifeq (${GW_OS_VARIANT},armbian)
armbian_LOI_RELEASE = 22.02.1
armbian_LOI_VARIANT = bullseye_current_5.15.25
armbian_LOI_IMAGE = \
  Armbian_${armbian_LOI_RELEASE}_Orangepizero_${armbian_LOI_VARIANT}.img
armbian_LOI_IMAGE_FILE = ${armbian_LOI_IMAGE}.xz
armbian_LOI_IMAGE_URL = \
  https://redirect.armbian.com/orangepizero/Bullseye_current
armbian_LOI_DOWNLOAD = wget
armbian_LOI_UNPACK = xz
armbian_LOI_P1_NAME = root
armbian_LOI_BOOT_PATH = ${armbian_LOI_P1_NAME}/boot
armbian_LOI_ROOT_PATH = ${armbian_LOI_P1_NAME}
endif

# OrangePi_zero_ubuntu_xenial_server_linux5.3.5_v1.0.tar.gz
ifeq (${GW_OS_VARIANT},ubuntu)
ubuntu_LOI_RELEASE = v1.0
ubuntu_LOI_VARIANT = zenial_server_linux5.3.5
ubuntu_LOI_IMAGE = \
  OrangePi_zero_${ubuntu_LOI_VARIANT}_${ubuntu_LOI_RELEASE}.img
ubuntu_LOI_IMAGE_FILE = \
  OrangePi_zero_${ubuntu_LOI_VARIANT}_${ubuntu_LOI_RELEASE}.tar.gz
ubuntu_LOI_IMAGE_ID = 14vsFOV-kqlIl5nqrKVPMB7qldJvX7Ttm
ubuntu_LOI_DOWNLOAD = google
ubuntu_LOI_UNPACK = tarz
ubuntu_LOI_P1_NAME = boot
ubuntu_LOI_P2_NAME = root
ubuntu_LOI_BOOT_PATH = ${ubuntu_LOI_P1_NAME}
ubuntu_LOI_ROOT_PATH = ${ubuntu_LOI_P2_NAME}
endif

# OrangePi_zero_debian_stretch_server_linux5.3.5_v1.0.tar.gz
ifeq (${GW_OS_VARIANT},debian)
debian_LOI_RELEASE = v1.0
debian_LOI_VARIANT = stretch_server_linux5.3.5
debian_LOI_IMAGE = \
  OrangePi_zero_debian_${debian_LOI_VARIANT}_${debian_LOI_RELEASE}.img
debian_LOI_IMAGE_FILE = \
  OrangePi_zero_debian_${debian_LOI_VARIANT}_${debian_LOI_RELEASE}.tar.gz
debian_LOI_IMAGE_ID = 1O9PuWWKFMgDeooJqBTVPC0aEeDMjvOmJ
debian_LOI_DOWNLOAD = google
debian_LOI_UNPACK = tarz
debian_LOI_P1_NAME = boot
debian_LOI_P2_NAME = root
debian_LOI_BOOT_PATH = ${debian_LOI_P1_NAME}
debian_LOI_ROOT_PATH = ${debian_LOI_P2_NAME}
endif

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

The Orange PI Zero does not have a display interface. To monitor the boot
process it is necessary to use the serial port. Some instructions can be
found here: https://www.sigmdel.ca/michel/ha/opi/OPiZ_uart_en.html
NOTE: Any USB/serial adaptor can be used as long as the adaptor can work
with the low TTL voltage (3.3V).

+---------------------------+
|   +-+ +------+  [] Gnd    |
|   |U| | Eth  |  o  TX     | <- USB/TTL adaptor connections
|   |S| |      |  o  RX     |
|   |B| |      |            |
|   +-+ +------+            |
....

Supported OS variants for Orange PI Zero.

armbian     The armbian.com based image.
ubuntu      Ubuntu version of the Orange PI OS.
debian      Debian version of teh Orange PI OS.

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
