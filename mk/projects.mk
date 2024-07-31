#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Provide features to use one or more projects.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,Provide features to use one or more projects.)
# -----

$(call Use-Segment,mods)

define _help
Make segment: ${Seg}.mk

A ModFW project is mostly intended to contain variable definitions needed to
configure mod builds and to create project specific packages using the output
of mod builds. Each project is maintained in a separate git repo.

Although several projects can exist side by side only one can be active at one
time. The active project is indicated by the value of the PROJECT variable. Kits
are installed (cloned into) the project directory making it possible for
different projects to use different versions of the same kits and mods. Kit
versions and dependencies are typically specified in the project makefile
segment. Kit repos are switched to the project specified branches when the
project is activated.

Once a project is activated, branches are no longer automatically switched but
can be manually switched using the branching macros or the git command line.

It is possible for projects to be dependent upon the output of other projects.
However, it is recommended this be avoided because of introducing the risk of
confusion resulting from different kit versions (branches).

This segment uses repo macros in repos.mk help manage ModFW projects. Each
project is contained in a separate repo. the install-repo macro is used to install
the active project if it doesn't yet exist in the projects directory.

Sticky variables are stored in the project subdirectory thus allowing each
project to have unique values for sticky variables. This segment (${Seg})
changes STICKY_PATH to point to the project specific sticky variables which are
also maintained in the repo.

New projects can be created using the mk-modfw-repo or
mk-repo-from-template macros. When a project repo is created, a project
makefile segment is generated and stored in the project subdirectory. The
developer modifies this file as needed.

The project makefile segment is typically used to override kit and mod
variables and to use specific mods. Project specific variables, goals and
recipes can also be added. This is also used to define the repos and branches
for the various kits used in the project. See help-repos for more information.

A new project can be based upon an existing project using the
mk-repo-from-template macro. See help-repos for more information.

The project build and staged artifacts are stored in subdirectories of the
build (BUILD_PATH) and staging (STAGING_PATH) directories. These subdirectories
normally have the same name as the project but can be overridden.

Command line goals:
  help-<project>
    Display the help message for a project.
  help-${Seg}
    Display this help.
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Add-Help-Section,options,Command line options.)

$(call Add-Help-Section,project-vars,Variables for managing projects.)

_var := projects
${_var} :=
define _help
${_var}
  The list of declared projects.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := project_ignored_nodes
${_var} := KITS_NODE BUILD_NODE STAGING_NODE TOOLS_NODE BIN_NODE LIB_NODE
define _help
${_var}
  These nodes are not part of the git repository and are therefore ignored using
  .gitignore.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := project_node_names
${_var} := PROJECT_STICKY_NODE ${project_ignored_nodes}
define _help
${_var}
  A project is intended to be self contained meaning all components used to
  build a project are contained within the project directory making each of
  the ModFW defined directories child nodes of the project node. This serves to
  help avoid conflicts where different projects use different versions of
  the same component. A project is expected to define these attributes and
  has the option to make them sticky.

  See help-modfw_structure for more information.

Project node names:
$(foreach _node,${project_node_names},
$(call help-${_node})
)
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := project_attributes
${_var} := \
  goals sticky_path kits_path build_path staging_path tools_path bin_path \
  lib_path
define _help
${_var}
  A project is a ModFW repo and extends a repo with the additional attributes.

  Additional attributes:
  $${PROJECT}.goals
    The list of goals for the project.
  $${PROJECT}.kits_path
    Where kits are installed.
  $${PROJECT}.sticky_path
    Where project sticky variables are stored. NOTE: These are part of the
    project repo.
  $${PROJECT}.build_path
    Where project build artifacts are stored.
  $${PROJECT},staging_path
    Where project deliverables are staged. Additional files are cherry picked
    from kits and mods and placed here.
  $${PROJECT}.tools_path
    Where the project specific build tools are stored. Typically, tools are
    build in this directory and then installed in the project bin or lib
    directories.
  $${PROJECT}.bin_path
    Where the project specific tools and utilities are installed.
  $${PROJECT}.lib_path
    Where the project specific libraries are installed.

${help-repo_attributes}
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

