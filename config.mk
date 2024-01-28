#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW config variables.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,ModFW config variables.)
# -----

_var := MK_PATH
$(call Overridable,${_var},${WorkingPath}/mk)
define _help
${_var} = ${${_var}}
  The path to the ModFW makefile segments. This is the primary segment search
  path.
endef
help-${_var} := $(call _help)

#+
# NOTE: The following directories are ignored by git(see .gitignore). These can
# be deleted by a clean.
#-
_var := DOWNLOADS_DIR
$(call Overridable,${_var},downloads)
define _help
${_var} = ${${_var}}
  The name of the directory where downloaded files are stored.
endef
help-${_var} := $(call _help)

_var := DOWNLOADS_PATH
$(call Overridable,${_var},${WorkingPath}/${DOWNLOADS_DIR})
define _help
${_var} = ${${_var}}
  The name of the directory where downloaded files are stored.
endef
help-${_var} := $(call _help)

_var := BUILD_DIR
$(call Overridable,${_var},build)
define _help
${_var} = ${${_var}}
  The name of the directory where build intermediate files are stored.
endef
help-${_var} := $(call _help)

_var := BUILD_PATH
$(call Overridable,${_var},${WorkingPath}/${BUILD_DIR})
define _help
${_var} = ${${_var}}
  The full path to where build intermediate files are stored.
endef
help-${_var} := $(call _help)

_var := STAGING_DIR
$(call Overridable,${_var},staging)
define _help
${_var} = ${${_var}}
  The the name of the directory where deliverables files are stored.
endef
help-${_var} := $(call _help)

_var := STAGING_PATH
$(call Overridable,${_var},${WorkingPath}/${STAGING_DIR})
define _help
${_var} = ${${_var}}
  The full path to where deliverable files are stored.
endef
help-${_var} := $(call _help)

_var := TOOLS_DIR
$(call Overridable,${_var},tools)
define _help
${_var} = ${${_var}}
  The the name of the directory where tools are stored.
endef
help-${_var} := $(call _help)

_var := TOOLS_PATH
$(call Overridable,${_var},${WorkingPath}/${TOOLS_DIR})
define _help
${_var} = ${${_var}}
  The the full path to where tools are stored.
endef
help-${_var} := $(call _help)

_var := BIN_DIR
$(call Overridable,${_var},bin)
define _help
${_var} = ${${_var}}
  The the name of the directory where tools are installed.
endef
help-${_var} := $(call _help)

_var := BIN_PATH
$(call Overridable,${_var},${TOOLS_PATH}/${BIN_DIR})
define _help
${_var} = ${${_var}}
  The full path to where tools are installed.
endef
help-${_var} := $(call _help)

_var := LOCAL_REPO
$(call Overridable,${_var},local)
define _help
${_var} = ${${_var}}
  Using this as a repo location says it is a local repo (no server).
endef
help-${_var} := $(call _help)

_var := DEFAULT_SERVER
$(call Overridable,${_var},git@github.com/StevenIsaacs)
define _help
${_var} = ${${_var}}
  The default server to use when installing or creating a repo.
endef
help-${_var} := $(call _help)

_var := DEFAULT_BRANCH
$(call Overridable,${_var},main)
define _help
${_var} = ${${_var}}
  The branch to checkout by default when installing or creating a repo.
endef
help-${_var} := $(call _help)

# +++++
# Postamble
# Define help only if needed.
__h := $(or $(call Is-Goal,help-${SegUN}),$(call Is-Goal,help-${SegID}))
ifneq (${__h},)
$(call Attention,Generating help for:${Seg})
define __help
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

${help-MK_PATH}

${help-DOWNLOADS_DIR}

${help-DOWNLOADS_PATH}

${help-BUILD_DIR}

${help-BUILD_PATH}

${help-STAGING_DIR}

${help-STAGING_PATH}

${help-TOOLS_DIR}

${help-TOOLS_PATH}

${help-BIN_DIR}

${help-BIN_PATH}

${help-LOCAL_REPO}

${help-DEFAULT_BRANCH}

Other make segments can define sticky options. These are options which become
defaults once they have been used. Sticky options can also be preset in the
sticky directory which helps simplify automated builds especially when build
repeatability is required. Each sticky option has its own file in the sticky
directory making it possible to have dependencies on the individual sticky
files to detect when the options have changed.
STICKY_PATH = ${STICKY_PATH}
  Where sticky options are stored.

Command line goals:
  help-${SegUN}
    Display this help.
endef
${__h} := ${__help}
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
