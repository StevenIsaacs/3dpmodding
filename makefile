#+
# This make file serves to build the components for modding a Tronxy X5SA Pro
# 3D printer. It is structured to be compatible with Apis SDE builds using
# Jenkins. To do so create a symbolic link to this file named "project.mk".
#
# All that is needed is a copy of this repository and then run make within
# project directory. All of the necessary tools are installed within the
# context of the project directory so that different projects can use
# different versions of tools without concern.
#
# The mods consist of a number of 3D printed parts and some custom Marlin
# firmware to change the layout of the display.
#
# All of the 3D models are either downloaded as STLs from various websites or
# are scripted using OpenSCAD or SolidPython.
#
# Platformio is used to build the Marlin firmware.
#
# Two Python virtual environments are used. One for ed-oscad (installed
# by ed-oscad) and the other for Platformio. These are separate environments
# to eliminate the risk of version conflict.
#-

ifndef project_mk
project_mk = tronxy-x5sa-project

$(info Goal: ${MAKECMDGOALS})

project_dir = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
$(info project_dir: $(project_dir))

define USAGE
Usage: "make <target>"
<target> A single target.
Possible targets:
    all       All assembly files are processed and .stl and .png files
              produced (default).
    firmware  Build the printer firmware only.
    parts     3D printable parts only.
    clean	  Remove the dependency files and the output files.
    help	  Display this help message (default).
    show-<variable>
              This is a special target which can be used to display
              any makefile variable and exit.
endef

export USAGE
help:
	@echo "$$USAGE"

#+
# Python virtual environment requirements needed to run PlatformIO.
#-
PioPythonVersion = 3.8
PioVirtualEnvDir = pio_venv
PioPythonBin = $(PioVirtualEnvDir)/bin/python3
PioVenvPackageDir = \
  $(PioVirtualEnvDir)/lib/python$(PioPythonVersion)/site-packages

$(PioPythonBin):
	python3 -m venv --copies ./$(PioVirtualEnvDir)

PioVenvRequirements = \
  $(PioPythonBin) \
  $(PioVenvPackageDir)/platformio/__init__.py

define PioInstallPythonPackage =
$(info ++++++++++++)
$(info PioInstallPythonPackage $1)
	( \
	  . $(PioVirtualEnvDir)/bin/activate; \
	  pip3 install $1; \
	)
endef

$(PioVenvPackageDir)/platformio/__init__.py:
	$(call PioInstallPythonPackage, platformio)

#+
# For Platformio which is used to build the Marlin firmware.
#-
PlatformIoRequirements = $(PioVenvRequirements)

#+
# For custom Marlin mods.
#-
MARLIN_REPO = git@github.com:StevenIsaacs/Marlin.git
MARLIN_BRANCH = ed
MARLIN_DIR = marlin
MarlinInstallFile = $(MARLIN_DIR)/README.md
MarlinModFiles = \
  $(MARLIN_DIR)/makefile

$(MarlinInstallFile):
	git clone $(MARLIN_REPO) $(MARLIN_DIR)
	git checkout $(MARLIN_BRANCH)

.PHONY: pio_python
pio_python: $(PioVenvRequirements)
	( \
	. $(PioVirtualEnvDir)/bin/activate; \
	cd ${MARLIN_DIR}; \
	python; \
	deactivate; \
	)

.PHONY: marlin
marlin: \
  $(PlatformIoRequirements) \
  $(MarlinInstallFile) \
  $(MarlinModFiles)

#+
# The custom modded Marlin firmware.
#-
TronxyX5saProBin = $(MARLIN_DIR)/.pio/build/chitu_f103/update.cbd

$(TronxyX5saProBin): \
  $(PlatformIoRequirements) \
  $(MarlinInstallFile) \
  $(MarlinModFiles)
	. $(PioVirtualEnvDir)/bin/activate; \
	cd $(MARLIN_DIR); \
	platformio run -e $(X5saBoard); \
	deactivate

firmware: $(TronxyX5saProBin)

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
ED_OSCAD_REPO = git@bitbucket.org:StevenIsaacs/ed-oscad.git
ED_OSCAD_DIR = ../ed-oscad
ED_OSCAD_BRANCH = dev
EdOscadInstallFile = $(ED_OSCAD_DIR)/README.md

$(EdOscadInstallFile):
	git clone $(ED_OSCAD_REPO) $(ED_OSCAD_DIR)
	git checkout $(ED_OSCAD_BRANCH)

.PHONY: ed-oscad
ed-oscad: $(EdOscadInstallFile)

TronxyX5saProModel = tronxy_x5sa_p

# 3D printable parts.
.PHONY: parts
parts: $(EdOscadInstallFile)
	cd $(ED_OSCAD_DIR); \
	$(MAKE) MODEL=$(TronxyX5saProModel)

all: $(TronxyX5saProBin) parts

endif
