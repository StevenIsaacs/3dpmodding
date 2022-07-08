#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Marlin firmware
#----------------------------------------------------------------------------

include ${MK_DIR}/platformio.mk

#+
# Config section.
#
# For custom Marlin mods.
#
# The Marlin configurations are installed to serve as starting points
# for new mods or for comparison with existing mods.
#-
ifndef FIRMWARE_VARIANT
  FIRMWARE_VARIANT = bugfix-2.0.x
endif
ifeq (${FIRMWARE_VARIANT},dev)
  MARLIN_REPO = git@github.com:StevenIsaacs/Marlin.git
  MARLIN_VARIANT = dev
  MARLIN_DIR = ${TOOLS_DIR}/marlin-dev
  MARLIN_CONFIG_REPO = git@github.com:StevenIsaacs/Configurations.git
  MARLIN_CONFIG_DIR = ${TOOLS_DIR}/marlin-configs-dev
else
  MARLIN_REPO = https://github.com/MarlinFirmware/Marlin.git
  MARLIN_VARIANT = ${FIRMWARE_VARIANT}
  MARLIN_DIR = ${TOOLS_DIR}/marlin
  MARLIN_CONFIG_REPO = https://github.com/MarlinFirmware/Configurations.git
  MARLIN_CONFIG_DIR = ${TOOLS_DIR}/marlin-configs
endif

#+
# For Platformio which is used to build the Marlin firmware.
#-
_PlatformIoRequirements = ${PioVenvRequirements}

_MarlinBuildDir = ${MARLIN_DIR}/.pio/build

_MarlinInstallFile = ${MARLIN_DIR}/README.md

_MarlinConfigInstallFile = ${MARLIN_CONFIG_DIR}/README.md

${_MarlinInstallFile}:
	git clone ${MARLIN_REPO} ${MARLIN_DIR}; \
	cd ${MARLIN_DIR}; \
	git checkout ${MARLIN_VARIANT}

$(_MarlinConfigInstallFile):
	git clone ${MARLIN_CONFIG_REPO} ${MARLIN_CONFIG_DIR}; \
	cd ${MARLIN_CONFIG_DIR}; \
	git checkout ${MARLIN_VARIANT}

_MarlinDeps = \
  ${_PlatformIoRequirements} \
  ${_MarlinInstallFile} \
  $(_MarlinConfigInstallFile)

marlin: ${_MarlinDeps}

#+
# All the files maintained for this mod.
#-
_MarlinModFiles = $(shell find ${MOD_DIR}/Marlin -type f)

_MarlinFirmware = ${_MarlinBuildDir}/${MARLIN_MOD_BOARD}/${MARLIN_FIRMWARE}

#+
# To build Marlin using the mod files.
# NOTE: The mod directory structure is expected to match the Marlin
# directory structure.
#-
${_MarlinFirmware}: ${_MarlinDeps} ${_MarlinModFiles}
	cd ${MARLIN_DIR}; git checkout .; git checkout ${FIRMWARE_VARIANT}
	cp -r ${MOD_DIR}/Marlin/* ${MARLIN_DIR}/Marlin
	. ${PioVirtualEnvDir}/bin/activate; \
	cd ${MARLIN_DIR}; \
	platformio run -e ${MARLIN_MOD_BOARD}; \
	deactivate

ModFirmware = ${MOD_STAGING_DIR}/${MARLIN_FIRMWARE}

${ModFirmware}: ${_MarlinFirmware}
	mkdir -p $(@D)
	cp $< $@

firmware: ${ModFirmware}


ifeq (${MAKECMDGOALS},help-marlin)
define HelpMarlinMsg
Make segment: marlin.mk

Marlin firmware is typically used to control 3D printers but can also be
used for CNC and Laser cutters/engravers.

This segment is used to build the Marlin firmware using the mod specific
source files. The mod specific source files are copied to the Marlin
source tree before building the firmware. The mod specific source tree is
expected to match the Marlin source tree so a simple recursive copy can
be used to modify the Marlin source. A git checkout is used to return the
Marlin source tree to its original cloned state.

Defined in mod.mk:
  FIRMWARE_VARIANT = ${FIRMWARE_VARIANT}
    The release or branch of the Marlin source code to use for the mod.
    If undefined then a default will be used. If using the dev variant
    then valid github credentials are required.
  MARLIN_MOD_BOARD = ${MARLIN_MOD_BOARD}
    The CAM controller board.
  MARLIN_FIRMWARE = ${MARLIN_FIRMWARE}
    The name of the file produced by the Marlin build to be installed on
    the CAM controller board.

Defined in kit.mk:
  MOD_STAGING_DIR = ${MOD_STAGING_DIR}
    Where the firmare image is staged.

Defines:
  MARLIN_REPO = ${MARLIN_REPO}
    The URL of the repo to clone the Marlin source frome.
  MARLIN_VARIANT = ${MARLIN_VARIANT}
    The branch to use for building the Marlin firmware.
  MARLIN_DIR = ${MARLIN_DIR}
    Where to clone the Marlin source to.
  MARLIN_CONFIG_REPO = ${MARLIN_CONFIG_REPO}
    The existing Marlin configurations which can be used as starting point
    for a new mod.
  MARLIN_CONFIG_DIR = ${MARLIN_CONFIG_DIR}
    Where to clone the Marlin configurations to.
  ModFirmware = ${ModFirmware}
    The dependencies to build the firmware.

Command line targets:
  help-marlin     Display this help.
  marlin          Install the Marlin source code and PlatformIO.
  firmware        Build the Marlin firware using the mod source files.

Uses:
  platformio.mk
endef

export HelpMarlinMsg
help-marlin:
	@echo "$$HelpMarlinMsg" | less
endif
