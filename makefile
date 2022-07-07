#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFw
#----------------------------------------------------------------------------

$(info Goal: ${MAKECMDGOALS})
ifeq (${MAKECMDGOALS},)
  $(info No target was specified.)
endif

project_dir = $(realpath $(dir $(realpath $(firstword ${MAKEFILE_LIST}))))
$(info project_dir: ${project_dir})

.DEFAULT_GOAL := all

include config.mk
# To simplfy the command line common option overrides can be placed in
# a separate make segment. This file is NOT maintained in source control
# (i.e. Ignored in .gitignore). It is included if it exists.
# NOTE: The options can still be overridden on the command line.
# NOTE: This does not override any of the subsequent make segments.
#       e.g. Overrides do not apply to mods.
-include overrides.mk

# Load the selected kit and mod.
# NOTE: Additional custom kits can be described in overrides.mk.
# This installs and loads the selected kit and mod.
include ${MK_DIR}/kits.mk

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Supporting components. These are triggered by the mod configuration.
#----------------------------------------------------------------------------
# Firmware
ifdef FIRMWARE
  include ${MK_DIR}/${FIRMWARE}.mk
endif

# Custom 3D printed parts.
ifdef CAD_TOOL
  # This defines AllModelDeps.
  include ${MK_DIR}/${CAD_TOOL}.mk
endif

# What server software to use. Server software is hosted on an SBC.
ifdef SERVER_SOFTWARE
  include ${MK_DIR}/os-modding.mk

  include ${MK_DIR}/${SERVER_SOFTWARE}.mk

  # Which board to run the server software on.
  ifdef SBC_BOARD
    ifneq (${MAKECMDGOALS},list-os-boards)
      include ${SBC_BOARDS_DIR}/${SBC_BOARD}.mk
      # To trigger the build of a case for the SBC.
      MODEL_OPTIONS += SBC_BOARD=${SBC_BOARD}
    endif
  endif

  # Which variation of the OS to use.
  ifdef OS_VARIANT
    ifneq (${MAKECMDGOALS},list-os-variants)
      include ${OS_VARIANTS_DIR}/${OS_VARIANT}.mk
      include ${MK_DIR}/os-modding.mk
      include ${MK_DIR}/firsttime.mk
    endif
  endif
endif

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# The entire project.
#----------------------------------------------------------------------------

all: ${ModFirmware} ${ModDeps} ${AllModelDeps}

# Display the value of any variable.
show-%:
	@echo '$*=$($*)'

.PHONY: clean
clean: ${Cleaners}
	cd ${MARLIN_DIR}; git checkout .
	rm -rf ${MarlinBuildDir}/${MARLIN_MOD_BOARD}

ifeq (${MAKECMDGOALS},help)
define ModFwUsage
Usage: make [<option>=<value>] <target>

This make file and the included make segments define a framework
for developing and modifying devices or small embedded systems.

The collection of files for a given device or system is termed a mod.
Semantically, a mod is a modification of a device or system. A mod
can also be the development a complete device or system.

A git repository is used to maintain one or more kit with each mod
having its own subdirectory within the git repository.

This includes firmware for microcontroller boards or MCUs (e.g. Arduino),
OS images for single board computers or SBCs (e.g. Raspberry Pi), 3D
modeling and printing of cases and enclosures as well as the machines
they control.

All that is needed to get started is a clone of this repository and then
run make within the cloned directory. All of the necessary tools are
automatically installed within the context of the project directory so
that different projects can use different versions of tools without
conflicts between versions.

All of the 3D models are either downloaded as STLs from various websites or
are scripted using OpenSCAD which are then processed using ed-oscad to
generate the corresponding STL files. Because of the differences
between the various slicers and 3D printers gcode is not produced.

NOTE: SolidPython, ed-sp, will also be supported at some time in the future.

Command line options:
  Use help-<segment> to view the segment specific command line options.

  Sticky options need to be selected on the command line at least once. After
  being selected they default to the previous selection. These options are
  stored in ${STICKY_DIR}.
  For automated builds it is possible to preset options in:
    ${STICKY_DIR}.

  MODEL_TARGET=${MODEL_TARGET}
    An optional target for ed-oscad. This defaults to all.
  <target>      A single target. This defaults to display this help.

Defined in mod.mk:
  A scripted CAD tool is used to generate STLs for 3D printing or CNC machines.
  The STLs can be imported into slice or route softare to generate gcode.
  CAD_TOOL=${CAD_TOOL}
    Which scripted CAD tool to use. If left undefined it is assumed no 3D
    printed parts are in the mod.
    Available tools are:
      ed-oscad  OpenSCAD and SolidPython.
      ed-cq     (future) CADQuery.
  CAD_TOOL_VARIANT=${CAD_TOOL_VARIANT}
    Which branch or release of the CAD tool to use.

  Firmware runs on the device hardware.
  FIRMWARE=${FIRMWARE}
    Which firmware to build. If left undefined it is assumed no firmware
    is included in the mod.
    Available options are:
      marlin    Build marlin firmware.
  FIRMWARE_VARIANT=${FIRMWARE_VARIANT}
    Which branch or release of the firmware to use.

  Server software connects to the firmware running on the device to provide
  access via a network. Server software can also provide a user interface
  using devices such as keyboards, displays, and touch screens.
  SERVER_SOFTWARE=${SERVER_SOFTWARE}
    Which server software to use. Server software is hosted on an SBC. If
    not defined then OS_VARIANT and SBC_BOARD are ignored.
  OS_VARIANT=${OS_VARIANT}
    The variant of the OS to use. This determines in which OS to install the
    initialization scripts. If undefined then an OS image will not be
    initilized.
  SBC_BOARD=${SBC_BOARD}
    The board on which the OS will run. This can also trigger the build
    of a 3D printed case for the board.

  Not defining CAD_TOOL, FIRMWARE, and SERVER_SOFTWARE will disable the
  corresponding section of a build.

Command line targets:
  all             The firmware is built and all assembly files are processed
                  to generate the 3D printable parts.
  firmware        Build the mod firmware only.
  parts           3D printable parts only.
  os              Build the SBC OS only.
  clean           Remove the dependency files and the output files.
  reset-sticky    Resets all sticky variables to they have to be defined on
                  the command line again. This does not reset mod specific
                  sticky variables. For mods use the mod defined reset.
  clean-<segment> Cleans a make segment output. See segment specific help
                  for more information.
  reset-<segment>-sticky
                  Reset segment specific variables. See segment specific
                  help for more information.
  help            Display this help message (default).
  show-<variable> This is a special target which can be used to display
                  any makefile variable and exit.
  help-<segment>  Display a make segment specific help.

endef

export ModFwUsage
.PHONY: help
help:
	@echo "$$ModFwUsage" | less
endif
