#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# PlatformIO
#----------------------------------------------------------------------------
define PlatformIoHelp
Make segment: platformio.mk

This segment is used to install PlatformIO for building firmware. Since
PlatformIO is implemented using Python a Python virtual environemt is
created where the PlatformIO module is installed. This virtual environment
is intended to be used only for running PlatformIO to avoid cross
contanimation with other modues.

Defined in mod.mk:

Defined in options.mk:
  TOOLS_DIR	        Where to install PlatformIO.

Defines:

Command line targets:
  help-platformio   Display this help.
  pio-python        Run Python in the PlatformIO virtual environment.

Uses:

endef

export PlatformIoHelp
help-platformio:
	@echo "$$PlatformIoHelp"

#+
# Install PlatformIO which is used to build firmware.
#-
#+
# Python virtual environment requirements needed to run PlatformIO.
#-
_PioPythonVersion = 3.8
_PioVirtualEnvDir = ${TOOLS_DIR}/pio_venv
_PioPythonBin = ${_PioVirtualEnvDir}/bin/python3
_PioVenvPackageDir = \
  ${_PioVirtualEnvDir}/lib/python${_PioPythonVersion}/site-packages

${_PioPythonBin}:
	python${_PioPythonVersion} -m venv --copies ${_PioVirtualEnvDir}

_PioVenvRequirements = \
  ${_PioPythonBin} \
  ${_PioVenvPackageDir}/platformio/__init__.py

define PioInstallPythonPackage =
$(info ++++++++++++)
$(info PioInstallPythonPackage $1)
	( \
	  . ${_PioVirtualEnvDir}/bin/activate; \
	  pip3 install $1; \
	)
endef

${_PioVenvPackageDir}/platformio/__init__.py:
	$(call PioInstallPythonPackage, platformio)

.PHONY: pio_python
pio_python: ${_PioVenvRequirements}
	( \
	. ${_PioVirtualEnvDir}/bin/activate; \
	python; \
	deactivate; \
	)
