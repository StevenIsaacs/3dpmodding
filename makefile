#+
# This make file serves to build components for modding computer aided
# manufacturing (CAM) software and hardware. This includes 3D printers,
# laser engravers, CNC machines and more.
#
# This is structured to be compatible with Apis SDE builds using Jenkins.
# To do so create a symbolic link to this file named "project.mk".
#
# All that is needed is a clone of this repository and then run make within
# project directory. All of the necessary tools are installed within the
# context of the project directory so that different projects can use
# different versions of tools without concern.
#
# All of the 3D models are either downloaded as STLs from various websites or
# are scripted using OpenSCAD or SolidPython which are then processed using
# ed-oscad to generate the corresponding STL files. Because of the differences
# between the various slicers and 3D printers gcode is not produced.
#-

$(info Goal: ${MAKECMDGOALS})
ifeq (${MAKECMDGOALS},)
  $(info No target was specified.)
endif

project_dir = $(dir $(realpath $(firstword ${MAKEFILE_LIST})))
$(info project_dir: ${project_dir})
mk_dir = $(realpath ${project_dir}/mk)

define ModCamUsage
Usage: "make [MOD=<mod>] [MODEL_TARGET=<ed-oscad-target>] <target>"
MOD=<mod>     Which mod to build. Defaults to the active_mod symlink. This
              must be used the first time and then will be optional.
MODEL_TARGET=<ed-oscad-target>
              An optional target for ed-oscad. This defaults to all.
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

export ModCamUsage
help:
	@echo "$$ModCamUsage"

include options.mk

# Install the mods repo if it doesn't exist.
# NOT using dependencies because this is always needed.
ifeq ($(realpath ${MODS_3DP_DIR}),)
  $(info Cloning ${MODS_3DP_REPO})
  r = $(shell git clone ${MODS_3DP_REPO} ${MODS_3DP_DIR})
  $(info r=${r} status=$(.SHELLSTATUS))
  ifneq ($(.SHELLSTATUS),0)
    $(error Could not clone ${MODS_3DP_REPO})
  endif
  $(info Checking out ${MODS_3DP_BRANCH})
  r = $(shell cd ${MODS_3DP_DIR}; git checkout ${MODS_3DP_BRANCH})
  $(info r=${r} status=$(.SHELLSTATUS))
  ifneq ($(.SHELLSTATUS),0)
    $(error Could not set MODS branch to ${MODS_3DP_BRANCH})
  endif
endif
# Which mod to build.
MOD = active_mod
MOD_DIR = $(realpath ${MODS_3DP_DIR}/${MOD})
ifeq (${MOD_DIR},)
  ifneq (${MOD},active_mod)
    $(error MOD directory does not exist)
  else
    $(info ${ModCamUsage})
    $(error MOD has not been specified. Use 'make MOD=<mod> <target>')
  endif
endif

# A symlink is used so it is not necessary to specify the MOD on the
# command line every time.
ifneq (${MOD},active_mod)
  $(info Creating MOD symlink)
  $(info MOD=${MOD})
  $(info MOD_DIR=${MOD_DIR})
  $(shell rm -f ${MODS_3DP_DIR}/active_mod)
  $(shell ln -s ${MOD_DIR} ${MODS_3DP_DIR}/active_mod)
endif

$(info Processing ${MOD})

-include ${MOD_DIR}/mod.mk

ifeq (${MODEL_TARGET},)
  MODEL_TARGET = all
endif

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Firmware
#----------------------------------------------------------------------------

# These are mutually exclusive options.
BuildFirmware = $(filter YES,${USE_MARLIN} ${USE_KLIPPER})
ifeq (${BuildFirmware},YES)
  # Only one option was selected.
  ifeq (${USE_MARLIN},YES)
    include ${mk_dir}/marlin.mk
  endif

  ifeq (${USE_KLIPPER},YES)
    # NOTE: This also builds the HOST OS image.
    # include ${mk_dir}/klipper.mk
    $(info USE_KLIPPER ignored. This is a future enhancement.)
  endif
else
  ifeq (${BuildFirmware},YES YES)
    $(warning Multiple firmware variations specified -- skipping. )
  endif
endif

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Custom 3D printed parts.
#----------------------------------------------------------------------------

ifeq (${USE_ED_OSCAD},YES)
  include ${mk_dir}/ed-oscad.mk
endif

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# HOST OS image and remote printer control.
#----------------------------------------------------------------------------

# These are mutually exclusive options.
BuildOsImage = $(filter YES,${USE_OCTOPRINT} ${USE_KLIPPER})
ifeq (${BuildOsImage},YES)
  # Only one option was selected.
  ifeq (${USE_OCTOPRINT},YES)
    include ${mk_dir}/octoprint.mk
  endif

  ifeq (${USE_KLIPPER},YES)
    # NOTE: This also builds the HOST OS image.
    # ${mk_dir}/klipper.mk was include int the firmware section.
    $(info USE_KLIPPER ignored. This is a future enhancement.)
  endif
else
  ifeq (${BuildOsImage},YES YES)
    $(warning Multiple OS image variations specified -- skipping. )
  endif
endif

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# The entire project.
#----------------------------------------------------------------------------

all: ${ModFirmware} ${MOD_DEPS} parts

# Display the value of any variable.
show-%:
	@echo '$*=$($*)'

clean:
	cd ${MARLIN_DIR}; git checkout .
	rm -rf ${MarlinBuildDir}/${MARLIN_MOD_BOARD}
