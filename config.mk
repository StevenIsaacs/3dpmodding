#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW config variables.
#----------------------------------------------------------------------------
# The prefix config must be unique for all files.
# The format of all the config based names is required.
# +++++
# Preamble
ifndef configSegId
$(call Enter-Segment,config)
# -----

#+
# Override these on the make command line or in overrides.mk as needed.
# Using overrides it should not be necessary to modify the makefiles.
#-

# For storing sticky options.
STICKY_PATH := ${ProjectPath}/.${PROJECT}/sticky
# The name of the project. Can be overridden on the command line.
PROJECT := ${ProjectName}

# Make segments and related files for specific features.
MK_PATH ?= ${ProjectPath}/mk

# A kit is a collection of mods.
# Where the mod kits are cloned to.
DEFAULT_KITS_PATH ?= ${ProjectPath}/kits

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

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${configSeg}),)
define help_${configSegN}_msg
Make segment: ${configSeg}.mk

Defines the options shared by all modules.

These can be overridden either on the command line or in overrides.mk.
Using overrides eliminates the need to modify the framework itself.

Defines:

Make segment paths.
MK_PATH = ${MK_PATH}
  Where the included make segments are maintained for different build modules.

MODEL_MK_PATH = ${MODEL_MK_PATH}
  The path to the make segments corresponding to modeling tools.

HELPERS_PATH = ${HELPERS_PATH}
  Where helper scripts and utilities are maintained.

Default sticky values.
DEFAULT_KIT_CONFIGS_PATH = ${DEFAULT_KIT_CONFIGS_PATH}
  Where mod kit definitions are maintained.
DEFAULT_KITS_PATH = ${DEFAULT_KITS_PATH}
  Where mod kits are cloned to.
DEFAULT_KIT_DEV_SERVER = ${DEFAULT_KIT_DEV_SERVER}
  The git server from which development versions of supported kits are cloned.
  Access to the dev version requires valid credentials.
DEFAULT_KIT_REL_SERVER = ${DEFAULT_KIT_REL_SERVER}
  The git server from which released versions of supported kits are cloned.
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

Command line goals:
  help-${configSeg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment,config)
else # configSegId exists
$(call Check-Segment-Conflicts,config)
endif # configSegId
# -----
