#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Marlin firmware
#----------------------------------------------------------------------------
# Defined in options.mk:
#   MARLIN_REPO
#   MARLIN_BRANCH
#   MARLIN_DIR
#   MARLIN_CONFIG_REPO
#   MARLIN_CONFIG_DIR
#
# Expected to be defined in mod.mk:
#   MARLIN_MOD_BOARD
# Other possible overrides:
#
#+
# For Platformio which is used to build the Marlin firmware.
#-
include ${mk_dir}/platformio.mk

PlatformIoRequirements = ${PioVenvRequirements}

MarlinBuildDir = ${MARLIN_DIR}/.pio/build

MarlinInstallFile = ${MARLIN_DIR}/README.md

MarlinConfigInstallFile = ${MARLIN_CONFIG_DIR}/README.md

${MarlinInstallFile}:
	git clone ${MARLIN_REPO} ${MARLIN_DIR}; \
	cd ${MARLIN_DIR}; \
	git checkout ${MARLIN_BRANCH}

$(MarlinConfigInstallFile):
	git clone ${MARLIN_CONFIG_REPO} ${MARLIN_CONFIG_DIR}; \
	cd ${MARLIN_CONFIG_DIR}; \
	git checkout ${MARLIN_BRANCH}

MarlinDeps = \
  ${PlatformIoRequirements} \
  ${MarlinInstallFile} \
  $(MarlinConfigInstallFile)

.PHONY: marlin
marlin: ${MarlinDeps}

#+
# All the files maintained for this mod.
#-
MarlinModFiles = $(shell find ${MOD_DIR}/Marlin -type f)

MarlinFirmware = ${MarlinBuildDir}/${MARLIN_MOD_BOARD}/${MOD_FIRMWARE}

#+
# To build Marlin using the mod files.
# NOTE: The mod directory structure is expected to match the Marlin
# directory structure.
#-
${MarlinFirmware}: ${MarlinDeps} ${MarlinModFiles}
	cd ${MARLIN_DIR}; git checkout .
	cp -r ${MOD_DIR}/Marlin/* ${MARLIN_DIR}/Marlin
	. ${PioVirtualEnvDir}/bin/activate; \
	cd ${MARLIN_DIR}; \
	platformio run -e ${MARLIN_MOD_BOARD}; \
	deactivate

firmware: ${MarlinFirmware}

ModFirmware = ${MarlinFirmware}