$(call Add-Help-Section,project-ifs,Macros for checking project status.)

_macro := project-is-declared
define _help
${_macro}
  Returns a non-empty value if the project has been declared.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(if $(filter $(1),${projects}),1)

_macro := project-exists
define _help
${_macro}
  This returns a non-empty value if a node contains a ModFW repo.
  Parameters:
    1 = The name of a previously declared project.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(call is-modfw-repo,$(1))

_macro := is-modfw-project
define _help
${_macro}
  Returns a non-empty value if the project conforms to the ModFW pattern. A
  ModFW project will always have a makefile segment having the same name as the
  project and the repo.
  The project is contained in a node of the same name. The makefile segment file
  will contain the same name to indicate it is customized for the project.
  Parameters:
    1 = The name of an existing and previously declared project.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),project=$(1))
  $(if $(call is-modfw-repo,$(1)),
    $(call Run,grep $(1) ${$(1).seg_f})
    $(if ${Run_Rc},
      $(call Verbose,grep returned:${Run_Rc})
    ,
      $(if $(wildcard ${$(1).path}/.gitignore),
        $(call Verbose,$(1) is a valid ModFW project.)
        1
      ,
        $(call Verbose,${(1).path}/.gitignore does not exist.)
      )
    )
  ,
    $(call Verbose,$(1) is not a ModFW repo.)
  )
  $(call Exit-Macro)
)
endef

$(call Add-Help-Section,project-decl,Macros for declaring projects.)

_macro := declare-project
define _help
  Declare a project as a repo and a child of the $${PROJECTS_NODE} node.

  NOTE: Only one project can be declared at a time.

  Parameters:
    1 = The name of the project.
    2 = The parent node for the project.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),project=$(1) parent=$(2))

$(if $(call project-is-declared,$(1)),
  $(call Attention,Using existing declaration for project $(1).)
,
  $(if $(call repo-is-declared,$(1)),
    $(call Signal-Error,\
        A repo using project name $(1) has already been declared.)
  ,
    $(if $(call node-is-declared,$(1)),
      $(call Signal-Error,\
        A node using project name $(1) has already been declared.)
    ,
      $(if $(call node-is-declared,$(2)),
        $(call Verbose,Checking variables for project:$(1))
        $(eval _ud := $(call Require,\
          PROJECTS_NODE ${project_node_names} $(1).URL $(1).BRANCH))
        $(eval _ud += $(call Require,${project_node_names}))
        $(if ${_ud},
          $(call Signal-Error,Undefined variables:${_ud})
        ,
          $(call Verbose,Declaring project $(1).)
          $(call declare-child-node,$(1),$(2))
          $(call declare-repo,$(1))
          $(foreach _node,${project_node_names},
            $(call declare-child-node,$(1).${${_node}},$(1),${${_node}})
          )
          $(eval $(1).goals :=)
          $(eval $(1).sticky_path := ${$(1).${PROJECT_STICKY_NODE}.path})
          $(eval $(1).build_path := ${$(1).${BUILD_NODE}.path})
          $(eval $(1).staging_path := ${$(1).${STAGING_NODE}.path})
          $(eval $(1).tools_path := ${$(1).${TOOLS_NODE}.path})
          $(eval $(1).bin_path := ${$(1).${BIN_NODE}.path})
          $(eval $(1).lib_path := ${$(1).${LIB_NODE}.path})
          $(eval $(1).kits_path := ${$(1).${KITS_NODE}.path})
          $(eval projects := $(1))
        )
      ,
        $(call Signal-Error,\
          Parent node $(2) for project $(1) is not declared.)
      )
    )
  )
)

$(call Exit-Macro)
endef

_macro := undeclare-project
define _help
  Remove a project declaration. The corresponding repo and node are also
  undeclared. The non-sticky project attributes are undefined.
  Parameters:
    1 = The name of the project.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),project=$(1))

