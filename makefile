#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW - A framework for modifying and developing devices.
#----------------------------------------------------------------------------
# Which branch of the helpers to use. Once the helpers have been cloned
# this is ignored.
HELPERS_BRANCH ?= main

# Helper scripts and utilities.
HELPERS_PATH := helpers
ifeq (${HELPERS_BRANCH},main)
  HELPERS_REPO := https://github.com/StevenIsaacs/modfw-helpers.git
else
  HELPERS_REPO := git@github.com:StevenIsaacs/modfw-helpers.git
endif

_helpers := ${HELPERS_PATH}/helpers.mk

# _helpers must be loaded almost immediately and defines some key variables
# such as .RECIPEPREFIX. Because of this can't rely upon make to trigger
# cloning at the correct time. Therefore, this takes a more direct approach.
_null := $(shell \
  if [ ! -f ${_helpers} ]; then \
    git clone ${HELPERS_REPO} ${HELPERS_PATH}; \
    cd ${HELPERS_PATH}; \
    git checkout ${HELPERS_BRANCH}; \
    git config pull.rebase true; \
  fi \
)

# Helper macros.
include ${_helpers}

# Using a conditional here because of needing to add a dependency on the
# overrides.mk only if it exists.
ifneq ($(wildcard overrides.mk),)
$(call Use-Segment,overrides)
endif

$(call Debug,STICKY_PATH = ${STICKY_PATH})
# This variable is in the default sticky directory.
$(call Sticky,PROJECT)
ifeq (${PROJECT},)
$(call Signal-Error,The sticky variable PROJECT must be defined.)
endif

# Config will change the sticky directory to be PROJECT specific.
$(call Use-Segment,config)

# Search path for loading segments. This can be extended by kits and mods.
$(call Add-Segment-Path,$(MK_PATH))

# Setup PROJECT specific configs. A project changes the STICKY_PATH to point
# to the project repo. This way sticky options are also under revision
# control.
$(call Use-Segment,projects)

$(call Debug,${PROJECT} STICKY_PATH = ${STICKY_PATH})

# This installs kits and uses a mod within a kit. A kit and mod extends the
# seg_paths variable as needed.
$(call Use-Segment,kits)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# The entire project.
#----------------------------------------------------------------------------

# mod_deps is defined by the mod.
all: ${MAKEFILE_LIST} ${mod_deps}

# cleaners is defined by the kit and the mod.
.PHONY: clean
clean: ${cleaners}
> rm -rf ${BUILD_PATH}
> rm -rf ${STAGING_PATH}

SHELL = /bin/bash

ifneq ($(filter help,$(Goals)),)
define _mod_fw_usage
Usage: make [<option>=<value> ...] [<goal>]

NOTE: This help is displayed if no goal is specified.

This make file and the included make segments define a framework for
developing new projects or modifying existing projects. A project can
consist of both software and hardware. A system is defined as all of the
software components needed by the project. A device is defined as all of
the hardware components needed by the project. All of the tools and existing
components needed to build the project are automatically downloaded,
configured and built if necessary.

The collection of files for a given device or system is termed a mod.
Semantically, a mod is a modification of an existing device or system or
a mod can also be the development a new device or system.

In the following, <seg> indicates a makefile segment (included file) where
<seg> is derived using the name of the makefile segment. Changing the name of
the file changes the name of the associated variables, macros and, goals.

An overrides file, overrides.mk, is supported where the developer can preset
variables rather than having to define them on the command line. This file is
intended to be temporary and is not maintained as part of the repository (i.e.
ignored in .gitignore). Additional kit and mod specific overrides can be
declared and maintained in an independent repository. See help-kits for more
information.

Naming conventions:
<seg>.mk        The name of a makefile segment. A makefile segment is designed
                to be included from another file. These should be formatted to
                contain a preamble and postamble. See help-helpers for more
                information.
GLOBAL_VARIABLE Can be overridden on the command line. Sticky variables should
                have this form. See help-helpers for more information about
                sticky variables.
global_variable Available to all segments but should not be overridden on the
                command line. Attempts to override can have unpredictable
                results.
<seg>_VARIABLE  A global variable prefixed with the name of the segment defining
                the variable. These can be overridden on the command line.
<seg>_variable  A global variable prefixed with the name of the segment
                defining the variable. These should not be overridden.
_private_variable Make segment specific. Should not be used by other segments
                since these can be changed without concern for other segments.
GlobalVariable  Camel case is used to identify variables defined by the
                helpers. This is mostly helpers.mk.
Callable-Macro  The name of a helper defined callable macro.
callable-macro  The name of a callable macro available to all segments.
_private-macro  A private macro specific to a segment.

Terms:
Workstation     A development workstation or a system administration
                workstation.
Proxy           Manages connections between workstations and gateways. This is
                typically hosted in the cloud.
Gateway         Serves as a protocol translator between the Controller and the
                workstation.
Controller      Controls the device hardware.

Hardware platforms:
PC  = A personal computer.
SBC = A single board computer.
MCU = An embedded microcontroller.
HDW = The device or machine being controlled. For example a 3D printer.

