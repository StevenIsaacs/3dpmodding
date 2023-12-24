#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW config variables.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----

# Make segments and related files for specific features.
$(call Overridable,MK_PATH,${WorkingPath}/mk)

#+
# NOTE: The following directories are ignored (see .gitignore). These can be
# deleted by a clean.
#-
# For downloaded files.
$(call Overridable,DOWNLOADS_DIR,downloads)
$(call Overridable,DOWNLOADS_PATH,${WorkingPath}/${DOWNLOADS_DIR})

# Where intermediate build files are stored.
$(call Overridable,BUILD_DIR,build)
$(call Overridable,BUILD_PATH,${WorkingPath}/${BUILD_DIR})

# Where the mod output files are staged.
$(call Overridable,STAGING_DIR,staging)
$(call Overridable,STAGING_PATH,${WorkingPath}/${STAGING_DIR})

# Where various tools are downloaded and installed.
$(call Overridable,TOOLS_DIR,tools)
$(call Overridable,TOOLS_PATH,${WorkingPath}/${TOOLS_DIR})

# Where executables are installed.
$(call Overridable,BIN_DIR,bin)
$(call Overridable,BIN_PATH,${TOOLS_PATH}/${BIN_DIR})

# Default repo to use when creating new repos.
$(call Overridable,LOCAL_REPO,local)
# The default branch used when creating or cloning repos.
$(call Overridable,DEFAULT_BRANCH,main)

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

Defines the options shared by all modules.

Variables defined in helpers.mk:
WorkingPath = ${WorkingPath}
  The path to the working directory. This is typically the directory containing
  the ModFW makefile.
DEFAULT_STICKY_PATH = ${DEFAULT_STICKY_PATH}
  The default path to where sticky variables are stored.
STICKY_PATH = ${STICKY_PATH}
  The current path to where sticky variables are stored.
  NOTE: projects.mk changes this to point to the active project directory so
  that sticky variable values are maintained as part of the project repo.

Unless otherwise noted the following can be overridden either on the command
line or in overrides.mk. Using overrides eliminates the need to modify the
framework itself.

Make segment paths:
MK_PATH = ${MK_PATH}
  Where the included make segments are maintained for different build modules.

MODEL_MK_PATH = ${MODEL_MK_PATH}
  The path to the make segments corresponding to modeling tools.

HELPERS_PATH = ${HELPERS_PATH}
  Where helper scripts and utilities are maintained.

These may be deleted as part of a clean:
TOOLS_PATH = ${TOOLS_PATH}
  Where build tools are installed.
STAGING_PATH = ${STAGING_PATH}
  Where the build output files for a mod are staged. They are copied here
  so all output files are located in one place. Each kit and mod are staged
  in subdirectories. i.e. <staging_dir>/<kit>/<mod>
BIN_PATH = ${BIN_PATH}
  Where executable binaries for support utilities are installed.
DOWNLOADS_PATH = ${DOWNLOADS_PATH}
  Where the downloaded OS images and other mod specific files are stored.

For managing repos:
repo_classes = ${repo_classes}
  The classes which are repos.
containers = ${containers}
  Valid containeres.
LOCAL_REPO = ${LOCAL_REPO}
  The name used to indicate a component is local only (no remote or clone).
DEFAULT_BRANCH = ${DEFAULT_BRANC}
  The default branch name to use when creating a new repo or switch to after
  cloning an existing repo.

Other make segments can define sticky options. These are options which become
defaults once they have been used. Sticky options can also be preset in the
sticky directory which helps simplify automated builds especially when build
repeatability is required. Each sticky option has its own file in the sticky
directory making it possible to have dependencies on the individual sticky
files to detect when the options have changed.
STICKY_PATH = ${STICKY_PATH}
  Where sticky options are stored.

Command line goals:
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
