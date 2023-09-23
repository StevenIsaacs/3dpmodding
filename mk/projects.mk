#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Manage multiple ModFW projects using git, branches and, tags.
#----------------------------------------------------------------------------
# The prefix $(call This-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call This-Segment-Basename)SegId
$(call Enter-Segment)
# -----

#+
# For all projects.
#-
# The directory containing the projects repo.
# NOTE: This is ignored in .gitignore.
$(call Overridable,DEFAULT_PROJECTS_DIR,${Seg})
# Where project specific kit and mod configuration repo is maintained.
$(call Overridable,DEFAULT_PROJECTS_PATH,${WorkingPath}/${DEFAULT_PROJECTS_DIR})

$(call Sticky,PROJECTS_DIR,${DEFAULT_PROJECTS_DIR})
$(call Sticky,PROJECTS_PATH,${DEFAULT_PROJECTS_PATH})

#+
# For the active project.
#-
# These variables are in the default sticky directory.
$(call Sticky,PROJECT)

$(call Require,PROJECT)

$(call Sticky,PROJECT_REPO,${DEFAULT_REPO})
$(call Sticky,PROJECT_BRANCH,${DEFAULT_BRANCH})

$(call activate-repo,PROJECT,${Seg},kits)

# To build the active project.
activate-project: ${${PROJECT}_repo_mk}

# To remove all projects.
ifneq ($(call Is-Goal,remove-${Seg}),)

  $(call Info,Removing all projects in: ${PROJECTS_PATH})
  $(call Warn,This cannot be undone!)
  ifeq ($(call Confirm,Remove all ${Seg} -- can not be undone?,y),y)

remove-${Seg}:
> rm -rf ${PROJECTS_PATH}

  else
    $(call Info,Not removing ${Seg}.)
 endif

endif

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

A ModFW project is mostly intended to contain variable definitions needed to
configure mod builds and to create project specific packages using the output
of mod builds. Each project is maintained in a separate git repo.

Although several projects can exist side by side only one can be active at one
time. The active project is indicated by the value of the PROJECT variable, The
"activate" goal is provided for switching between projects. Different projects
can use different versions of the same kits and mods. Kit versions and
dependencies are typically specified in the project makefile segment. Kit repos
are switched to the project specified branches when the project is activated.
Once activated, branches are no longer automatically switched but can be
manually switched using the branching macros. If the active branch of a repo
is not the same as the original branch when the project was activated a
warning is issued.

It is possible for projects to be dependent upon the output of other projects. However, it is recommended this be avoided because of introducing the risk of
disk thrashing as a result of switching branches of projects and kits.

This segment uses git to help manage ModFW projects. If the project repo doesn't
exist then it must first be created using the "create-new" goal. The project
is either created or cloned depending upon the value of PROJECT_REPO (below).
These configurations define the options for kits and mods within the kits.

Sticky variables are stored in the project subdirectory thus allowing each project to have unique values for sticky variables. This segment (${Seg}) changes STICKY_PATH to point to the project specific sticky variables which are also maintained in the repo.

When a project repo is created, a project makefile segment is generated and stored in the project subdirectory. The developer modifies this file as needed. The project makefile segment is typically used to override kit and mod variables. Project specific variables, goals and recipes can also be added. This is also used to define the repos and branches for the various kits used in the project.

A new project can be based upon an existing project by specifying the
existing project using the BASIS_PROJECT command line variable. In this case
the existing project files are copied to the new project. The project
specific segment is renamed for the new project and all project references
in the new project are changed to reference the new project. For reference
the basis project makefile segment is copied to the new project but not used.

Required sticky command line variables:
  PROJECT = ${PROJECT}
    The name of the active project. This is used to create or switch to the
    project specific repo in the projects directory. This variable is stored
    in the default sticky directory.
    DEFAULT_STICKY_PATH = ${DEFAULT_STICKY_PATH}

Optional sticky variables:
  PROJECTS_PATH = ${PROJECTS_PATH}
  Default: DEFAULT_PROJECTS_PATH = ${DEFAULT_PROJECTS_PATH}
    Where the project specific configurations are stored. This is the location
    of the collection of project git repos.

Changes:
  STICKY_PATH = ${STICKY_PATH}
    Changed to point to the project directory in the projects repo.

Command line variables:
  NEW_PROJECT = ${NEW_PROJECT}
    The name of a new project to create. If this is not empty then a new
    project is declared and the "create-new" goal will create the new
    project.
    This creates new sticky variables for the new project:
      $${NEW_PROJECT}_REPO
      $${NEW_PROJECT}_BRANCH
    These are not defined unless the variable NEW_PROJECT is defined on the
    command line.
  BASIS_PROJECT = ${BASIS_PROJECT}
    When defined and creating a new project using "create-new" the new
    project is initialized by copying files from the basis project to the new
    project. e.g. make NEW_PROJECT=<new> BASIS_PROJECT=<existing> create-new

Macros:
  use-project
    Declare project specific variables, macros and, goals (a namespace). This
    allows having one project depend upon the output of another. If the project
    segment exists then it is loaded.
    Command line goals:
      <project>-create-new
        This goal is fully defined only when the "create-new" goal (below)
        is used. To reduce the possibility of accidental creation of new
        projects this goal does nothing if the "create-new" goal is not in
        the list of command line goals.
    Parameters:
      1 = The project file name. This is used to name:
            - The project make segment file.
            - The project directory.
            - Project specific goals.
      2 = The optional basis project to use if creating a new project. The
          contents of the basis project directory are copied to the new
          project. The basis project makefile segment is used to generate the
          new project makefile segment.

Command line goals:
  show-projects
    Display a list of projects in the projects directory.
  activate-project
    Build the active project (${PROJECT}).
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
