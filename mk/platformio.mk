#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# PlatformIO
#----------------------------------------------------------------------------

#+
# Install PlatformIO which is used to build firmware.
#-
#+
# Python virtual environment requirements needed to run PlatformIO.
#-
ifndef PIO_PYTHON_VARIANT
  PIO_PYTHON_VARIANT = 3.8
endif

PioVirtualEnvPath = ${BIN_PATH}/pio_venv_${PIO_PYTHON_VARIANT}
_PioPythonBin = ${PioVirtualEnvPath}/bin/python3

PioVenvRequirements = \
  ${_PioPythonBin} \
  ${_PioVenvPackagePath}/platformio/__init__.py

_PioVenvPackagePath = \
  ${PioVirtualEnvPath}/lib/python${PIO_PYTHON_VARIANT}/site-packages

${_PioPythonBin}:
> python${PIO_PYTHON_VARIANT} -m venv --copies ${PioVirtualEnvPath}

define _PioInstallPythonPackage =
$(info ++++++++++++)
$(info _PioInstallPythonPackage $1)
> ( \
>   . ${PioVirtualEnvPath}/bin/activate; \
>   pip3 install $1; \
> )
endef

${_PioVenvPackagePath}/platformio/__init__.py:
> $(call _PioInstallPythonPackage, platformio)

.PHONY: pio_python
pio_python: ${PioVenvRequirements}
> ( \
> . ${PioVirtualEnvPath}/bin/activate; \
> python; \
> deactivate; \
> )

ifeq (${MAKECMDGOALS},help-platformio)
define HelpPlatformioMsg
Make segment: platformio.mk

This segment is used to install PlatformIO for building firmware. Since
PlatformIO is implemented using Python a Python virtual environemt is
created where the PlatformIO module is installed. This virtual environment
is intended to be used only for running PlatformIO to avoid cross
contanimation with other modules.

Defined in mod.mk:
  PIO_VARIANT = ${PIO_VARIANT}
    Which version of PlatformIO to use. If undefined then a default is used.
    NOTE: This is the Python version installed on the host used to create
> the Python virtual environment.
  PIO_PYTHON_VARIANT = ${PIO_PYTHON_VARIANT}
    Which version of Python to use. If undefined then a default is used.

Defined in config.mk:
  BIN_PATH = ${BIN_PATH}
    Where to install PlatformIO.

Defines:
  PioVirtualEnvPath = ${PioVirtualEnvPath}
    Where the PlatformIO Python virtual environment is installed.
  PioVenvRequirements = ${PioVenvRequirements}
    A list of requirements for installing PlatformIO.

Command line targets:
  help-platformio   Display this help.
  pio-python        Run Python in the PlatformIO virtual environment.

Uses:

endef

export HelpPlatformioMsg
help-platformio:
> @echo "$$HelpPlatformioMsg" | less
endif