Hardware roles:
WS  = Development or administration workstation.
UI  = User interface either command line or graphical or both.
PRX = The proxy hosted in the cloud.
GW  = Gateway (protocol translation) between the CTL and the system.
CTL = The device controller.

ModFW directly supports the following design patterns. If necessary mods
can either change the patterns or define new ones.

Design patterns:

  Direct:
  MCU_ACCESS_METHOD = direct
  Direct interface to the MCU from a PC workstation. In this case there is
  no gateway and no OS image is staged.
  +-PC----------+   +-MCU--------+   +-HDW------+
  | Workstation |<->| Controller |<->| Hardware |
  +-WS----------+ ^ +-CTL--------+ ^ +----------+
    GW            |                |
    UI            MCU defined      Hardware system bus
                  (typically a
                  serial port)

  Console:
  MCU_ACCESS_METHOD = standalone
  Similar to direct but the SBC is the user interface and a corresponding
  OS image for the SBC is staged. In this case there is no network interface.
  Software updates in this case must be performed manually at the Gateway.
  +-SBC-----+   +-MCU--------+   +-HDW------+
  | Gateway |<->| Controller |<->| Hardware |
  +-GW------+ ^ +-CTL--------+ ^ +----------+
    UI        |                |
              MCU defined      Hardware system bus
              (typically a
              serial port)

  Local network:
  MCU_ACCESS_METHOD = headless
  SSH sessions are used to communicate with the Gateway and a corresponding
  OS image for the SBC is staged. The Gateway has no keyboard or display.
  +-PC----------+   +-SBC-----+   +-MCU--------+   +-HDW------+
  | Workstation |<->| Gateway |<->| Controller |<->| Hardware |
  +-WS----------+ ^ +-GW-----=+ ^ +-CTL--------+ ^ +----------+
    UI            |   UI        |                |
                  SSH           MCU defined      Hardware system bus
                                (typically a
                                serial port)

  MCU_ACCESS_METHOD = proxied
  Secure proxied remote access using SSH tunnels. A valid ModDev package is
  required and a corresponding OS image is staged. The ModDev package is also
  used to generate scripts for accessing the gateway from the workstation and
  for accessing the proxy from either the gateway or the workstation.
  +-PC----------+   +-(cloud)+   +-SBC-----+   +-MCU--------+   +-HDW------+
  | Workstation |<->| Proxy  |<->| Gateway |<->| Controller |<->| Hardware |
  +-WS----------+ ^ +-PRX----+ ^ +-GW------+ ^ +-CTL--------+ ^ +----------+
    UI            |            |   UI        |                |
                  SSH tunnel   SSH tunnel    MCU defined      Hardware system
                                             (typically a     bus
                                             serial port)

A separate git repository is used to maintain one or more mods with each mod
having its own subdirectory within the git repository. A repository
containing a collection of mods is termed a kit.

This includes (but is not limited to) firmware for microcontroller boards or MCUs (e.g. Arduino),
OS images for single board computers or SBCs (e.g. Raspberry Pi), 3D
modeling and printing of cases and enclosures as well as the machines
they control.

All that is needed to get started is a clone of this repository and then
run make within the cloned directory. All of the necessary tools are
automatically installed within the context of the project directory so
that different projects can use different versions of tools without
conflicts between versions.

Command line options:
  Required sticky options:
  PROJECT = ${PROJECT}
    Sticky option for the project name. This is stored in the helpers defined
    default sticky directory. Then the sticky path is changed to be project
    specific so that all subsequent sticky options are stored in the project
    specific directory. This allows quickly changing context from one project
    to another.
    See help-kits for additional required sticky options.

  For automated builds it is possible to preset options in another directory
  then overriding STICKY_PATH either in overrides.mk or on the command line.

Defines:
  seg_paths
    A list of paths to be searched when using additional make segments.
    NOTE: Kits and mods can extend this list (using +=). This list is then
    passed to the Use-Segment macro (see help-helpers).

Command line goals:
  all             The firmware is built and all assembly files are processed
                  to generate the 3D printable parts. Use show-mod_deps for
                  a list of goals.
  clean           Remove all of the build artifacts. This removes the build
                  and staging directories.

  Defined by a kit and mod:
  firmware        Build the mod firmware only.
  parts           3D printable parts only.
  os              Build the SBC OS only.
  clean           Remove the dependency files and the output files.
  reset-sticky    Resets ALL sticky variables so they have to be defined on
                  the command line again. This does not reset mod specific
                  sticky variables. For mods use the mod defined reset.
  clean-<seg>     Cleans a make segment output. See segment specific help
                  for more information.
  reset-<seg>-sticky
                  Reset segment specific variables. See segment specific
                  help for more information.

  Help and debug:
  help            Display this help message (default).
  show-mod_deps   Display the list of goals a mod is dependent upon.
  show-<variable> This is a special goal which can be used to display
                  any makefile variable and exit.
  help-<seg>      Display a make segment specific help.

endef

export _mod_fw_usage
.PHONY: help
help: display-errors display-messages
> @echo "$$_mod_fw_usage" | less
endif # help
