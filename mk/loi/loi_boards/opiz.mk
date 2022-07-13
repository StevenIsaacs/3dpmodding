$(info Using OS board: ${OS_BOARD})

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
armbian_LOI_P1_NAME = p1
armbian_LOI_P1_OFFSET = 4194304
armbian_LOI_P1_SIZE = 1434451968
armbian_LOI_BOOT_DIR = p1/boot
armbian_LOI_ROOT_DIR = p1

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
ubuntu_LOI_P1_NAME = p1
ubuntu_LOI_P1_OFFSET = 4194304
ubuntu_LOI_P1_SIZE = 1434451968
ubuntu_LOI_P2_NAME = p2
ubuntu_LOI_P2_OFFSET = 272629760
ubuntu_LOI_P2_SIZE = 1744830464
ubuntu_LOI_BOOT_DIR = p1
ubuntu_LOI_ROOT_DIR = p2

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
debian_LOI_P1_NAME = p1
debian_LOI_P1_OFFSET = 20971520
debian_LOI_P1_SIZE = 52428800
debian_LOI_P2_NAME = p2
debian_LOI_P2_OFFSET = 73400320
debian_LOI_P2_SIZE = 1224736768
debian_LOI_BOOT_DIR = p1
debian_LOI_ROOT_DIR = p2

ifeq (${MAKECMDGOALS},list-os-variants)
define OsVariantsList
Supported OS variants for Orange PI Zero.

armbian     The armbian.com based image.
ubuntu      Ubuntu version of the Orange PI OS.
debian      Debian version of teh Orange PI OS.
endef

export OsVariantsList
.PHONY: list-os-variants
list-os-variants:
	@echo "$$OsVariantsList"
endif
