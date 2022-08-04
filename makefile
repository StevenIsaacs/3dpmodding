#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFw - A framework for modifying and developing devices.
#----------------------------------------------------------------------------
# Changing the prefix because some editors like vscode don't handle tabs
# in make files very well. This also slightly improves readability.
.RECIPEPREFIX = >

$(info Goal: ${MAKECMDGOALS})
ifeq (${MAKECMDGOALS},)
  $(info No target was specified.)
endif

project_dir = $(realpath $(dir $(realpath $(firstword ${MAKEFILE_LIST}))))
$(info project_dir: ${project_dir})

.DEFAULT_GOAL := all

# Special target to force another target.
FORCE:

include config.mk
# To simplfy the command line common option overrides can be placed in
# a separate make segment. This file is NOT maintained in source control
# (i.e. Ignored in .gitignore). It is included if it exists.
# NOTE: The options can still be overridden on the command line.
# NOTE: This does not override any of the subsequent make segments.
#       e.g. Overrides do not apply to mods.
-include overrides.mk

# Get the helpers.
include ${MK_DIR}/helpers.mk

# Helper macros.
include ${HELPERS_DIR}/macros.mk

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

# Custom 3d printed parts.
ifdef CAD_TOOL_3DP
  # This defines AllModelDeps.
  include ${MK_DIR}/${CAD_TOOL_3DP}.mk
endif

# TODO: Slicer software for 3D printing and CNC.

# Custom laser cut/engraved parts.
ifdef CAD_TOOL_LASER
  # TODO: Add CAD for laser.
  # Future possible is laserweb4.mk.
  #   https://github.com/LaserWeb/LaserWeb4
  $(info Laser cutting/engraving will be supported in the future)
  $(info OpenSCAD 2D mode can be used for laser cutting)
endif

# Custom CNC'd parts.
ifdef CAD_TOOL_CNC
  # TODO: Add CAD for CNC.
  $(info CNC tools will be supported in the future)
  $(info In the meantime OpenSCAD can be used for CNC modeling)
endif

ifdef CAD_TOOL_PCB
# TODO: Scripted schematic capture and PCB layout using tools like those
# mentioned in this article:
# https://hackaday.com/2021/03/30/wires-vs-words-pcb-routing-in-python/
$(info PCB CAD tools will be supported in the future)
endif

# What user interface software to use. User interface software is hosted on
# a single board computer (SBC).
ifdef GW_SOFTWARE
  ModOsInitScripts = ${HELPER_FUNCTIONS}
  include ${MK_DIR}/${GW_SOFTWARE}.mk
endif

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# The entire project.
#----------------------------------------------------------------------------

all: ${ModFirmware} ${ModDeps} ${AllModelDeps}

# Display the value of any variable.
show-%:
> @echo '$*=$($*)'

.PHONY: clean
clean: ${Cleaners}
> rm -rf ${BUILD_DIR}
> rm -rf ${STAGING_DIR}

SHELL = /bin/bash

ifeq (${MAKECMDGOALS},help)
define ModFwUsage
Usage: make [<option>=<value> ...] <target>

This make file and the included make segments define a framework
for developing and modifying devices or small embedded systems.

The collection of files for a given device or system is termed a mod.
Semantically, a mod is a modification of an existing device or system.
A mod can also be the development a new device or system.

ModFW directly supports the following design patterns. This pattern
is usable in most situations where remote access to devices is needed.
If necessary mods can either change the pattern or define a new one.

Design patterns:

  Direct:
  GW_ACCESS_METHOD = direct
  Direct interface to the MCU from the PC workstation.
  +-PC----------+   +-MCU--------+
  | Workstation |<->| Controller |
  +-CLI---------+ ^ +-CTL--------+
    GW            |
    UI            MCU defined
                  (typically serial port)

  Console:
  GW_ACCESS_METHOD = console
  Similar to direct but the SBC is the console interface.
  +-SBC---------+   +-MCU--------+
  | Wprkstation |->| Controller |
  +-CLI---------+ ^ +-CTL--------+
    GW            |
    UI            MCU defined
                  (typically serial port)

  Local network:
  GW_ACCESS_METHOD = ssh
  +-PC----------+   +-SBC-----+   +-MCU--------+
  | Workstation |<->| Gateway |<->| Controller |
  +-CLI---------+ ^ +-GW-----=+ ^ +-CTL--------+
    UI            |   UI        |
                  SSH           MCU defined
                                (typically serial port)

  Secure brokered remote access using SSH tunnels.
  GW_ACCESS_METHOD = brokered
  +-PC----------+   +-(cloud)+   +-SBC-----+   +-MCU--------+
  | Workstation |<->| Broker |<->| Gateway |<->| Controller |
  +-CLI---------+ ^ +-BKR----+ ^ +-GW------+ ^ +-CTL--------+
    UI            |            |   UI        |
                  SSH tunnel   SSH tunnel    MCU defined
                                             (typically serial port)

