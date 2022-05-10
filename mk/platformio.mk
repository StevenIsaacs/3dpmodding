#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# PlatformIO
#----------------------------------------------------------------------------

#+
# Install PlatformIO which is used to build firmware.
#-
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

.PHONY: pio_python
pio_python: ${PioVenvRequirements}
	( \
	. ${PioVirtualEnvDir}/bin/activate; \
	python; \
	deactivate; \
	)
