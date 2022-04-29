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

project_dir = $(dir $(realpath $(firstword ${MAKEFILE_LIST})))
$(info project_dir: ${project_dir})

define Mod3dpUsage
Usage: "make [MOD=<mod>] [MODEL_TARGET=<ed-oscad-target>] <target>"
MOD=<mod>     Which mod to build. Defaults to the active_mod symlink. This
              must be used the first time and then will be optional.
MODEL_TARGET=<ed-oscad-target>
              An optional target for ed-oscad. Use ed-oscad-help for more
              information.
<target>      A single target. This defaults to display this help.
Possible targets:
    all       The firmware is built and all assembly files are processed
              to generate the 3D printable parts.
    firmware  Build the printer firmware only.
    parts     3D printable parts only.
    clean     Remove the dependency files and the output files.
    help      Display this help message (default).
    ed-oscad-help
              Display the ed-oscad help.
    show-<variable>
              This is a special target which can be used to display
              any makefile variable and exit.
endef

export Mod3dpUsage
help:
	@echo "$$Mod3dpUsage"

include options.mk

# For downloaded files.
DOWNLOADS_DIR = $(realpath downloads)
OS_IMAGE_DIR = $(realpath os_images)

# Which mod to build.
MOD = active_mod
MOD_DIR = $(realpath ${MODS_DIR}/${MOD})
ifeq (${MOD_DIR},)
  ifneq (${MOD},active_mod)
    $(error MOD directory does not exist)
  else
    $(info ${Mod3dpUsage})
    $(error MOD has not been specified. Use 'make MOD=<mod> <target>')
  endif
endif

# A symlink is used so it is not necessary to specify the MOD on the
# command line every time.
ifneq (${MOD},active_mod)
  $(info Creating MOD symlink)
  $(info MOD=${MOD})
  $(info MOD_DIR=${MODS_DIR}/${MOD_DIR})
  $(shell rm -f ${MODS_DIR}/active_mod)
  $(shell ln -s ${MOD_DIR} ${MODS_DIR}/active_mod)
endif

$(info Processing ${MOD})

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Marlin firmware
#----------------------------------------------------------------------------

#+
# Python virtual environment requirements needed to run PlatformIO.
#-
PioPythonVersion = 3.8
PioVirtualEnvDir = pio_venv
PioPythonBin = ${PioVirtualEnvDir}/bin/python3
PioVenvPackageDir = \
  ${PioVirtualEnvDir}/lib/python${PioPythonVersion}/site-packages

${PioPythonBin}:
	python${PioPythonVersion} -m venv --copies ./${PioVirtualEnvDir}

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

-include ${MOD_DIR}/mod.mk

#+
# All the files maintained for this mod.
#-
MarlinModFiles = $(shell find ${MOD_DIR}/Marlin -type f)

#+
# To build Marlin using the mod files.
# NOTE: The mod directory structure is expected to match the Marlin
# directory structure.
#-
${MARLIN_MOD_BIN}: ${MarlinDeps} ${MarlinModFiles}
	cd ${MARLIN_DIR}; git checkout .
	cp -r ${MOD_DIR}/Marlin/* ${MARLIN_DIR}/Marlin
	. ${PioVirtualEnvDir}/bin/activate; \
	cd ${MARLIN_DIR}; \
	platformio run -e ${MARLIN_MOD_BOARD}; \
	deactivate

firmware: ${MARLIN_MOD_BIN}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Custom 3D printed parts.
#----------------------------------------------------------------------------

EdOscadInstallFile = ${ED_OSCAD_DIR}/README.md

${EdOscadInstallFile}:
	git clone ${ED_OSCAD_REPO} ${ED_OSCAD_DIR}
	cd ${ED_OSCAD_DIR}; git checkout ${ED_OSCAD_BRANCH}

.PHONY: ed-oscad
ed-oscad: ${EdOscadInstallFile}

.PHONY: ed-oscad-help
ed-oscad-help: ${EdOscadInstallFile}
	cd ${ED_OSCAD_DIR}; make help

# 3D printable parts.
.PHONY: parts
parts: ${EdOscadInstallFile}
	cd ${ED_OSCAD_DIR}; \
	${MAKE} MODEL_DIR=${MOD_DIR}/model ${MODEL_OPTIONS} ${MODEL_TARGET}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# The entire project.
#----------------------------------------------------------------------------

all: ${MARLIN_MOD_BIN} ${MOD_DEPS} parts

# Display the value of any variable.
show-%:
	@echo '$*=$($*)'

clean:
	cd ${MARLIN_DIR}; git checkout .
	rm -rf ${MarlinBuildDir}/${MARLIN_MOD_BOARD}

endif
