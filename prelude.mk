#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Standard makefile prelude to setup standard options and helpers.
#----------------------------------------------------------------------------

# Changing the prefix because some editors, like vscode, don't handle tabs
# in make files very well. This also slightly improves readability.
.RECIPEPREFIX := >
SHELL = /bin/bash
.DEFAULT_GOAL := all

ifndef ProjectDir
$(error ProjectDir must be defined.)
endif

$(info ProjectDir: ${ProjectDir})
ProjectName := $(notdir ${ProjectDir})
$(info ProjectName: ${ProjectName})
# The name of the project. Can be overridden on the command line.
PROJECT := ${ProjectName}

# For storing sticky options.
STICKY_DIR ?= ${ProjectDir}/.${PROJECT}/sticky

# Helper scripts and utilities.
HELPERS_DIR := ${ProjectDir}/helpers
# These are helper functions for shell scripts (Bash).
HELPER_FUNCTIONS := ${HELPERS_DIR}/modfw-functions.sh

ifeq (${HELPERS_VARIANT},dev)
  HELPERS_REPO := git@github.com:StevenIsaacs/modfw-helpers.git
else
  HELPERS_REPO := https://github.com/StevenIsaacs/modfw-helpers.git
  HELPERS_VARIANT := main
endif

Macros := ${HELPERS_DIR}/macros.mk

CoreDeps := ${Macros}

# Macros must be loaded almost immediately. Because of this can't rely
# upon make to trigger cloning at the correct time. Therefore, this takes
# a more direct approach.
_null := $(shell \
  if [ ! -f ${Macros} ]; then \
    git clone ${HELPERS_REPO} ${HELPERS_DIR}; \
    cd ${HELPERS_DIR}; \
    git checkout ${HELPERS_VARIANT}; \
    git config pull.rebase true; \
  fi \
)

# Helper macros.
include ${Macros}

# This is structured so that help-kits can be used to determine which kits
# are avialable without loading any kit or mod.
ifeq (${MAKECMDGOALS},help-standard)
define HelpStandardMsg
Make segment: standard.mk

This is a standard makefile prelude which defines options common to ModFW
makefiles.

Clone the helpers. The clone is triggered by including the macros. This must
be included as early as possible.

Uses (must be defined):
  ProjectDir = ${ProjectDir}
    The path to the directory containing the makefile is the project directory.

Defines:
  Project = ${Project}
    The name of the directory containing the makefile is the name of the
    project.
  CoreDeps = ${CoreDeps}
    Core depencies. Other modules can add to this.

Defined but can be overridden on the command line:
  PROJECT := ${PROJECT}
    The name of this project.
  HELPERS_DIR := ${HELPERS_DIR}
    Where helper scripts and utilities are maintained.
  HELPERS_FUNCTIONS := ${HELPER_FUNCTIONS}
    Helper functions for use in Bash scripts.
  HELPERS_VARIANT = ${HELPERS_VARIANT}
    Which variant or branch to checkout. This defaults to 'main'. Using the
    devleopment variant (dev) requires valid github credentials. This needs
    to be used once to set variant. Once the helpers have been cloned this is
    no longer needed.
  STICKY_DIR := ${STICKY_DIR}
    Where sticky options are stored.

Command line targets:
  help-standard     Display this help.

endef

export HelpStandardMsg
help-standard:
> @echo "$$HelpStandardMsg" | less

endif # help-standard
