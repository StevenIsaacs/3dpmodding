#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Manage multiple ModFW projects using git, branches, and tags.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
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

repo_classes += PROJECT
containers += PROJECT

$(call Sticky,PROJECT)
$(call Sticky,PROJECTS_DIR,${DEFAULT_PROJECTS_DIR})
$(call Sticky,PROJECTS_PATH,${DEFAULT_PROJECTS_PATH})

$(call Sticky,PROJECT_SERVER,git@github.com:)
$(call Sticky,PROJECT_ACCOUNT,StevenIsaacs)
$(call Sticky,PROJECT_REPO,${PROJECT})

_req := $(call Require,\
  PROJECT\
  PROJECTS_DIR \
  PROJECTS_PATH \
  PROJECT_SERVER \
  PROJECT_ACCOUNT \
  PROJECT_REPO)

ifneq (${_req},)
  $(call Signal-Error,Missing sticky variables:${_req})
else
  project_url := ${PROJECT_SERVER}$(PROJECT_ACCOUNT)/${PROJECT_REPO}
  $(call Verbose,Project url is:${project_url})
  ifneq (${NEW_PROJECT},)
    $(call new-repo,PROJECT,$(NEW_PROJECT),$(BASIS_PROJECT))
  else
    $(call activate-repo,PROJECT)
    # If the project exists then route stick variables to the project and
    # load the kits.
    ifneq ($(call repo-is-setup,${PROJECT}),)
      $(call Attention,Pointing STICKY_PATH to the active project.)
      $(eval STICKY_PATH := ${${PROJECT}_repo_path}/sticky)
      $(call Use-Segment,kits)
    else
      $(call Signal-Error,The PROJECT repo ${PROJECT} is not setup.)
    endif
  endif
endif

# To remove all projects.
ifneq ($(call Is-Goal,remove-${Seg}),)

  $(call Info,Removing all projects in: ${PROJECTS_PATH})
  $(call Warn,This cannot be undone!)
  ifeq ($(call Confirm,Remove all ${Seg} -- cannot be undone?,y),y)

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
define help-${Seg}
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
exist then it must first be created using the NEW_PROJECT option. The project
is either created or cloned depending upon the value of PROJECT_REPO (below).

Sticky variables are stored in the project subdirectory thus allowing each project to have unique values for sticky variables. This segment (${Seg}) changes STICKY_PATH to point to the project specific sticky variables which are also maintained in the repo.

When a project repo is created, a project makefile segment is generated and stored in the project subdirectory. The developer modifies this file as needed. The project makefile segment is typically used to override kit and mod variables. Project specific variables, goals and recipes can also be added. This is also used to define the repos and branches for the various kits used in the project.

A new project can be based upon an existing project by specifying the
existing project using the BASIS_PROJECT command line variable. In this case
the existing project files are copied to the new project. The project
specific segment is renamed for the new project and all project references
in the new project are changed to reference the new project. For reference
the basis project makefile segment is copied to the new project but not used.

Required sticky variables:
  PROJECT = ${PROJECT}
    The name of the active project. This is used to create or switch to the
    project specific repo in the projects directory. This variable is stored
    in the default sticky directory.
    DEFAULT_STICKY_PATH = ${DEFAULT_STICKY_PATH}
  PROJECT_SERVER = ${PROJECTS_SERVER}
    The git server where project repos are hosted. If the protocol is https
    then this needs to end with a forward slash (/). If the protocol is ssh
    then this needs to end with a colon (:).
  PROJECT_ACCOUNT = ${PROJECTS_ACCOUNT}
    The user account on the git server.
  PROJECT_REPO=${PROJECT_REPO}
    Default: PROJECT_REPO = ${PROJECT}
    The repo to clone for the active project. NOTE: This can be different
    than the local repo name making it possible to have multiple copies of a
    project repo.
  PROJECT_BRANCH=${PROJECT_BRANCH}
    Default: DEFAULT_BRANCH = ${DEFAULT_BRANCH}
    Branch in the active project repo to install. This becomes part of the
    directory name for the project.

Sticky variables for other projects:
  <project>_REPO = (Defined when a project is activated)
    Default: LOCAL_REPO = ${LOCAL_REPO}
    The repo to clone for the selected project.
  <project>_BRANCH = (Defined when a project is activated)
    Default: DEFAULT_BRANCH = ${DEFAULT_BRANCH}
    The branch in the selected project to install. This is used as part of the
    directory name for the selected version of the project.

Optional sticky variables:
  PROJECTS_DIR = ${PROJECTS_DIR}
    The name of the directory where projects are stored. This is used as part
    of the definition of PROJECTS_PATH.
  PROJECTS_PATH = ${PROJECTS_PATH}
  Default: DEFAULT_PROJECTS_PATH = ${DEFAULT_PROJECTS_PATH}
    Where the project specific configurations are stored. This is the location
    of the collection of project git repos.

Defines:
  project_url = ${project_url}
  The URL produced by combining PROJECT_SERVER, PROJECT_ACCOUNT, and PROJECT.

Changes:
  STICKY_PATH = ${STICKY_PATH}
    Changed to point to the active project repo directory.

Command line variables:
  NEW_PROJECT = ${NEW_PROJECT}
    The name of a new project to create. If this is not empty then a new
    project is declared and the "create-new" goal will create the new
    project.
    This creates new sticky variables for the new project:
      <NEW_PROJECT>_REPO
      <NEW_PROJECT>_BRANCH
    These are not defined unless the variable NEW_PROJECT is defined on the
    command line.
  BASIS_PROJECT = ${BASIS_PROJECT}
    When defined and creating a new project using "create-new" the new
    project is initialized by copying files from the basis project to the new
    project. e.g. make NEW_PROJECT=<new> BASIS_PROJECT=<existing> create-new

Command line goals:
  show-${Seg}
    Display a list of projects in the projects directory.
  activate-project
    Activate the project (${PROJECT}). This is available only when the
    project hasn't been installed.
  remove-projects
    Remove all project repositories. WARNING: Use with care. This is potentially
    destructive. As a precaution the dev is prompted to confirm before
    proceeding.
  help-<project>
    Display the help message for a project.
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
