
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
octopi_OS_VERSION = 0.18.0-1.7.3-20220323100241
octopi_OS_IMAGE = octopi-${octopi_OS_VERSION}.img
octopi_OS_IMAGE_FILE = octopi-${octopi_OS_VERSION}.zip
octopi_OS_IMAGE_URL = https://github.com/OctoPrint/OctoPi-UpToDate/releases/download/${octopi_OS_VERSION}/${octopi_OS_IMAGE_FILE}
octopi_OS_UNPACK = ZIP
octopi_OS_P1_NAME = p1
octopi_OS_P1_OFFSET = 4194304
octopi_OS_P1_SIZE = 26873856
octopi_OS_P2_NAME = p2
octopi_OS_P2_OFFSET = 272629760
octopi_OS_P2_SIZE = 2216689664
octopi_OS_BOOT_DIR = p1
octopi_OS_ROOT_DIR = p2

# Raspberry PI OS (formerly Raspbian now Raspios) on a Raspberry PI 3 or 4.
raspios_OS_RELEASE = 2022-04-07
raspios_OS_VERSION = 2022-04-04-raspios-bullseye
raspios_OS_IMAGE = ${raspios_OS_VERSION}-armhf-lite.img
raspios_OS_IMAGE_FILE = ${raspios_OS_IMAGE}.xz
raspios_OS_IMAGE_URL = https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-${raspios_OS_RELEASE}/${raspios_OS_IMAGE_FILE}
raspios_OS_UNPACK = XZ
raspios_OS_P1_NAME = p1
raspios_OS_P1_OFFSET = 4194304
raspios_OS_P1_SIZE = 26873856
raspios_OS_P2_NAME = p2
raspios_OS_P2_OFFSET = 272629760
raspios_OS_P2_SIZE = 1744830464
raspios_OS_BOOT_DIR = p1
raspios_OS_ROOT_DIR = p2
