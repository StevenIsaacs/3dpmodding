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
# to reduce the risk of version conflict and cross-contanimation.
#-

ifndef project_mk
project_mk = tronxy-x5sa-project

$(info Goal: ${MAKECMDGOALS})

project_dir = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
$(info project_dir: $(project_dir))

define Usage
Usage: "make MOD=<mod> <target>"
MOD=<mod>     Which mod to build.
<target>      A single target. This defaults to display this help.
Possible targets:
    all       The firmware is built and all assembly files are processed
              to generate the 3D printable parts.
    firmware  Build the printer firmware only.
    parts     3D printable parts only.
    clean     Remove the dependency files and the output files.
    help      Display this help message (default).
    show-<variable>
              This is a special target which can be used to display
              any makefile variable and exit.
endef

export Usage
help:
	@echo "$$Usage"

MOD = target_mod
ModDir = $(realpath $(MOD))
ifeq ($(ModDir),)
  ifneq ($(MOD),target_mod)
    $(error MOD directory does not exist)
  else
    $(error MOD has not been specified. Use 'make MOD=<mod> <target>')
  endif
endif

ifneq ($(MOD),target_mod)
  $(info Creating MOD symlink)
  $(info MOD=$(MOD))
  $(info ModDir=$(ModDir))
  $(shell rm -f target_mod)
  $(shell ln -s $(ModDir) target_mod)
endif

$(info Processing $(MOD))

include options.mk

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Marlin firmware
#----------------------------------------------------------------------------

#+
# Python virtual environment requirements needed to run PlatformIO.
#-
PioPythonVersion = 3.8
PioVirtualEnvDir = pio_venv
PioPythonBin = $(PioVirtualEnvDir)/bin/python3
PioVenvPackageDir = \
  $(PioVirtualEnvDir)/lib/python$(PioPythonVersion)/site-packages

$(PioPythonBin):
	python$(PioPythonVersion) -m venv --copies ./$(PioVirtualEnvDir)

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

MarlinBuildDir = $(MARLIN_DIR)/.pio/build

MarlinInstallFile = $(MARLIN_DIR)/README.md

MarlinConfigInstallFile = $(MARLIN_CONFIG_DIR)/README.md

$(MarlinInstallFile):
	git clone $(MARLIN_REPO) $(MARLIN_DIR); \
	cd $(MARLIN_DIR); \
	git checkout $(MARLIN_BRANCH)

$(MarlinConfigInstallFile):
	git clone $(MARLIN_CONFIG_REPO) $(MARLIN_CONFIG_DIR); \
	cd $(MARLIN_CONFIG_DIR); \
	git checkout $(MARLIN_BRANCH)

MarlinDeps = \
  $(PlatformIoRequirements) \
  $(MarlinInstallFile) \
  $(MarlinConfigInstallFile)

.PHONY: pio_python
pio_python: $(PioVenvRequirements)
	( \
	. $(PioVirtualEnvDir)/bin/activate; \
	cd ${MARLIN_DIR}; \
	python; \
	deactivate; \
	)

.PHONY: marlin
marlin: $(MarlinDeps)

#+
# The custom modded Marlin firmware.
# The prefix for mod specific files is TX5SAPM_.
#-
MarlinModDir = $(MOD)

-include $(MarlinModDir)/marlin_mod.mk

#+
# All the files maintained for this mod.
#-
MarlinModFiles = $(shell find $(MarlinModDir)/Marlin -type f)

#+
# To build Marlin using the mod files.
#-
$(MARLIN_MOD_BIN): $(MarlinDeps) $(MarlinModFiles)
	cd $(MARLIN_DIR); git checkout .
	cp -r $(MarlinModDir)/Marlin/* $(MARLIN_DIR)/Marlin
	. $(PioVirtualEnvDir)/bin/activate; \
	cd $(MARLIN_DIR); \
	platformio run -e $(MARLIN_MOD_BOARD); \
	deactivate

firmware: $(MARLIN_MOD_BIN)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Custom 3D printed parts.
#----------------------------------------------------------------------------

EdOscadInstallFile = $(ED_OSCAD_DIR)/README.md

$(EdOscadInstallFile):
	git clone $(ED_OSCAD_REPO) $(ED_OSCAD_DIR)
	git checkout $(ED_OSCAD_BRANCH)

.PHONY: ed-oscad
ed-oscad: $(EdOscadInstallFile)

# 3D printable parts.
.PHONY: parts
parts: $(EdOscadInstallFile)
	cd $(ED_OSCAD_DIR); \
	$(MAKE) MODEL=$(MOD_MODEL)

all: $(MARLIN_MOD_BIN) parts

# Display the value of any variable.
show-%:
	@echo '$*=$($*)'

clean:
	rm -rf $(MarlinBuildDir)/$(MARLIN_MOD_BOARD)

endif
