#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# PlatformIO
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,PlatformIO)
# -----

#+
# Install PlatformIO which is used to build firmware.
#-
#+
# Python virtual environment requirements needed to run PlatformIO.
#-
ifndef PIO_PYTHON_VERSION
  PIO_PYTHON_VERSION = 3.8
endif

pio_venv_path = ${BIN_PATH}/pio_venv_${PIO_PYTHON_VERSION}
_pio_python_bin = ${pio_venv_path}/bin/python3

_pio_venv_package_path = \
  ${pio_venv_path}/lib/python${PIO_PYTHON_VERSION}/site-packages

pio_venv_requirements = \
  ${_pio_python_bin} \
  ${_pio_venv_package_path}/platformio/__init__.py

${_pio_python_bin}:
> python${PIO_PYTHON_VERSION} -m venv --copies ${pio_venv_path}

define _pio-install-python-package =
$(call Verbose,++++++++++++)
$(call Verbose, _pio-install-python-package $1)
> ( \
>   . ${pio_venv_path}/bin/activate; \
>   pip3 install $1; \
> )
endef

${_pio_venv_package_path}/platformio/__init__.py:
> $(call _pio-install-python-package, platformio)

.PHONY: ${SegUN}-python
${SegUN}-python: ${pio_venv_requirements}
> ( \
> . ${pio_venv_path}/bin/activate; \
> python; \
> deactivate; \
> )

# +++++
# Postamble
__h := $(or $(call Is-Goal,help-${SegUN}),$(call Is-Goal,help-${SegID}))
ifneq (${__h},)
$(call Attention,Generating help for:${Seg})
define __help
Make segment: ${Seg}.mk

This segment is used to install PlatformIO for building firmware. Since
PlatformIO is implemented using Python a Python virtual environment is
created where the PlatformIO module is installed. This virtual environment
is intended to be used only for running PlatformIO to avoid cross
contamination with other modules.

Defined in ${MOD}.mk:
  PIO_VERSION = ${PIO_VERSION}
    Which version of PlatformIO to use. If undefined then a default is used.
    NOTE: This is the Python version installed on the host used to create
> the Python virtual environment.
  PIO_PYTHON_VERSION = ${PIO_PYTHON_VERSION}
    Which version of Python to use. If undefined then a default is used.

Defined in config.mk:
  BIN_PATH = ${BIN_PATH}
    Where to install PlatformIO.

Defines:
  pio_venv_path = ${pio_venv_path}
    Where the PlatformIO Python virtual environment is installed.
  pio_venv_requirements = ${pio_venv_requirements}
    A list of requirements for installing PlatformIO.

Command line goals:
  ${SegUN}-python
    Run Python in the PlatformIO virtual environment.
  help-${SegUN}
    Display this help.
endef
${__h} := ${__help}
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
