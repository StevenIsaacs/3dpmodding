#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Manage multiple ModFW projects using git, branches and, tags.
#----------------------------------------------------------------------------
# The prefix prj must be unique for all files.
# The format of all the prj based names is required.
# +++++
# Preamble
ifndef prjSegId
$(call Enter-Segment,prj)
# -----

$(call Sticky,PROJECTS_REPO,${DEFAULT_PROJECTS_REPO})
$(call Sticky,PROJECTS_DIR,${DEFAULT_PROJECTS_DIR})
$(call Sticky,PROJECTS_PATH,${DEFAULT_PROJECTS_PATH})
$(call Sticky,PROJECTS_BRANCH,${DEFAULT_PROJECTS_BRANCH})

projects_repo_path := ${PROJECTS_PATH}
project_config_path := ${projects_repo_path}/${PROJECT}
project_segment := ${PROJECT}-cfg
project_config_mk := ${project_config_path}/${project_segment}.mk
project_name := $(call To-Name,${PROJECT})

projects = $(filter-out .git,$(call Directories-In,${projects_repo_path}))

#+
# Because this segment, similar to helpers.mk, initializes and changes variables
# that configure kits and mods the project repo cannot be managed using normal
# make goals. Instead, immediate shell commands are used.
#-

define ${project_name}_config_seg
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Project specific configs for project: ${PROJECT}
#----------------------------------------------------------------------------
# The prefix ${project_name}_c_ must be unique for all files.
# The format of all the ${project_name}_c_ based names is required.
# +++++
# Preamble
$.ifndef ${project_name}_c_SegId
$$(call Enter-Segment,${project_name}_c_)
# -----

# Add configs here.

# +++++
# Postamble
# Define help only if needed.
$.ifneq ($$(call Is-Goal,help-${${project_name}_c_Seg}),)
$.define help_$${${project_name}_c_SegN}_msg
Make segment: $${${project_name}_c_Seg}.mk

Project specific configs for the project: ${PROJECT}

# Add help messages here.

Defines:
  # Describe each config.

Command line goals:
  # Describe additional goals provided by the config.
  help-$${${project_name}_c_Seg}
    Display this help.
$.endef
$.endif # help goal message.

$$(call Exit-Segment,${project_name}_c_)
$.else # ${project_name}_c_SegId exists
$$(call Check-Segment-Conflicts,${project_name}_c_)
$.endif # ${project_name}_c_SegId
# -----
endef

${PROJECTS_PATH}/.git:
ifeq (${PROJECTS_REPO},local)
> git init -b ${PROJECTS_BRANCH} ${PROJECTS_PATH}
else
> git clone ${PROJECTS_REPO} ${PROJECTS_PATH}
> cd ${PROJECTS_PATH} && \
    git checkout ${PROJECTS_BRANCH} && \
    git config pull.rebase true
endif

ifneq ($(wildcard ${project_config_mk}),)
$(call Verbose,Using ${PROJECT})
# Redirect the sticky variables to the project config directory.
STICKY_PATH := ${project_config_path}

$(call Add-Segment-Path,$(project_config_path))
$(call Use-Segment,${project_segment})

create-project:

else # Project config does not exist.
  ifeq ($(call Is-Goal,create-project),)
$(call Signal-Error,The project ${PROJECT} does not exist. See help-${SegN}.)
  else # Not create-project
    ifneq ($(call Confirm,Create new project ${PROJECT}?,y),)
$(call Add-Message,Creating project: ${PROJECT})
export ${project_name}_config_seg
${project_config_mk}: ${PROJECTS_PATH}/.git
> mkdir $(@D) && printf "%s" "$$${project_name}_config_seg" > $@

# New projects must be initialized using this goal to avoid typos creating
# useless projects.
create-project: ${project_config_mk}
> @echo Project ${PROJECT} has been created.

    else
$(call Signal-Error,${PROJECT} does not exist.)
create-project:

    endif # Yes create the project.
  endif # Create project.
endif # Project config does not exist.

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${prjSeg}),)
define help_${prjSegN}_msg
Make segment: ${prjSeg}.mk

This segment uses git manage project specific configurations. If the git
repo doesn't exist then it must first be created using the create-project
goal. The project is either created or cloned depending upon the value of
PROJECTS_REPO (below). These configurations define the options for
kits and mods within the kits.

Each project has a subdirectory in the repository. The variable PROJECT
specifies which project is active. If a project directory does not exist it
must be created using the create-project goal (below).

A project makefile segment is generated and stored in the project
subdirectory when the project is created. The developer modifies this
file as needed. This is typically used to override kit and mod variables
but project specific variables, goals and recipes can be added. The developer
is also expected to add them to the repo and commit changes as needed.

Sticky variables are stored in the project subdirectory thus allowing each
project to have unique values for sticky variables. This segment change
STICKY_PATH to point to the project specific sticky variables which are also
maintained in the repo.

Required sticky command line variables:
  PROJECT = ${PROJECT}
    The name of the project. This is used to create or switch to the
    project specific directory in the project configurations repo. This
    variable is stored in the default sticky directory.
    DEFAULT_STICKY_PATH = ${DEFAULT_STICKY_PATH}

Optional sticky variables:
  PROJECTS_PATH = ${PROJECTS_PATH}
  Default: DEFAULT_PROJECTS_PATH = ${DEFAULT_PROJECTS_PATH}
  Where the project specific configurations are stored. This is the location
  of a git repo.
  PROJECTS_REPO = ${PROJECTS_REPO}
  Default: DEFAULT_PROJECTS_REPO = ${DEFAULT_PROJECTS_REPO}
    If this is equal to local then a git repo is created to manage the
    configurations. Otherwise a git repo is cloned to install existing project
    specific kit and mod configurations.
  PROJECTS_BRANCH = ${PROJECTS_BRANCH}
  default: DEFAULT_PROJECTS_BRANCH = ${DEFAULT_PROJECTS_BRANCH}
    This is the branch used by the projects. The repo is
    switched to this branch before creating the new branch.

Changes:
  STICKY_PATH = ${STICKY_PATH}
  Changed to point to the project directory in the projects repo.

Command line goals:
  help-${prjSeg}
    Display this help.
  show-projects
    Display a list of projects in the project repo.
  create-project
    Create a new project in the projects repo. If the repo does not exist
    it is either cloned from a remote repo or a new local repo is created
    depending upon the PROJECTS_REPO variable.

endef
endif # help goal message.

$(call Exit-Segment,prj)
else # prjSegId exists
$(call Check-Segment-Conflicts,prj)
endif # prjSegId
# -----
