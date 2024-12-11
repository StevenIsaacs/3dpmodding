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

_var := MK_DIR
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

_var := STICKY_DIR
$(call Sticky,${_var},${STICKY_DIR})
define _help
${_var} = ${${_var}}
  The name of the node containing the overall sticky variables. This defaults
  to the helpers variable STICKY_DIR.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := PROJECTS_DIR
$(call Sticky,${_var},projects)
define _help
${_var} = ${${_var}}
  The name of the root node containing the project nodes.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := KITS_DIR
$(call Sticky,${_var},kits)
define _help
${_var} = ${${_var}}
  The name of the directory containing the kit repos.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := MODS_DIR
$(call Sticky,${_var},mods)
define _help
${_var} = ${${_var}}
  The name of the directory containing the mods within a kit repo.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := PROJECT_STICKY_DIR
$(call Sticky,${_var},${STICKY_DIR})
define _help
${_var} = ${${_var}}
  The name of the directory containing the project specific sticky variables.
  This defaults to the variable STICKY_DIR.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := BUILD_DIR
$(call Sticky,${_var},build)
define _help
${_var} = ${${_var}}
  The name of the directory where build intermediate files are stored.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := STAGING_DIR
$(call Sticky,${_var},staging)
define _help
${_var} = ${${_var}}
  The the name of the directory where files are staged for selection for
  deployment.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := DEPLOYMENT_DIR
$(call Sticky,${_var},deploy)
define _help
${_var} = ${${_var}}
  The the name of the directory where deliverable files are stored.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := TOOLS_DIR
$(call Sticky,${_var},tools)
define _help
${_var} = ${${_var}}
  The the name of the directory where tools are installed.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := BIN_DIR
$(call Sticky,${_var},bin)
define _help
${_var} = ${${_var}}
  The the name of the directory where tool executables are installed.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := LIB_DIR
$(call Sticky,${_var},lib)
define _help
${_var} = ${${_var}}
  The the name of the directory where libraries used to build projects are
  installed.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := INC_DIR
$(call Sticky,${_var},inc)
define _help
${_var} = ${${_var}}
  The the name of the directory where include files are stored.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := DOWNLOADS_DIR
$(call Sticky,${_var},downloads)
define _help
${_var} = ${${_var}}
  The name of the directory where downloaded files are stored.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := TESTS_DIR
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

_var := GIT_USER
$(call Sticky,${_var},git)
define _help
${_var} = ${${_var}}
  The default server user account to use when installing or creating a repo.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := GIT_SERVER
$(call Sticky,${_var},painter)
define _help
${_var} = ${${_var}}
  The default server to use when installing or creating a repo.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := GIT_DIR
$(call Sticky,${_var},repos)
define _help
${_var} = ${${_var}}
  The default server to use when installing or creating a repo.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := DEFAULT_URL
$(call Sticky,${_var},${GIT_SERVER}:${GIT_DIR})
define _help
${_var} = ${${_var}}
  The default URL minus the repo name to use when installing or creating a repo.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := DEFAULT_PROJECT_URL
$(call Sticky,${_var},${DEFAULT_URL}/${PROJECTS_DIR})
define _help
${_var} = ${${_var}}
  The default URL minus the repo name to use when installing or creating a
  project repo.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := DEFAULT_KIT_URL
$(call Sticky,${_var},${DEFAULT_URL}/${KITS_DIR})
define _help
${_var} = ${${_var}}
  The default URL minus the repo name to use when installing or creating a
  kit repo.
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