$(if $(call project-is-declared,$(1)),
  $(if $(call repo-is-declared,$(1)),
    $(if $(call node-is-declared,$(1)),
      $(if $(call is-a-child-node,$(1)),
        $(call undeclare-repo,$(1))
        $(foreach _node,${$(1).children},
          $(call undeclare-child-node,${_node})
        )
        $(call undeclare-child-node,$(1))
        $(foreach _att,${project_attributes},
          $(eval undefine $(1).${_att})
        )
        $(eval projects := $(filter-out $(1),${projects}))
      ,
        $(call Signal-Error,Project $(1) is not a child node.)
      )
    ,
      $(call Signal-Error,Project $(1) does not have a declared node.)
    )
  ,
    $(call Signal-Error,Project $(1) does not have a declared repo.)
  )
,
  $(call Signal-Error,The project $(1) has not been declared.)
)
$(call Exit-Macro)
endef

$(call Add-Help-Section,project-reports,Macros for reporting projects.)

_macro := display-project
define _help
${_macro}
  Display project attributes.
  Parameters:
    1 = An optional name of the project. This defaults to ${PROJECT}.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),project=$(1))
  $(if $(1),
    $(eval _p_ := $(1))
  ,
    $(eval _p_ := ${PROJECT})
  )
  $(call declare-project,${_p_},${PROJECTS_NODE})
  $(if $(call project-is-declared,${_p_}),
    $(call Attention,Displaying project ${_p_})
    $(call Display-Vars,\
      $(foreach _a,${project_attributes},${_p_}.${_a}) \
      $(foreach _a,${project_node_names},${_p_}.${_a})
    )
    $(call display-repo,${_p_})
  ,
    $(call Warn,Project ${_p_} has not been declared.)
  )
  $(call Exit-Macro)
endef

$(call Add-Help-Section,project-install,Macros for creating projects.)

_macro := gen-project-gitignore
define _help
${_macro}
  Generate the .gitignore file text for a project. The ignored items are
  relative to the project directory.
  Parameters:
    1 = The project name.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(foreach _n,${project_ignored_nodes},
$(1).${_n}
)
endef

_macro := mk-project
define _help
${_macro}
  Create and initialize a new project repo. The project node is declared to be
  a child of the PROJECTS_NODE node. The node is then created and initialized
  to be a repo.

  NOTE: This is designed to be callable from the make command line using the
  helper call-${_macro} goal.
  For example:
    make ${_macro}.PARMS=<prj> [<prj>.URL=<url>] [<prj>.BRANCH=<branch>] call-${_macro}

  Parameters:
    1 = The node name of the new project (<prj>).
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),project=$(1))
  $(call Clear-Errors)
  $(if ${$(1).URL},
  ,
    $(eval $(1).URL := ${DEFAULT_PROJECT_URL}/$(1))
  )
  $(call Attention,Using url:${$(1).URL})
  $(if ${$(1).BRANCH},
  ,
    $(eval $(1).BRANCH := ${DEFAULT_BRANCH})
  )
  $(call Attention,Using branch:${$(1).BRANCH})
  $(if $(call project-is-declared,$(1)),
    $(call Attention,Using existing declaration for project $(1).)
  ,
    $(call declare-project,$(1),${PROJECTS_NODE})
  )
  $(if ${Errors},
    $(call Attention,Unable to make a project.)
  ,
    $(if $(call node-exists,$(1)),
      $(call Signal-Error,Project $(1) node already exists.)
    ,
      $(call mk-node,$(1))
      $(call mk-modfw-repo,$(1))
      $(if ${Errors},
        $(call Warn,An error occurred -- not generating .gitignore file.)
      ,
        $(file >${$(1).path}/.gitignore,$(call gen-project-gitignore,$(1)))
        $(call add-file-to-repo,$(1),.gitignore)
      )
    )
  )
  $(call Exit-Macro)
endef

