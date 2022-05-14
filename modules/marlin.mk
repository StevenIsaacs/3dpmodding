#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Marlin firmware
#----------------------------------------------------------------------------
define MarlinHelp
Make segment: marlin.mk

This segment is used to build the Marlin firmware using the mod specific
source files. The mod specific source files are copied to the Marlin
source tree before building the firmware. The mod specific source tree is
expected to match the Marlin source tree so a simple recursive copy can
be used to modify the Marlin source. A git checkout is used to return the
Marlin source tree to its original cloned state.

Defined in mod.mk:
  MARLIN_MOD_BOARD
                  The CAM controller board.
  MOD_FIRMWARE    The name of the file produced by the Marlin build to be
                  installed on the CAM controller board.

Defined in options.mk:
  MARLIN_REPO     The URL of the repo to clone the Marlin source frome.
  MARLIN_BRANCH   The branch to use for building the Marlin firmware.
  MARLIN_DIR      Where to clone the Marlin source to.
  MARLIN_CONFIG_REPO
                  The existing Marlin configurations which can be used as
				  starting point for a new mod.
  MARLIN_CONFIG_DIR
                  Where to clone the Marlin configurations to.

Defines:
  ModFirmware     The dependencies to build the firmware.

Command line targets:
  help-marlin     Display this help.
  firmware        Build the Marlin firware using the mod source files.
  marlin          Install the Marlin source code and PlatformIO.

Uses:
  platformio.mk
endef

export MarlinHelp
help-marlin:
	@echo "$$MarlinHelp"

include ${mk_dir}/platformio.mk

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
	git checkout ${MARLIN_BRANCH}

$(_MarlinConfigInstallFile):
	git clone ${MARLIN_CONFIG_REPO} ${MARLIN_CONFIG_DIR}; \
	cd ${MARLIN_CONFIG_DIR}; \
	git checkout ${MARLIN_BRANCH}

_MarlinDeps = \
  ${_PlatformIoRequirements} \
  ${_MarlinInstallFile} \
  $(_MarlinConfigInstallFile)

marlin: ${_MarlinDeps}

#+
# All the files maintained for this mod.
#-
_MarlinModFiles = $(shell find ${MOD_DIR}/Marlin -type f)

_MarlinFirmware = ${_MarlinBuildDir}/${MARLIN_MOD_BOARD}/${MOD_FIRMWARE}

#+
# To build Marlin using the mod files.
# NOTE: The mod directory structure is expected to match the Marlin
# directory structure.
#-
${_MarlinFirmware}: ${_MarlinDeps} ${_MarlinModFiles}
	cd ${MARLIN_DIR}; git checkout .
	cp -r ${MOD_DIR}/Marlin/* ${MARLIN_DIR}/Marlin
	. ${PioVirtualEnvDir}/bin/activate; \
	cd ${MARLIN_DIR}; \
	platformio run -e ${MARLIN_MOD_BOARD}; \
	deactivate

firmware: ${_MarlinFirmware}

ModFirmware = ${_MarlinFirmware}
