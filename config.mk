#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW config variables.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,ModFW config variables.)
$(call Display-Segs)
$(call Display-Seg-Attributes,${SegUN})

# -----
define _help
Make segment: ${Seg}.mk

Defines the options shared by all modules.

Unless otherwise noted the configuration variables are sticky variables which
can be overridden either on the command line or in overrides.mk. Using
overrides eliminates the need to modify the framework itself.

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
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Add-Help-Section,dirs,Directory names.)

_var := MK_NODE
$(call Sticky,${_var},mk)
define _help
${_var} = ${${_var}}
    The name of the directory containing the ModFW makefile segments.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := TESTING_PATH
$(call Sticky,${_var},${TmpPath}/testing)
define _help
${_var} = ${${_var}}
    The path to the root node which will contain test nodes. This is used to
    avoid polluting the projects directory.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := PROJECTS_PATH
$(call Sticky,${_var},${ModFW_path})
define _help
${_var} = ${${_var}}
    The path to the root node which will contain project nodes. This can be used
    to avoid polluting the ModFW directory itself.
    However, this defaults to the path to ModFW itself as defined by
    ModFW_path. Use this to change the location where projects are installed.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := PROJECTS_NODE
$(call Sticky,${_var},projects)
define _help
${_var} = ${${_var}}
    The name of the root node containing the project nodes.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := KITS_NODE
$(call Sticky,${_var},projects)
define _help
${_var} = ${${_var}}
    The name of the directory containing the kit repos.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := MODS_NODE
$(call Sticky,${_var},projects)
define _help
${_var} = ${${_var}}
    The name of the directory containing the mods within a kit repo.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := PROJECT_STICKY_NODE
$(call Sticky,${_var},${STICKY_NODE})
define _help
${_var} = ${${_var}}
    The name of the directory containing the project specific sticky variables.
    This defaults to the Helpers variable STICKY_NODE.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := BUILD_NODE
$(call Sticky,${_var},build)
define _help
${_var} = ${${_var}}
  The name of the directory where build intermediate files are stored.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := STAGING_NODE
$(call Sticky,${_var},staging)
define _help
${_var} = ${${_var}}
  The the name of the directory where deliverables files are stored.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := TOOLS_NODE
$(call Sticky,${_var},tools)
define _help
${_var} = ${${_var}}
  The the name of the directory where tools are stored and built if necessary.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := BIN_NODE
$(call Sticky,${_var},bin)
define _help
${_var} = ${${_var}}
  The the name of the directory where tools are installed.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := LIB_NODE
$(call Sticky,${_var},bin)
define _help
${_var} = ${${_var}}
  The the name of the directory where libraries used to build projects are
  installed.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := DOWNLOADS_NODE
$(call Sticky,${_var},downloads)
define _help
${_var} = ${${_var}}
  The name of the directory where downloaded files are stored.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := TESTS_NODE
$(call Sticky,${_var},test-suites)
define _help
${_var} = ${${_var}}
  The name of the directory where the testing segment is stored.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

$(call Add-Help-Section,repos,Repo defaults.)

_var := LOCAL_REPO
$(call Sticky,${_var},local)
define _help
${_var} = ${${_var}}
  Using this as a repo location says it is a local repo (no server).
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := GIT_ACCOUNT
$(call Sticky,${_var},StevenIsaacs)
define _help
${_var} = ${${_var}}
  The default server account to use when installing or creating a repo.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := GIT_SERVER
$(call Sticky,${_var},git@github.com)
define _help
${_var} = ${${_var}}
  The default server to use when installing or creating a repo.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := DEFAULT_URL
$(call Sticky,${_var},${GIT_SERVER}/${GIT_ACCOUNT})
define _help
${_var} = ${${_var}}
  The default URL minus the repo name to use when installing or creating a repo.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := DEFAULT_BRANCH
$(call Sticky,${_var},main)
define _help
${_var} = ${${_var}}
  The branch to checkout by default when installing or creating a repo.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

$(call Add-Help-Section,structure,ModFW directory structure.)
_h := modfw_structure
define _help
${_h}
Legend:
>-  A node name (see help-nodes).
--  A directory.
|   One or more files within a directory.
... Repeats the previous node sub-structure.
<a> Indicates a node or file name defined by a variable.

