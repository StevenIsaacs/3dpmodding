#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Manage multiple ModFW projects using git, branches, and tags.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,Manage multiple ModFW projects using git, branches, and tags.)
# -----

#+
# For all projects.
#-
# The directory containing the projects repo.
# NOTE: This is ignored in .gitignore.
$(call Overridable,DEFAULT_PROJECTS_DIR,${SegUN})
# Where project specific kit and mod configuration repo is maintained.
$(call Overridable,DEFAULT_PROJECTS_PATH,${WorkingPath})

$(call Sticky,PROJECTS_DIR,${DEFAULT_PROJECTS_DIR})
$(call Sticky,PROJECTS_PATH,${DEFAULT_PROJECTS_PATH})

$(call Use-Segment,nodes)
$(call Use-Segment,repos)

$(call declare-node,${PROJECTS_DIR},,${PROJECTS_PATH})
$(call create-node,${PROJECTS_DIR})

_var := project_attributes
${_var} := ${repo_attributes}
define _help
${_var}
  A project is a ModFW repo and has the same attributes as the repo.

${help-repo_attributes}
endef
help-${_var} := $(call _help)

_var := PROJECT
define _help
${_var} = ${${_var}}
    The name of the active project. This is used to create or switch to the
    project specific repo in the projects directory. No two projects can have
    the same name.
endef
help-${_var} := $(call _help)

_var := PRJ_BUILD_PATH
define _help
${_var} = ${${_var}}
  The full path to where project build intermediate files are stored.
endef
help-${_var} := $(call _help)

_var := PRJ_STAGING_PATH
define _help
${_var} = ${${_var}} (sticky)
  The full path to where project deliverable files are stored.
endef
help-${_var} := $(call _help)


_macro := use-project
define _help
${_macro}
  Use this to install a project repo in the project. This clones an existing
  repo into the parent node directory.
  Parameters:
    1 = The name of the project to use.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(if ${$(1).SegID},
  $(call Verbose,Project $(1) is already in use.)
,
  $(call declare-repo,$(1),${PROJECTS_DIR})
  $(call use-repo,$(1))
  $(if $(call is-modfw-repo,$(1)),
    $(call Info,Using project:$(1))
    $(call Attention,Redirecting sticky variables to project:${PROJECT})
    $(call Redirect-Sticky,${${PROJECT}.path}/sticky)
    $(call Sticky,PRJ_BUILD_PATH,${BUILD_PATH}/$(1))
    $(call Sticky,PRJ_STAGING_PATH,${STAGING_PATH}/$(1))
    $(call Use-Segment,kits)
    $(call Use-Segment,mods)
    $(call Use-Segment,$(1))
  ,
    $(call Signal-Error,$(1) is not a ModFW repo.)
  )
)
$(call Exit-Macro)
endef

_macro := new-project
define _help
${_macro}
  Create and initialize a new project repo. A makefile segment is generated
  from  a template. The dev must then complete the makefile segment before
  attempting a build.
  NOTE: This is designed to be callable from the make command line using the
  helpers call-<macro> goal.
  For example:
    make ${_macro}.PARMS=<project>[:<basis>] call-${_macro}
  Parameters:
    1 = The name of the new project.
    2 = Optional project name to use as the basis of the new project.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(if $(call repo-is-setup,$(1)),
  $(call Signal-Error,Project $(1) already exists -- not creating.)
,
  $(call new-repo,$(1),${PROJECTS_DIR},$(2))
)
$(call Exit-Macro)
endef

_macro := remove-project
define _help
${_macro}
  Remove an project repo.
  NOTE: This is designed to be callable from the make command line using the
  helpers call-<macro> goal.
  For example:
    make ${_macro}.PARMS=<project> call-${_macro}
  Parameters:
    1 = The name of the project to be removed.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(if $(call repo-is-setup,$(1)),
  $(call Signal-Error,Project $(1) already exists -- not creating.)
,
  $(call remove-repo,$(1),${PROJECTS_DIR},$(2))
)
$(call Exit-Macro)
endef

