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
# Python virtual environment requirements needed to run PlatformIO.
#-
PioPythonVersion = 3.8
PioVirtualEnvDir = ${TOOLS_DIR}/pio_venv
PioPythonBin = ${PioVirtualEnvDir}/bin/python3
PioVenvPackageDir = \
  ${PioVirtualEnvDir}/lib/python${PioPythonVersion}/site-packages

${PioPythonBin}:
	python${PioPythonVersion} -m venv --copies ${PioVirtualEnvDir}

PioVenvRequirements = \
  ${PioPythonBin} \
  ${PioVenvPackageDir}/platformio/__init__.py

define PioInstallPythonPackage =
$(info ++++++++++++)
$(info PioInstallPythonPackage $1)
	( \
	  . ${PioVirtualEnvDir}/bin/activate; \
	  pip3 install $1; \
	)
endef

${PioVenvPackageDir}/platformio/__init__.py:
	$(call PioInstallPythonPackage, platformio)

#+
# For Platformio which is used to build the Marlin firmware.
#-
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

.PHONY: pio_python
pio_python: ${PioVenvRequirements}
	( \
	. ${PioVirtualEnvDir}/bin/activate; \
	cd ${MARLIN_DIR}; \
	python; \
	deactivate; \
	)

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
