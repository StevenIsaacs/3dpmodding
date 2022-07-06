#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Modding an OS image.
#----------------------------------------------------------------------------

#+
# Config section.
#
# Installing the OS modding framework.
#-
ifeq (${OS_MODDING_VARIANT},dev)
  OS_MODDING_REPO = git@github.com:StevenIsaacs/os-modding.git
  OS_MODDING_BRANCH = dev
  OS_MODDING_DIR = ${TOOLS_DIR}/os-modding-dev
else
  # default
  OS_MODDING_REPO = https://github.com:StevenIsaacs/os-modding.git
  OS_MODDING_BRANCH = ${OS_MODDING_VARIANT}
  OS_MODDING_DIR = ${TOOLS_DIR}/os-modding
endif
# OS images and image configuration.
OS_IMAGE_DIR = ${TOOLS_DIR}/os_images
# realpath is handy for reducing duplicate slashes (//) in paths.
# realpath returns null if the directory does not exist.
$(shell mkdir -p ${OS_IMAGE_DIR}/mnt)
OS_IMAGE_MNT_DIR = $(realpath ${OS_IMAGE_DIR}/mnt)

_OsModdingSegment = ${OS_MODDING_DIR}/osm_.mk

${_OsModdingSegment}:
	git clone ${OS_MODDING_REPO} ${OS_MODDING_DIR}
	cd ${OS_MODDING_DIR}; git checkout ${OS_MODDING_BRANCH}

include ${_OsModdingSegment}
MOD_DEPS += ${OSM_IMAGE_DIR}/${OSM_IMAGE}

.PHONY: os-modding
os-modding: ${_OsModdingSegment}

ifeq (${MAKECMDGOALS},help-os-modding)
define HelpOsModdingMsg
Make segment: os-modding.mk

This segment is used to clone the os-modding git repository and checkout a
specific branch. It includes the os-modding make segment.

Defined on the command line (see help):

Defined in the higher level make file:
  OS_MODDING_VARIANT = ${OS_MODDING_VARIANT}
    Which variant or branch to use.

Defines:
  OS_MODDING_REPO = ${OS_MODDING_REPO}
    Which repository to clone from.
  OS_MODDING_BRANCH = ${OS_MODDING_BRANCH}
    Which branch to checkout after cloning.
  OS_MODDING_DIR = ${OS_MODDING_DIR}
    The directory in which to clone the repository.
  OS_IMAGE_DIR = ${OS_IMAGE_DIR}
    Where the unpacked OS image files are placed.
  OS_IMAGE_MNT_DIR = ${OS_IMAGE_MNT_DIR}
    Where an OS image is mounted to install the initialization scripts.

Command line targets:
  help-os-modding	Display this help.

endef

export HelpOsModdingMsg
help-os-modding:
	@echo "$$HelpOsModdingMsg" | less
endif