ModFW is a repo containing the ModFW components needed to build projects or
test ModFW. The directory containing the ModFW repo is the root node. All
other nodes are children of the ModFW root node. As a result, all directories
are sub-directories of the ModFW directory.

>-ModFW_node # All other nodes are children of this node.
  --.git
    | Files managed by git
  | .gitignore # Ignores STICKY_NODE, DOWNLOADS_NODE and, PROJECTS_NODE.
  | makefile
  >-$${MK_NODE} = ${MK_NODE}
    ModFW makefile segments
  >-$${TESTS_NODE} = ${TESTS_NODE}
    ModFW makefile segments for testing ModFW

  The following nodes are not part of the ModFW repo.

  >-$${STICKY_NODE} = ${STICKY_NODE}
    Top level sticky variable save files. Ths location of this node is defined
    by STICKY_PATH which is defined by the helpers (see help-helpers).
  >-$${DOWNLOADS_NODE} = ${DOWNLOADS_NODE}
    Where downloaded tools and components are stored. Multiple projects can
    reference these to avoid redundant downloads. The variable DOWNLOADS_PATH
    defines the location of this node.
  >-$${PROJECTS_NODE} = ${PROJECTS_NODE}
    Contains all projects. The location of this node is defined by
    PROJECTS_PATH.

    The PROJECTS_NODE contains all of the installed projects. Each project is a
    separate repo.

    The active project is the top level or focus. The project then "uses" one or
    more mods. Mods can then "use" additional mods and even mods from other
    kits to build components they may be dependent upon. Dependency trees
    should always begin with the active project.

    Projects are intended to be self contained meaning all build artifacts along
    with the tools needed to build them are contained within the project
    directory structure. This helps avoid version conflicts between projects
    which use the same but different versions of kits or tools. This also helps
    avoid situations where removing a project breaks the build of another
    project or results in orphaned build artifacts.

    Projects cannot reference or be dependent upon files contained in other
    projects.

    The ModFW project directory structure is:

    >-$${PROJECT} = ${PROJECT} <project> (repo)
      | .gitignore (ignores projects, tools, bin, build and staging)
      | <project>.mk
      | project defined files
      --.git
        | Files managed by git
      >-$${PROJECT}.$${STICKY_NODE} = ${STICKY_NODE}
        | project specific sticky variable save files
      >-$${PROJECT}.$${BUILD_NODE} = ${BUILD_NODE}
        | project build files
      >-$${PROJECT}.$${STAGING_NODE} ${STAGING_NODE}
        | project staged files
      >-$${PROJECT}.$${TOOLS_NODE}
        >-<tool>
          | tool specific files used for building the tools
        >-<tool>...
      >-$${PROJECT}.$${LIB_NODE}
        >-<lib>
          | installed library files
        >-<lib>...
      >-$${PROJECT}.$${BIN_NODE}
        | installed tools and utilities
      >-$${PROJECT}.$${KITS_NODE} = ${KITS_NODE}
        A project contains a collection of kits needed to build the project.
        Each kit is a separate repo.
        >-<kit> (repo) (see help-kits)
          --.git
            | Files managed by git
          | .gitignore
          | <kit>.mk
          | kit defined files
          >-<kit>.$${MODS_NODE} = ${MODS_NODE}
            A kit contains a collection of mods. The mods are part of the
            containing kit repo.
            >-<kit>.<mod> (see help-mods)
              | <mod>.mk
              | mod defined files
              >-<kit>.<mod>.$${BUILD_NODE}
                | mod build files
              >-<kit>.<mod>.$${STAGING_NODE}
                | mod staged files
            >-<kit>.<mod>...
          >-<kit>.$${BUILD_NODE}
            | kit build files
          >-<kit>.$${STAGING_NODE}
            | kit staged files
        >-<kit>... (repo)
    >-<project>... (repo)

endef
help-${_h} := $(call _help)
$(call Add-Help,${_h})

# +++++
# Postamble
# Define help only if needed.
$(call Verbose,Seg=${Seg} SegUN=${SegUN} SegID=${SegID})
__h := \
  $(or \
    $(call Is-Goal,help-${Seg}),\
    $(call Is-Goal,help-${SegUN}),\
    $(call Is-Goal,help-${SegID}))
ifneq (${__h},)
define __help
$(call Display-Help-List,${SegID})
endef
${__h} := ${__help}
endif # help goal message.

$(call Exit-Segment)
else # <u>SegID exists
$(call Check-Segment-Conflicts)
endif # <u>SegID
# -----
