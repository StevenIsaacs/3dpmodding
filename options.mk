#+
# Override these on the make command line as needed. Using overrides it should
# not be necessary to modify the makefile.
#-

# Where tool specific configurations are maintained.
CONF_DIR = ${project_dir}/conf

# Where various tools are downloaded and installed.
# NOTE: This directory is in .gitignore.
TOOLS_DIR = ${project_dir}/tools

# For downloaded files.
DOWNLOADS_DIR = ${TOOLS_DIR}/downloads
OS_IMAGE_DIR = ${TOOLS_DIR}/os_images
# realpath is handy for reducing duplicate slashes (//) in paths.
# realpath returns null if the directory does not exist.
$(shell mkdir -p ${OS_IMAGE_DIR}/mnt)
OS_IMAGE_MNT_DIR = $(realpath ${OS_IMAGE_DIR}/mnt)

#+
# Installing the 3D printer mods.
#-
MODS_3DP_DEV = YES
ifeq (${MODS_3DP_DEV},YES)
  MODS_3DP_REPO = git@github.com:StevenIsaacs/3dpmods.git
  MODS_3DP_BRANCH = dev
  MODS_3DP_DIR = 3dpmods-dev
else
  MODS_3DP_REPO = https://github.com:StevenIsaacs/3dpmods.git
  MODS_3DP_BRANCH = release/0.0.1
  MODS_3DP_DIR = 3dpmods
endif

#+
# Custom 3D printed parts.
#
# NOTE: ed-oscad supports multiple models. It may be more convenient to
# install ed-oscad in a different location than within this directory. If
# so then simply reference that other location using ED_OSCAD_DIR.
#
# The default assumes ed-oscad is installed with the intent of working with
# multiple models.
#-
ED_OSCAD_DEV=YES
ifeq (${ED_OSCAD_DEV},YES)
  ED_OSCAD_REPO = git@bitbucket.org:StevenIsaacs/ed-oscad.git
  ED_OSCAD_DIR = ${TOOLS_DIR}/ed-oscad-dev
  ED_OSCAD_BRANCH = dev
else
  ED_OSCAD_REPO = https://bitbucket.org/StevenIsaacs/ed-oscad.git
  ED_OSCAD_DIR = ${TOOLS_DIR}/ed-oscad
  ED_OSCAD_BRANCH = release/0.0.1
endif

#+
# For custom Marlin mods.
#
# The Marlin configurations are installed to serve as starting points
# for new mods or for comparison with existing mods.
#-
# MARLIN_DEV = YES
ifeq (${MARLIN_DEV},YES)
  MARLIN_REPO = git@github.com:StevenIsaacs/Marlin.git
  MARLIN_BRANCH = dev
  MARLIN_DIR = ${TOOLS_DIR}/marlin-dev
  MARLIN_CONFIG_REPO = git@github.com:StevenIsaacs/Configurations.git
  MARLIN_CONFIG_DIR = ${TOOLS_DIR}/marlin-configs-dev
else
  MARLIN_REPO = https://github.com/MarlinFirmware/Marlin.git
  MARLIN_BRANCH = bugfix-2.0.x
  MARLIN_DIR = ${TOOLS_DIR}/marlin
  MARLIN_CONFIG_REPO = https://github.com/MarlinFirmware/Configurations.git
  MARLIN_CONFIG_DIR = ${TOOLS_DIR}/marlin-configs
endif

#+
# OS images for running Octoprint or Klipper.
# These typically have one or two partitions. For now the offsets and sizes
# for the partitions are hard coded. In the future the output of partx can be
# parsed to determine the number of partitions and their sizes.
#-
#+
# For using Octoprint on an SBC such as a Raspberry PI or Orange PI.
#
# The octoprint make module downloads and modifies the OS image. This
# defines the OS variants which are supported.
#-

# Octopi prebuilt OS running on a Raspberry PI 3 or 4.
# This used when USE_OCTOPI=YES.
OCTOPI_OS_VERSION = 0.18.0-1.7.3-20220323100241
OCTOPI_OS_IMAGE = octopi-${OCTOPI_OS_VERSION}.img
OCTOPI_OS_IMAGE_FILE = octopi-${OCTOPI_OS_VERSION}.zip
OCTOPI_OS_IMAGE_URL = https://github.com/OctoPrint/OctoPi-UpToDate/releases/download/${OCTOPI_OS_VERSION}/${OCTOPI_OS_IMAGE_FILE}
OCTOPI_OS_UNPACK = ZIP
OCTOPI_OS_P1_NAME = p1
OCTOPI_OS_P1_OFFSET = 4194304
OCTOPI_OS_P1_SIZE = 26873856
OCTOPI_OS_P2_NAME = p2
OCTOPI_OS_P2_OFFSET = 272629760
OCTOPI_OS_P2_SIZE = 2216689664
OCTOPI_OS_BOOT_DIR = p1
OCTOPI_OS_ROOT_DIR = p2

# Raspberry PI OS (formerly Raspbian now Raspios) on a Raspberry PI 3 or 4.
RASPIOS_OS_RELEASE = 2022-04-07
RASPIOS_OS_VERSION = 2022-04-04-raspios-bullseye
RASPIOS_OS_IMAGE = ${RASPIOS_OS_VERSION}-armhf-lite.img
RASPIOS_OS_IMAGE_FILE = ${RASPIOS_OS_IMAGE}.xz
RASPIOS_OS_IMAGE_URL = https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-${RASPIOS_OS_RELEASE}/${RASPIOS_OS_IMAGE_FILE}
RASPIOS_OS_UNPACK = XZ
RASPIOS_OS_P1_NAME = p1
RASPIOS_OS_P1_OFFSET = 4194304
RASPIOS_OS_P1_SIZE = 26873856
RASPIOS_OS_P2_NAME = p2
RASPIOS_OS_P2_OFFSET = 272629760
RASPIOS_OS_P2_SIZE = 1744830464
RASPIOS_OS_BOOT_DIR = p1
RASPIOS_OS_ROOT_DIR = p2

# An Orange PI Zero.
# Bullseye is Debian based.
OPIZ_OS_RELEASE = 22.02.1
OPIZ_OS_VERSION = bullseye_current_5.15.25
OPIZ_OS_IMAGE = Armbian_${OPIZ_OS_RELEASE}_Orangepizero_${OPIZ_OS_VERSION}.img
OPIZ_OS_IMAGE_FILE = ${OPIZ_OS_IMAGE}.xz
OPIZ_OS_IMAGE_URL = https://redirect.armbian.com/orangepizero/Bullseye_current
OPIZ_OS_UNPACK = XZ
OPIZ_OS_P1_NAME = p1
OPIZ_OS_P1_OFFSET = 4194304
OPIZ_OS_P1_SIZE = 1434451968
OPIZ_OS_BOOT_DIR = p1/boot
OPIZ_OS_ROOT_DIR = p1