_macro := mk-project-from-template
define _help
${_macro}
  Declare and create a new project in the PROJECTS_NODE node using another
  project in the PROJECTS_NODE node as a template.

  NOTE: This is designed to be callable from the make command line using the
  helper call-<macro> goal.
  For example:
    make ${_macro}.PARMS=<prj>:<tmpl> call-${_macro}

  Parameters:
    1 = The name of the new project.
    2 = The name of the template project.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),project=$(1) template=$(2))

  $(if $(call project-is-declared,$(1)),
    $(call Attention,Using existing declaration for project $(1).)
  ,
    $(call declare-project,$(1),${PROJECTS_NODE})
  )
  $(if ${Errors},
    $(call Attention,Unable to make a project.)
  ,
    $(if $(call node-exists,$(1)),
      $(call Signal-Error,Project $(1) node already exists.)
      $(call undeclare-project,$(1))
    ,
      $(call declare-child-node,$(2),${PROJECTS_NODE})
      $(call declare-repo,$(2))
      $(if $(call is-modfw-repo,$(2)),
        $(call mk-repo-from-template,$(1),$(2))
      ,
        $(call Signal-Error,Template project $(2) does not exist.)
        $(call undeclare-project,$(1))
      )
      $(call undeclare-repo,$(2))
      $(call undeclare-child-node,$(2))
    )
  )
  $(call Exit-Macro)
endef

_macro := rm-project
define _help
${_macro}
  Remove an existing project. The project node is declared to be a child of
  the PROJECTS_NODE node. The node is then removed.

  NOTE: This is designed to be callable from the make command line using the
  helper call-${_macro} goal.
  For example:
    make ${_macro}.PARMS=<prj> call-${_macro}

  Parameters:
    1 = The node name of the project to remove(<prj>).
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),project=$(1))
  $(call Clear-Errors)
  $(if project-is-declared,$(1),
    $(call Attention,Using existing declaration for project $(1).)
  ,
    $(call declare-project,$(1),${PROJECTS_NODE})
  )
  $(if ${Errors},
    $(call Attention,Unable to remove project $(1).)
  ,
    $(if $(call node-exists,$(1)),
      $(call rm-node,$(1),Remove project $(1)?)
      $(if ${Errors},
        $(call Warn,An error occurred when removing project $(1).)
      )
    ,
      $(call Signal-Error,Project $(1) node does not exist.)
    )
    $(call undeclare-project,$(1))
  )
  $(call Exit-Macro)
endef

$(call Add-Help-Section,project-use,The primary macro for using projects.)

_macro := install-project
define _help
${_macro}
  Use this to install a project repo. This declares and clones an existing repo
  into the $${PROJECTS_NODE} node directory.

  If the project has already been declared then the existing project
  declaration is used.

  Parameters:
    1 = The name of the project to install.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),project=$(1))

$(call declare-project,$(1),${PROJECTS_NODE})
$(if ${Errors},
  $(call Attention,Unable to install a project.)
,
  $(if $(call node-exists,${$(1).parent}),
    $(call install-repo,$(1))
    $(if ${Errors},
    ,
      $(if $(call is-modfw-repo,$(1)),
        $(call Verbose,Project $(1) is a ModFW repo.)
      ,
        $(call Signal-Error,Project $(1) is not a ModFW repo.)
        $(if ${VERBOSE},$(call display-project,$(1)))
      )
    )
  ,
    $(call Signal-Error,\
      Parent node ${$(1).parent} for project $(1) does not exist.)
  )
)
$(call Exit-Macro)
endef

_macro := use-project
define _help
${_macro}
  Declares a project which in turn declares a project node as a child of the
  PROJECTS_NODE node. If the project repo doesn't exist locally then it is
  installed into the PROJECTS_NODE node.

  NOTE: The PROJECTS_NODE node must have been previously declared and must exist.

  Parameters:
    1 = The name of the project to use.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),project=$(1))
  $(if ${${$(1).seg_un}.SegID},
    $(call Verbose,Project $(1) is already in use.)
  ,
    $(call Info,Using project:$(1))
    $(call install-project,$(1))
    $(if ${Errors},
      $(call Signal-Error,An error occurred when installing the project $(1).)
    ,
      $(foreach _node,${project_node_names},
        $(if $(call node-exists,$(1).${${_node}}),
          $(call Info,Using existing node $(1).${${_node}})
        ,
          $(call mk-node,$(1).${${_node}})
        )
      )
      $(call Use-Segment,${$(1).seg_f})
    )
  )
  $(call Exit-Macro)
endef

# +++++
# Postamble
# Define help only if needed.
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
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
