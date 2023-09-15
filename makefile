#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW - A framework for modifying and developing devices.
# NOTE: ModFW is not a build tool. Rather it is a framework for integrating
# a variety of build and development tools.
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

# Config will change the sticky directory to be PROJECT specific.
$(call Use-Segment,config)

# Search path for loading segments. This can be extended by kits and mods.
$(call Add-Segment-Path,$(MK_PATH))

# Common macros for ModFW segments.
$(call Use-Segment,macros)

$(call Debug,STICKY_PATH = ${STICKY_PATH})

# Setup PROJECT specific variables and goals. A project changes the STICKY_PATH
# to point to the project repo. This way sticky options are also under revision
# control.
$(call Use-Segment,projects)

ifdef APPEND
  $(call Use-Segment,${APPEND})
endif

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

This is the top level make file for ModFW. NOTE: ModFW is not a build system.
Instead, ModFW is intended to integrate a variety of build systems which are
used to build both software and hardware components and products.

NOTE: This help is displayed if no goal is specified.

This make file and the included make segments define a framework for
developing new products or modifying existing products. A product can
consist of both software and hardware. A system is defined as all of the
software components needed by the product. A device is defined as all of
the hardware components needed by the product. All of the tools and existing
components needed to build the product are automatically downloaded,
configured and built if necessary.

Definitions:
  repo: A git repository.

  container: A directory containing project or kit repos.

  MOD: The collection of files for a given device or system is termed a mod.
  Semantically, a mod is a modification of an existing device or system or
  a mod can also be the development a new device or system. A mod can be
  dependent upon other mods.

  KIT: A kit is a collection of mods. Each kit is a separate git repository and
  is cloned from the remote repository when needed. New kits can be created
  locally.

  PROJECT: A project is the collection of files which define a product. This
  can be as simple as a single makefile segment but should at minimum be the
  repository for the product documentation. A project is maintained as a
  separate git repository. Similar to a kit, a project is automatically cloned
  when needed or can be created locally. The makefile segment for the project
  should define the kit repo URLs and branches. One project can be the "active"
  project. Sticky variables are stored in the active project directory.

  component: A project, kit or, mod. Each component has a unique name which is
  used to name component attributes (see help-macros). Each component contains
  a makefile segment having the name <component>.mk which is included when the
  component is referenced.

  <seg>: Indicates a makefile segment (included file) where <seg> is derived
  using the name of the makefile segment. Changing the name of the file changes
  the name of the associated variables, macros and, goals. <seg> is also used
  to name project and kit repositories.

Repositories and branches:
  As previously mentioned projects and kits are separate git repositories. Mods
  can be dependent upon the output of other projects and kits. Different mods
  can be dependent upon different versions of projects and kits. Managing this
  potential web of dependencies can be a nightmare and lead to disk thrashing
  when switching to different branches because of mod dependencies. Therefore,
  only one branch of a repository can be active. The branch can be specified at
  the time the repository is cloned. Thereafter branches must be switched
  manually and all interdependent components can only use the same branch of a
  given repository.

Naming conventions:
<seg>           The name of a segment. This is used to declare segment specific
                variables and to derive directory and file names. As a result
                no two segments can have the same file name.
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
callable-macro  The name of a callable macro available to all segments.
_private-macro  A private macro specific to a segment.
GlobalVariable  Camel case is used to identify variables defined by the
                helpers. This is mostly helpers.mk.
Callable-Macro  The name of a helper defined callable macro.

WARNING: Even though make allows variable names to begin with a numeric
character this must be avoided for all variable names since they may be
exported to the environment to be passed to bash. If a numeric character is
used as the first character of a variable name unpredictable behavior can
occur. This is particularly important for PROJECT, KIT, MOD and, segment
names.

Overriding variables:
An overrides file, overrides.mk, is supported where the developer can preset
variables rather than having to define them on the command line. This file is
intended to be temporary and is not maintained as part of the repository (i.e.
ignored in .gitignore). Additional kit and mod specific overrides can be
declared and maintained in an independent repository. See help-kits for more
information.

Architectural components:
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

Getting started:
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
    To help avoid naming conflicts use the prefix prj- when naming projects.
    See help-kits for additional required sticky options.

  For automated builds it is possible to preset options in another directory
  then overriding STICKY_PATH either in overrides.mk or on the command line.

  APPEND = ${APPEND}
    When defined on the command line this triggers the inclusion of a makefile
    segment named by APPEND. This segment is loaded last after all other
    segments have been loaded. The Use-Segment macro is used to find and load
    the segment so segment search paths will be used (see help-helpers for more
    information).
    For example: "make APPEND=test" will load the makefile segment named
    test.mk.

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
