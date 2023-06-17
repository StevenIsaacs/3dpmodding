#+
# Override these on the make command line or in overrides.mk as needed.
# Using overrides it should not be necessary to modify the makefiles.
#-
# Changing the prefix because some editors, like vscode, don't handle tabs
# in make files very well. This also slightly improves readability.
.RECIPEPREFIX := >
SHELL = /bin/bash

ProjectPath = $(realpath $(dir $(realpath $(firstword ${MAKEFILE_LIST}))))

$(info ProjectPath: ${ProjectPath})
ProjectName := $(notdir ${ProjectPath})
$(info ProjectName: ${ProjectName})
# The name of the project. Can be overridden on the command line.
PROJECT := ${ProjectName}

# Using a conditional here because of needing to add a dependency on the
# overrides.mk only if it exists.
ifneq (,$(wildcard overrides.mk))
include ${ProjectPath}/overrides.mk
$(eval $(call add-to-manifest,CoreDeps,null,overrides.mk))
endif

#+
# NOTE: The following directories are ignored (see .gitignore). These can be
# deleted by a clean.
#-
# For downloaded files.
DOWNLOADS_PATH ?= ${ProjectPath}/downloads

# Where intermediate build files are stored.
BUILD_PATH ?= ${ProjectPath}/build

# Where the mod output files are staged.
STAGING_PATH ?= ${ProjectPath}/staging

# Where various tools are downloaded and installed.
TOOLS_PATH ?= ${ProjectPath}/tools

# Where executables are installed.
BIN_PATH ?= ${TOOLS_PATH}/bin

# For storing sticky options.
STICKY_PATH ?= ${ProjectPath}/.${PROJECT}/sticky

# Which variant of the helpers to use. Once the helpers have been cloned
# this is ignored.
HELPERS_VARIANT ?= main

# Helper scripts and utilities.
HELPERS_PATH := ${ProjectPath}/helpers
# These are helper functions for shell scripts (Bash).
HELPER_FUNCTIONS := ${HELPERS_PATH}/modfw-functions.sh

ifeq (${HELPERS_VARIANT},main)
  HELPERS_REPO := https://github.com/StevenIsaacs/modfw-helpers.git
else
  HELPERS_REPO := git@github.com:StevenIsaacs/modfw-helpers.git
endif

Macros := ${HELPERS_PATH}/macros.mk

CoreDeps := ${Macros}

# Macros must be loaded almost immediately. Because of this can't rely
# upon make to trigger cloning at the correct time. Therefore, this takes
# a more direct approach.
_null := $(shell \
  if [ ! -f ${Macros} ]; then \
    git clone ${HELPERS_REPO} ${HELPERS_PATH}; \
    cd ${HELPERS_PATH}; \
    git checkout ${HELPERS_VARIANT}; \
    git config pull.rebase true; \
  fi \
)

# Helper macros.
include ${Macros}

# Toolset classes. These are used to build paths among other things.
MODEL_CLASS ?= model
FIRMWARE_CLASS ?= firmware
PCB_CLASS ?= pcb
GW_OS_CLASS ?= gw_os
GW_UI_CLASS ?= gw_ui

# Make segments and related files for specific features.
MK_PATH ?= ${ProjectPath}/mk

MODEL_MK_PATH ?= ${MK_PATH}/${MODEL_CLASS}

FIRMWARE_MK_PATH ?= ${MK_PATH}/${FIRMWARE_CLASS}
PCB_MK_PATH ?= ${MK_PATH}/${PCB_CLASS}

GW_OS_PATH ?= ${MK_PATH}/${GW_OS_CLASS}
GW_UI_PATH ?= ${MK_PATH}/${GW_UI_CLASS}

# A kit is a collection of mods.
# Where kit configurations are located. Override this for custom kits.
KIT_CONFIGS_PATH ?= ${ProjectPath}/kit-configs
# Where the mod kits are cloned to.
KITS_PATH ?= ${ProjectPath}/kits
# The development git server for supported kits.
KIT_DEV_SERVER ?= git@github.com:StevenIsaacs
# The release git server for supported kits.
KIT_REL_SERVER ?= https://github.com/StevenIsaacs

ifneq ($(findstring help-config,${MAKECMDGOALS}),)
define HelpConfigMsg
Make segment: config.mk

Defines the options shared by all modules.

These can be overridden either on the command line or in overrides.mk.
Using overrides eliminates the need to modify the framework itself.

Defines:
Mod toolset classes are used to organize mods into more manageable groups.
MODEL_CLASS = ${MODEL_CLASS}
  2D and 3D modeling tools. These are used to model physical components of a
  mod such as an enclosure for a PCB or a component of a mechanism.
FIRMWARE_CLASS = ${FIRMWARE_CLASS}
  Firmware for embedded microcontrollers.
PCB_CLASS = ${PCB_CLASS}
  The PCB for which the Firmware is designed to control.
GW_OS_CLASS = ${GW_OS_CLASS}
  To build and/or configure an OS image intended to be run on the Gateway. The
  UI runs in this OS environment.
GW_UI_CLASS = ${GW_UI_CLASS}
  The UI or app which runs on the Gateway.

Make segment paths.
MK_PATH = ${MK_PATH}
  Where the included make segments are maintained for different build modules.

MODEL_MK_PATH = ${MODEL_MK_PATH}
  The path to the make segments corresponding to modeling tools.

FIRMWARE_MK_PATH = ${FIRMWARE_MK_PATH}
  The path to the make segments corresponding to tools used to build firmware.
PCB_MK_PATH = ${PCB_MK_PATH}
  The path to the make segments corresponding to tools used to create PCBs for
  the firmware.

GW_OS_PATH = ${GW_OS_PATH}
  The path to the make segments corresponding to tools used to build the OS
  intended to run on the Gateway.
GW_UI_PATH = ${GW_UI_PATH}
  The path to the make segments corresponding to tools used to build the UI
  or app for the Gateway.

HELPERS_PATH = ${HELPERS_PATH}
  Where helper scripts and utilities are maintained.
KIT_CONFIGS_PATH = ${KIT_CONFIGS_PATH}
  Where mod kit definitions are maintained. Override this for custom
  mod kit definitions.
KITS_PATH = ${KITS_PATH}
  Where mod kits are cloned to.
KIT_DEV_SERVER = ${KIT_DEV_SERVER}
  The git server from which development versions of supported kits are cloned.
  Access to the dev variant requires valid credentials.
KIT_REL_SERVER = ${KIT_REL_SERVER}
  The git server from which released versioins of supported kits are cloned.
  Credentials are not required.

These may be deleted as part of a clean.
STAGING_PATH = ${STAGING_PATH}
  Where the build output files for a mod are staged. They are copied here
  so all output files are located in one place. Each kit and mod are staged
  in subdirectories. i.e. <staging_dir>/<kit>/<mod>
TOOLS_PATH = ${TOOLS_PATH}
  Where build tools are installed.
BIN_PATH = ${BIN_PATH}
  Where executable binaries for support utilities are installed.
DOWNLOADS_PATH = ${DOWNLOADS_PATH}
  Where the downloaded OS images and other mod specific files are stored.

Other make segments can define sticky options. These are options which become
defaults once they have been used. Sticky options can also be preset in the
stick directory which helps simplify automated builds especially when build
repeatability is required.
STICKY_PATH = ${STICKY_PATH}
  Where sticky options are stored.

endef

export HelpConfigMsg
help-config:
> @echo "$$HelpConfigMsg" | less
endif