# To remove all projects.
ifneq ($(call Is-Goal,remove-${SegUN}),)

  $(call Info,Removing all projects in: ${PROJECTS_PATH})
  $(call Warn,This cannot be undone!)
  ifeq ($(call Confirm,Remove all ${SegUN} -- cannot be undone?,y),y)

remove-${SegUN}:
> rm -rf ${PROJECTS_PATH}

  else
    $(call Info,Not removing ${SegUN}.)
  endif
else
  ifneq ($(call Is-Goal,call-new-project),)
    $(call Attention,Creating new project:${PROJECT})
  else
    ifneq ($(call Is-Goal,call-remove-project),)
      $(call Attention,Removing project:${PROJECT})
    else
      $(call Sticky,PROJECT)
      $(call declare-repo,${PROJECT},$(PROJECTS_DIR))
      $(call Attention,Redirecting sticky variables to project:${PROJECT})
      $(call Redirect-Sticky,${${PROJECT}.path}/sticky)
      $(call use-project,${PROJECT})
      # If the project exists then run the project init.
      ifneq ($(call repo-is-setup,${PROJECT}),)
        $(if $(findstring undefined,$(flavor ${PROJECT}.init)),
          $(call Warn,The init macro for ${PROJECT} is undefined.)
        ,
          $(call ${PROJECT}.init)
        )
      else
        $(call Signal-Error,The PROJECT repo ${PROJECT} is not setup.)
      endif
    endif
  endif
endif

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
Make segment: ${Seg}.mk

A ModFW project is mostly intended to contain variable definitions needed to
configure mod builds and to create project specific packages using the output
of mod builds. Each project is maintained in a separate git repo.

Although several projects can exist side by side only one can be active at one
time. The active project is indicated by the value of the PROJECT variable,Kits
are installed (cloned into) the project directory making it possible for
different projects tu use different versions of the same kits and mods. Kit
versions and dependencies are typically specified in the project makefile
segment. Kit repos are switched to the project specified branches when the
project is activated.

Once activated, branches are no longer automatically switched but can be
manually switched using the branching macros. If the active branch of a repo
is not the same as the original branch when the project was activated a
warning is issued.

It is possible for projects to be dependent upon the output of other projects.
However, it is recommended this be avoided because of introducing the risk of
confusion resulting from different kit versions.

This segment uses git to help manage ModFW projects. If the project repo doesn't
exist then it must first be created using the new-project macro which should be
called from the make command line using the call-new-project goal.

Sticky variables are stored in the project subdirectory thus allowing each
project to have unique values for sticky variables. This segment (${Seg})
changes STICKY_PATH to point to the project specific sticky variables which are
also maintained in the repo.

When a project repo is created, a project makefile segment is generated and
stored in the project subdirectory. The developer modifies this file as needed.
The project makefile segment is typically used to override kit and mod
variables. Project specific variables, goals and recipes can also be added.
This is also used to define the repos and branches for the various kits used in
the project.

A new project can be based upon an existing project by specifying the
existing project using the BASIS_PROJECT command line variable. In this case
the existing project files are copied to the new project. The project
specific segment is renamed for the new project and all project references
in the new project are changed to reference the new project. For reference
the basis project makefile segment is copied to the new project but not used.

The project build and staged artifacts are stored in subdirectories of the  build (BUILD_PATH) and staging (STAGING_PATH) directories. These subdirectories
have the same name as the project.

Projects cannot be dependent upon other projects.

Required sticky variables:
${help-PROJECT}

Optional sticky variables:
${help-PROJECTS_DIR}

${help-PROJECTS_PATH}

See help-repo_attributes for additional sticky variables.

Changes:
  STICKY_PATH = ${STICKY_PATH}
    Changed to point to the active project repo directory.

${help-new-project}

${help-use-project}

Command line goals:
  call-new-project
    Create a new project. See help-new-project for more info.
  show-${SegUN}
    Display a list of projects which are in use.
  remove-projects
    Remove all project repositories. WARNING: Use with care. This is potentially
    destructive. As a precaution the dev is prompted to confirm before
    proceeding.
  help-<project>
    Display the help message for a project.
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