$(call Add-Help-Section,structure,ModFW node and directory structure.)
_h := modfw_structure
define _help
${_h}
  In a ModFW run only one project can be built at a time. The PROJECT variable
  indicates which project is being built. This project is the active project.

  The active project is the top level or focus. The project then "uses" one or
  more mods. Mods can then "use" additional mods and even mods from other
  kits to build components they may be dependent upon. Dependency trees
  should always begin with the active project.

  The PROJECTS_DIR contains all of the installed projects. Each project is a
  separate repo. Projects cannot reference or be dependent upon files contained
  in other projects. However, projects can install and use kits which were
  developed in other projects.

  Projects are intended to be self contained meaning all build artifacts along
  with the tools needed to build them are contained within the project
  directory structure. This helps avoid version conflicts between projects
  which use the same but different versions of kits or tools. This also helps
  avoid situations where removing a project breaks the build of another
  project or results in orphaned build artifacts.

  ModFW is a repo containing the ModFW components needed to build projects or
  test ModFW. The directory containing the ModFW repo is the root node. All
  other nodes are children of the ModFW root node.

  == ModFW Node Structure ==

  This is the structure of the declared nodes. Typically, the resulting
  directory structure matches the node structure but it is possible to
  change the location of a particular node. See help-nodes for more
  information. A typical case for this is to use the variable PROJECTS_DIR
  to change the location where projects are installed and built.

  Legend:
  +-    A root node.
  >-    A child node name.
  --    A directory.
  |     One or more files within a directory.
  ...   Repeats the node sub-structure for each instance.
  <a>   Indicates a node or file name defined by a variable.
  $${X} Indicates a sticky variable which can be overridden on the command line.

  +-ModFW_node (repo) # All other nodes are children of this node.
    --.git
      Files managed by git.
    --.modfw
      Hidden directory where ModFW specific config and temporary files are
      stored.
    | .gitignore # Ignores STICKY_DIR, DOWNLOADS_DIR and, PROJECTS_DIR.
    | makefile (The top level makefile.)
    >-$${MK_DIR} = ${MK_DIR}
      ModFW makefile segments.
    >-$${TESTS_DIR} = ${TESTS_DIR}
      ModFW makefile segments for testing ModFW.

    The following are not part of the ModFW repo.

    --$${STICKY_DIR} = ${STICKY_DIR}
      Top level sticky variable save files. Ths location of this node is defined
      by $${STICKY_PATH} which is defined by the helpers (see help-helpers).
      This is redirected to the active project.
    >-$${DOWNLOADS_DIR} = ${DOWNLOADS_DIR} (ignored)
      Where downloaded tools and components are stored. Multiple projects can
      reference these to avoid redundant downloads.
    >-$${PROJECTS_DIR} = ${PROJECTS_DIR} (ignored)
      Contains all projects. The location of this node is defined by
      $${PROJECTS_PATH}.
      >-$${PROJECT}... (repo)
        | .gitignore (ignores TOOLS_DIR, KITS_DIR, BUILD_DIR, and STAGING_DIR)
        | <project>.mk
        | Project defined files.
        --.git
          | Files managed by git.
        --$${PROJECT_STICKY_DIR} = ${PROJECT_STICKY_DIR}
          Sticky variables are redirected to this directory when the project
          is used. Any sticky variables defined by the project or any mods used
          within a project become part of the project rep.
        >-$${INC_DIR} = ${INC_DIR}
          Where shared include files are stored. This is typically used to
          provide project specific definitions.
        >-$${TOOLS_DIR} = ${TOOLS_DIR} (ignored)
          Where tools are installed. These can be tools built by mods or
          downloaded and installed by mods. Mods which use tools provided by
          other mods must have declared the proper dependencies and the
          providing mods must have declared the corresponding goals.
          >-$${TOOLS_DIR}.$${BIN_DIR} = ${BIN_DIR}
            Where generic tools and utilities are installed. These are typically
            installed by mods.
          >-$${TOOLS_DIR}.$${INC_DIR} = ${INC_DIR}
            Where common tool related include files are installed. These are
            typically installed by mods.
          >-$${TOOLS_DIR}.$${LIB_DIR} = ${LIB_DIR}
            Where shared libraries are stored. These are typically built and
            installed by mods.
          >-<tool>...
            >-$${<tool>.VERSION}
              When it is not appropriate to install tool related files in a
              shared location, a mod can define its own set of nodes in which
              to install a tool. These are the recommended nodes for tool. The
              actual nodes are defined by the mod. The only requirement is a
              tool be installed in version specific nodes to help avoid
              conflicts between different versions of the same tool. For
              example:
              >-$${<tool>.VERSION}.$${BIN_DIR}
                Where tool executables are installed when a generic location
                won't work.
              >-$${<tool>.VERSION}.$${LIB_DIR}
                Where tool libraries are installed when a generic location
                won't work.
              >-$${<tool>.VERSION}.$${INC_DIR}
                Where tool or version specific shared include files are
                installed.
        >-$${KITS_DIR} = ${KITS_DIR} (ignored)
          A project contains a collection of kits needed to build the project.
          Each kit is a separate repo.
          >-<kit>... (repo) (see help-kits)
            --.git
              | Files managed by git.
            | .gitignore
            | <kit>.mk
            | Kit defined files.
            >-<kit>.$${MODS_DIR} = ${MODS_DIR}
              A kit contains a collection of mods. The mods are part of the
              containing kit repo.
              | <kit>.mk
              >-<kit>.<mod>... (see help-mods)
                | <mod>.mk
                | .gitignore
                | Mod defined files.
                >-<kit>.<mod>.$${INC_DIR} = ${INC_DIR}
                  | Mod defined include files.
        >-$${BUILD_DIR} = ${BUILD_DIR} (ignored)
          Where tools and mods are built.
          >-<kit>.$${BUILD_DIR}...
            Contains kit build files. Typically these are common to all of the
            contained mods.
            >-<kit>.<mod>.$${BUILD_DIR}...
              | Mod build files.
        >-$${STAGING_DIR} = ${STAGING_DIR} (ignored)
          >-<kit>.$${STAGING_DIR}...
            Contains staged kit files. Typically these are common to all of the
            contained mods.
            >-<kit>.<mod>.$${STAGING_DIR}...
              Where a mod stages its files for selection by the project. The
              project goals copy these files to the project deployment
              directory. The structure of the nodes within this node are
              defined by the mod.
        >-$${DEPLOYMENT_DIR} = ${DEPLOYMENT_DIR} (ignored)
          Where selected files from kits and mods are staged for deployment. The
          structure of the nodes within this node is defined by the project.
          files contained in this node become the top level goals for a
          project. Selected files in the staging nodes are the dependencies
          for deployable files.

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
