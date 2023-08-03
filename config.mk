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

# For storing sticky options in a known location.
DEFAULT_STICKY_PATH := ${WorkingPath}/.${WorkingName}/sticky

# NOTE: This is changed on the fly by projects.mk to point to a project
# specific sticky directory.
STICKY_PATH := ${DEFAULT_STICKY_PATH}

# Make segments and related files for specific features.
$(call Overridable,MK_PATH,${WorkingPath}/mk)

# A kit is a collection of mods. Each kit is a separate git repo.
# The directory containing the kit repos.
$(call Overridable,DEFAULT_KITS_DIR,kits)
# Where the mod kits are cloned to.
# NOTE: This is ignored in .gitignore.
$(call Overridable,DEFAULT_KITS_PATH,${WorkingPath}/${DEFAULT_KITS_DIR})

# The directory containing the projects repo.
# NOTE: This is ignored in .gitignore.
$(call Overridable,DEFAULT_PROJECTS_DIR,projects)
# Where project specific kit and mod configuration repo is maintained.
$(call Overridable,DEFAULT_PROJECTS_PATH,${WorkingPath}/${DEFAULT_PROJECTS_DIR})
# If this is not equal to "local" then a remote repo is cloned to create
# the project specific configurations. Otherwise, a new git repository is
# created and initialized.
$(call Overridable,DEFAULT_PROJECTS_REPO,local)
# The branch used by the active project.
$(call Overridable,DEFAULT_PROJECTS_BRANCH,main)

#+
# NOTE: The following directories are ignored (see .gitignore). These can be
# deleted by a clean.
#-
# For downloaded files.
$(call Overridable,DOWNLOADS_PATH,${WorkingPath}/downloads)

# Where intermediate build files are stored.
$(call Overridable,BUILD_PATH,${WorkingPath}/build)

# Where the mod output files are staged.
$(call Overridable,STAGING_PATH,${WorkingPath}/staging)

# Where various tools are downloaded and installed.
$(call Overridable,TOOLS_PATH,${WorkingPath}/tools)

# Where executables are installed.
$(call Overridable,BIN_PATH,${TOOLS_PATH}/bin)

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
WorkingPath = ${WorkingPath}
  The path to the directory containing the top level makefile.
WorkingName = ${WorkingName}
  The name associated with the top level makefile derived from the
  WorkingPath.

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
DEFAULT_KIT_CONFIGS_PATH = ${DEFAULT_KIT_CONFIGS_PATH}
  Where generated config files are stored.

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
sticky directory which helps simplify automated builds especially when build
repeatability is required. Each sticky option has its own file in the sticky
directory making it possible to have dependencies on the individual sticky
files to detect when the options have changed.
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
