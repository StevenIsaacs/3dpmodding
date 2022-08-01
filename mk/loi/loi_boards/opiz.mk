$(info Using OS board: ${SBC_OS_BOARD})

# This is important for emulation.
SBC_OS_ARCH = arm

# Bullseye is Debian based.
armbian_LOI_RELEASE = 22.02.1
armbian_LOI_VERSION = bullseye_current_5.15.25
armbian_LOI_IMAGE = \
  Armbian_${armbian_LOI_RELEASE}_Orangepizero_${armbian_LOI_VERSION}.img
armbian_LOI_IMAGE_FILE = ${armbian_LOI_IMAGE}.xz
armbian_LOI_IMAGE_URL = \
  https://redirect.armbian.com/orangepizero/Bullseye_current
armbian_LOI_DOWNLOAD = wget
armbian_LOI_UNPACK = xz
armbian_LOI_P1_NAME = root
armbian_LOI_BOOT_DIR = ${armbian_LOI_P1_NAME}/boot
armbian_LOI_ROOT_DIR = ${armbian_LOI_P1_NAME}

# OrangePi_zero_ubuntu_xenial_server_linux5.3.5_v1.0.tar.gz
ubuntu_LOI_RELEASE = v1.0
ubuntu_LOI_VERSION = zenial_server_linux5.3.5
ubuntu_LOI_IMAGE = \
  OrangePi_zero_${ubuntu_LOI_VERSION}_${ubuntu_LOI_RELEASE}.img
ubuntu_LOI_IMAGE_FILE = \
  OrangePi_zero_${ubuntu_LOI_VERSION}_${ubuntu_LOI_RELEASE}.tar.gz
ubuntu_LOI_IMAGE_ID = 14vsFOV-kqlIl5nqrKVPMB7qldJvX7Ttm
ubuntu_LOI_DOWNLOAD = google
ubuntu_LOI_UNPACK = tarz
ubuntu_LOI_P1_NAME = boot
ubuntu_LOI_P2_NAME = root
ubuntu_LOI_BOOT_DIR = ${ubuntu_LOI_P1_NAME}
ubuntu_LOI_ROOT_DIR = ${ubuntu_LOI_P2_NAME}

# OrangePi_zero_debian_stretch_server_linux5.3.5_v1.0.tar.gz
debian_LOI_RELEASE = v1.0
debian_LOI_VERSION = stretch_server_linux5.3.5
debian_LOI_IMAGE = \
  OrangePi_zero_debian_${debian_LOI_VERSION}_${debian_LOI_RELEASE}.img
debian_LOI_IMAGE_FILE = \
  OrangePi_zero_debian_${debian_LOI_VERSION}_${debian_LOI_RELEASE}.tar.gz
debian_LOI_IMAGE_ID = 1O9PuWWKFMgDeooJqBTVPC0aEeDMjvOmJ
debian_LOI_DOWNLOAD = google
debian_LOI_UNPACK = tarz
debian_LOI_P1_NAME = boot
debian_LOI_P2_NAME = root
debian_LOI_BOOT_DIR = ${debian_LOI_P1_NAME}
debian_LOI_ROOT_DIR = ${debian_LOI_P2_NAME}

ifeq (${MAKECMDGOALS},help-${SBC_OS_BOARD})
define ${SBC_OS_BOARD}_Help
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
endef

export ${SBC_OS_BOARD}_Help
.PHONY: help-${SBC_OS_BOARD}
help-${SBC_OS_BOARD}:
> @echo "$$${SBC_OS_BOARD}_Help"
endif
