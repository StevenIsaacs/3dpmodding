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

project_dir := ${PROJECT}
project_path := ${projects_repo_path}/${project_dir}
project_name := $(call To-Name,${project_dir})
project_segment := ${PROJECT}
project_mk := ${project_path}/${project_segment}.mk

projects = $(filter-out .git,$(call Directories-In,${projects_repo_path}))

#+
# Because this segment, similar to helpers.mk, initializes and changes variables
# that configure kits and mods the project repo cannot be managed using normal
# make goals. Instead, immediate shell commands are used.
#-

define _${project_name}_seg
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Project specific configs for project: ${PROJECT}
#----------------------------------------------------------------------------
# The prefix ${project_name} must be unique for all files.
# The format of all the ${project_name} based names is required.
# +++++
# Preamble
$.ifndef ${project_name}SegId
$$(call Enter-Segment,${project_name})
# -----

# Add configs here.

# +++++
# Postamble
# Define help only if needed.
$.ifneq ($$(call Is-Goal,help-$${${project_name}Seg}),)
$.define help_$${${project_name}SegN}_msg
Make segment: $${${project_name}Seg}.mk

Project specific configs for the project: ${PROJECT}

# Add help messages here.

Defines:
  # Describe each config.

Command line goals:
  # Describe additional goals provided by the config.
  help-$${${project_name}Seg}
    Display this help.
$.endef
$.endif # help goal message.

$$(call Exit-Segment,${project_name})
$.else # ${project_name}SegId exists
$$(call Check-Segment-Conflicts,${project_name})
$.endif # ${project_name}SegId
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

# Redirect the sticky variables to the project config directory.
STICKY_PATH := ${project_path}

ifneq ($(wildcard ${project_path}),)

  # Project exists
  $(call Verbose,Using ${PROJECT})

  $(call Add-Segment-Path,$(project_path))
  $(call Use-Segment,${project_segment})
  # This installs kits and uses a mod within a kit. A kit and mod extends the
  # seg_paths variable as needed.
  $(call Use-Segment,kits)

create-project:

else # Project config does not exist.

  ifeq ($(call Is-Goal,create-project),)
  # Project does not exist and is not being created.
    $(call Signal-Error,The project ${PROJECT} does not exist. See help-${SegN}.)
  else # Create a new project
    ifneq ($(call Confirm,Create new project ${PROJECT}?,y),)
      # Yes, create a new project.
      ifndef SEED_PROJECT
      # Not using a SEED_PROJECT
        $(call Add-Message,Creating project: ${PROJECT})
        export _${project_name}_seg

${project_mk}: ${PROJECTS_PATH}/.git
> mkdir -p $(@D) && printf "%s" "$$_${project_name}_seg" > $@

# New projects must be initialized using this goal to avoid typos creating
# useless projects.
create-project: ${project_mk}
> @echo Project ${PROJECT} has been created.

      else # Use existing seed project.
        $(call Add-Message,Creating project: ${PROJECT} using ${SEED_PROJECT})
        seed_config_path := ${projects_repo_path}/${SEED_PROJECT}
        seed_segment := ${SEED_PROJECT}-cfg
        seed_config_mk := ${seed_config_path}/${seed_segment}.mk
        seed_name := $(call To-Name,${SEED_PROJECT})

# The seed project config file is retained in the new project for reference.
create-project: ${seed_config_mk}
> rsync -avzh --exclude $(notdir ${seed_config_mk}) \
    ${seed_config_path}/* ${project_path}
> echo "# Derived from seed project - ${SEED_PROJECT}" > ${project_mk}
> sed 's/${seed_name}/${project_name}/g' \
    ${seed_config_mk} >> ${project_mk}

      endif # Use seed project.
    else # NO, don't create a new project.
      $(call Signal-Error,${PROJECT} does not exist.)

create-project:

    endif # Confirm create the project.
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

A new project can be based upon an existing project by specifying the
existing project using the SEED_PROJECT command line option. In this case
the existing project files are copied to the new project. The project
specific segment is renamed for the new project and all project references
in the new project are changed to reference the new project. For reference
the seed project config file is copied to the new project.

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

Command line options:
  SEED_PROJECT = ${SEED_PROJECT}
    When defined and creating a new project using create-project the new
    project is initialized by copying files from the seed project to the new
    project. e.g. make SEED_PROJECT=<existing> create-project

Macros:
  strip-dir-prefix
  Scan the indicated directory and return the directories having the prefix
  with the prefix removed.
  Parameters:
    1 = The prefix to scan for and to remove.
    2 = The path to scan.

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