PC  = A personal computer.
SBC = A single board computer.
MCU = An embedded microcontroller.
CLI = Command line interface.
UI  = User interface either command line or graphical or both.
BKR = The broker hosted in the cloud.
GW  = Gateway (protocol conversion) between the CTL and the system.
CTL = The device controller.

A git repository is used to maintain one or more mods with each mod
having its own subdirectory within the git repository. The repository
is termed a kit.

This includes firmware for microcontroller boards or MCUs (e.g. Arduino),
OS images for single board computers or SBCs (e.g. Raspberry Pi), 3D
modeling and printing of cases and enclosures as well as the machines
they control.

All that is needed to get started is a clone of this repository and then
run make within the cloned directory. All of the necessary tools are
automatically installed within the context of the project directory so
that different projects can use different versions of tools without
conflicts between versions.

All of the CAD models are either downloaded as STLs from various websites or
are scripted using a corresponding scripting tool (e.g. 3D models using
OpenSCAD) which are then processed using the corresponding tool to
generate the corresponding output files. See the individual tool help targets
for more information.

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
  CAD_TOOL_3DP=${CAD_TOOL_3DP}
    Which scripted CAD tool to use for 3D printing. If left undefined it is
    assumed no 3D printed parts are in the mod.
    A scripted CAD tool is used to generate STLs for 3D printing or CNC
    machines. The STLs can be imported into slice or route software to
    generate gcode.
    Available tools are:
      openscad   OpenSCAD and SolidPython.
  CAD_TOOL_3DP_VARIANT=${CAD_TOOL_3DP_VARIANT}
    Which branch or release of the CAD tool to use.
  CAD_TOOL_LASER=${CAD_TOOL_LASER}
    Future
    Which scripted CAD tool to use for laser engraving or cutting. If left
    undefined it is assumed no laser produced parts are used.
    Available tools are:
      openscad   OpenSCAD and SolidPython.
  CAD_TOOL_LASER_VARIANT=${CAD_TOOL_LASER_VARIANT}
    Which branch or release of the CAD tool to use.
  CAD_TOOL_CNC=${CAD_TOOL_CNC}
    Future
    Which scripted CAD tool to use for CNC machining or engraving. If left
    undefined it is assumed no CNC parts are produced.
    Available tools are:
      openscad   OpenSCAD and SolidPython.
  CAD_TOOL_CNC_VARIANT=${CAD_TOOL_CNC_VARIANT}
    Which branch or release of the CAD tool to use.
  CAD_TOOL_PCB=${CAD_TOOL_PCB}
    Future
    Which scripted CAD tool to use for producing PCBs. If left undefined it
    is assumed no PCBs are produced.
  CAD_TOOL_PCB_VARIANT=${CAD_TOOL_PCB_VARIANT}
    Which branch or release of the CAD tool to use.

  Firmware runs on the device hardware.
  FIRMWARE=${FIRMWARE}
    Which firmware to build. If left undefined it is assumed no firmware
    is included in the mod.
    Available options are:
      marlin    Build marlin firmware.
  FIRMWARE_VARIANT=${FIRMWARE_VARIANT}
    Which branch or release of the firmware to use.

  Host user interface (HUI) software connects to the firmware running on the
  controller to provide monitoring and access via a GUI, console, or a network.
  The HUI uses devices such as keyboards, displays, and touch screens.
  GW_SOFTWARE=${GW_SOFTWARE}
    Which user interface software to use. User interface software is typcially
    hosted on an SBC. If not defined then GW_OS_VARIANT and GW_OS_BOARD are
    ignored.
  GW_OS_VARIANT=${GW_OS_VARIANT}
    The variant of the OS to use. This determines in which OS to install the
    initialization scripts. If undefined then an OS image will not be
    initialized.
  GW_OS_BOARD=${GW_OS_BOARD}
    The board on which the OS will run. This can also trigger the build
    of a 3D printed enclosuer for the board determined by the mod.

  Not defining CAD_TOOL_xxx, FIRMWARE, or GW_SOFTWARE will disable the
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
> @if [ -n '${ErrorMessages}' ]; then\
    echo Errors encountered:;\
    m='${ErrorMessages}';printf " $${m//nlnl/\\n}";\
    read -p "Press ENTER to continue...";\
  fi
> @echo "$$ModFwUsage" | less
else
  ifdef ErrorMessages
    $(error Errors encountered. See make help)
  endif
endif # help
