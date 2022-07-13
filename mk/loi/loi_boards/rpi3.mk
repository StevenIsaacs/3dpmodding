
ifeq (${MAKECMDGOALS},list-os-variants)
define ListOsVariantMsg
Supported OS variants for Raspberry PI 3 or 4.

raspios   The official Raspberry PI OS.
octopi    Raspberry PI OS pre-configured for Octoprint
endef

export ListOsVariantMsg
.PHONY: list-os-variants
list-os-variants:
	@echo "$$ListOsVariantMsg"
endif

# Octopi prebuilt OS running on a Raspberry PI 3 or 4.
# This used when USE_OCTOPI=YES.
octopi_LOI_VERSION = 0.18.0-1.7.3-20220323100241
octopi_LOI_IMAGE = octopi-${octopi_LOI_VERSION}.img
octopi_LOI_IMAGE_FILE = octopi-${octopi_LOI_VERSION}.zip
octopi_LOI_IMAGE_URL = https://github.com/OctoPrint/OctoPi-UpToDate/releases/download/${octopi_LOI_VERSION}/${octopi_LOI_IMAGE_FILE}
octopi_LOI_UNPACK = ZIP
octopi_LOI_P1_NAME = p1
octopi_LOI_P1_OFFSET = 4194304
octopi_LOI_P1_SIZE = 26873856
octopi_LOI_P2_NAME = p2
octopi_LOI_P2_OFFSET = 272629760
octopi_LOI_P2_SIZE = 2216689664
octopi_LOI_BOOT_DIR = p1
octopi_LOI_ROOT_DIR = p2

# Raspberry PI OS (formerly Raspbian now Raspios) on a Raspberry PI 3 or 4.
raspios_LOI_RELEASE = 2022-04-07
raspios_LOI_VERSION = 2022-04-04-raspios-bullseye
raspios_LOI_IMAGE = ${raspios_LOI_VERSION}-armhf-lite.img
raspios_LOI_IMAGE_FILE = ${raspios_LOI_IMAGE}.xz
raspios_LOI_IMAGE_URL = https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-${raspios_LOI_RELEASE}/${raspios_LOI_IMAGE_FILE}
raspios_LOI_UNPACK = XZ
raspios_LOI_P1_NAME = p1
raspios_LOI_P1_OFFSET = 4194304
raspios_LOI_P1_SIZE = 26873856
raspios_LOI_P2_NAME = p2
raspios_LOI_P2_OFFSET = 272629760
raspios_LOI_P2_SIZE = 1744830464
raspios_LOI_BOOT_DIR = p1
raspios_LOI_ROOT_DIR = p2
