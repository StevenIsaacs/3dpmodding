#+
# Override these on the make command line or in overrides.mk as needed.
# Using overrides it should not be necessary to modify the makefiles.
#-

# Some behavior depends upon which platform.
ifeq ($(shell grep WSL /proc/version > /dev/null; echo $$?),0)
  Platform = Microsoft
else ifeq ($(shell echo $$(expr substr $$(uname -s) 1 5)),Linux)
  Platform = Linux
else ifeq ($(shell uname),Darwin)
# Detecting OS X is untested.
  Platform = OsX
else
  $(error Unable to identify platform)
endif
$(info Running on: ${Platform})

# Helper scripts and utilities.
HELPER_DIR = ${project_dir}/helpers

# Make segments and related files for specific features.
MK_DIR = ${project_dir}/mk

# A kit is a collection of mods.
# Where kit configurations are located. Override this for custom kits.
KIT_CONFIGS_DIR = ${project_dir}/kit-configs
# Where the mod kits are cloned to.
KITS_DIR = ${project_dir}/kits
# The development git server for supported kits.
KIT_DEV_SERVER = git@github.com:StevenIsaacs
# The release git server for supported kits.
KIT_REL_SERVER = https://github.com/StevenIsaacs

#+
# NOTE: The following directories are ignored (see .gitignore). These can be
# deleted by a clean.
#-
# Where the mod output files are staged.
STAGING_DIR = ${project_dir}/staging

# Where various tools are downloaded and installed.
TOOLS_DIR = ${project_dir}/tools

# Where executables are installed.
BIN_DIR = ${TOOLS_DIR}/bin

# For downloaded files.
DOWNLOADS_DIR = ${TOOLS_DIR}/downloads

# For storing sticky options.
STICKY_DIR = ${project_dir}/.modfw/sticky

include ${HELPER_DIR}/macros.mk

ifneq ($(findstring help-config,${MAKECMDGOALS}),)
define HelpConfigMsg
Make segment: config.mk

Defines the options shared by all modules.

These can be overridden either on the command line or in overrides.mk.
Using overrides eliminates the need to modify the framework itself.

Defines:
HELPER_DIR = ${HELPER_DIR}
  Where helper scripts and utilities are maintained.
MK_DIR = ${MK_DIR}
  Where the included make segments are maintained for different build modules.
KIT_CONFIGS_DIR = ${KIT_CONFIGS_DIR}
  Where mod kit definitions are maintained. Override this for custom
  mod kit definitions.
KITS_DIR = ${KITS_DIR}
  Where mod kits are cloned to.
KIT_DEV_SERVER = ${KIT_DEV_SERVER}
  The git server from which development versions of supported kits are cloned.
  Access to the dev variant requires valid credentials.
KIT_REL_SERVER = ${KIT_REL_SERVER}
  The git server from which released versioins of supported kits are cloned.
  Credentials are not required.

These may be deleted as part of a clean.
STAGING_DIR = ${STAGING_DIR}
  Where the build output files for a mod are staged. They are copied here
  so all output files are located in one place. Each kit and mod are staged
  in subdirecties. i.e. <staging_dir>/<kit>/<mod>
TOOLS_DIR = ${TOOLS_DIR}
  Where build tools are installed.
BIN_DIR = ${BIN_DIR}
  Where executable binaries are installed.
DOWNLOADS_DIR = ${DOWNLOADS_DIR}
  Where the downloaded OS compressed files are placed.
STICKY_DIR = ${STICKY_DIR}
  Where sticky options are stored.

Other make segments can define stick options. These are options which become
defaults once they have been used. Sticky optons can also be preset in the
stick directory which helps simplify automated builds especially when build
repeatability is required.

sticky
  A callable macro for setting sticky options. This can be used in a mod
  using a mod specific sticky directory. An option becomes sticky only
  if it hasn't been previously defined. The parameters are:
  1 = The name of the sticky variable.
  2 = Optional: Where to store the sticky variable.
      Defaults to STICKY_DIR

Sticky options are:
  ${_StickyOptions}
endef

export HelpConfigMsg
help-config:
	@echo "$$HelpConfigMsg" | less
endif
