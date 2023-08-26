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

$(call Sticky,PROJECTS_DIR,${DEFAULT_PROJECTS_DIR})
$(call Sticky,PROJECTS_PATH,${DEFAULT_PROJECTS_PATH})
$(call Sticky,PROJECTS_REPO,${DEFAULT_PROJECTS_REPO})
$(call Sticky,PROJECTS_BRANCH,${DEFAULT_PROJECTS_BRANCH})

projects = $(filter-out .git,$(call Directories-In,${PROJECTS_PATH}))

project_deps :=

# Redirect the sticky variables to the project config directory.
STICKY_PATH := ${PROJECTS_PATH}/${PROJECT}

${PROJECTS_PATH}/.git:
ifeq (${PROJECTS_REPO},local)
> git init -b ${PROJECTS_BRANCH} ${PROJECTS_PATH}
else
> git clone ${PROJECTS_REPO} ${PROJECTS_PATH}
> cd ${PROJECTS_PATH} && \
    git checkout ${PROJECTS_BRANCH} && \
    git config pull.rebase true
endif

define use-project
$.ifdef p_$(2)
$$(call Signal-Error,Project $(2) is already in use.)
$.else
$$(call Verbose,Using project: $(1))

# Project specific variables.
p_$(2) := $(1)
p_$(2)_dir := $(1)
p_$(2)_path := ${PROJECTS_PATH}/$${p_$(2)_dir}
p_$(2)_name := $(2)
p_$(2)_segment := $(1)
p_$(2)_mk := $${p_$(2)_path}/$(1).mk

project_deps += $${p_$(2)_mk}

$.ifneq ($$(wildcard $${p_$(2)_path}),)

  # Project exists
  $$(call Verbose,Using project: $(1))

  $$(call Add-Segment-Path,$${p_$(2)_path})
  $$(call Use-Segment,$(1))
  # This installs kits and uses a mod within a kit. A kit and mod extends the
  # seg_paths variable as needed.
  $$(call Use-Segment,kits)

$(1)-create-project:

$.else # Project config does not exist.

  $.ifeq ($$(call Is-Goal,create-project),)
    # Project does not exist and is not being created.
    $$(call Signal-Error,The project $(1) does not exist. See help-${SegN}.)
  $.else # Create a new project
    $.ifneq ($$(call Confirm,Create new project $(1)?,y),)
      # Yes, create a new project.
      $.ifeq ($(3),)
        # Not using a SEED_PROJECT
        $$(call Add-Message,Creating project: $(1))
        p_$${p_$(2)_name}_seg := \
          $$(call Gen-Segment,\
          Project specific definitions for project: $(1),$(2))
        $.export p_$${p_$(2)_name}_seg

$${p_$(2)_mk}: ${PROJECTS_PATH}/.git
> mkdir -p $$(@D) && printf "%s" "$${Dlr}p_$${p_$(2)_name}_seg" > $$@

# New projects must be initialized using this goal to avoid typos creating
# useless projects.
$(1)-create-project: $${p_$(2)_mk}
> @echo Project $(1) has been created.

      $.else # Use existing seed project.
        $$(call Add-Message,Creating project: $(1) using $(3))
        p_seed_$(2) := $(3)
        p_seed_$(2)_path := ${PROJECTS_PATH}/$(3)
        p_seed_$(2)_segment := $(3)
        p_seed_$(2)_mk := \
          $${p_seed_$(2)_path}/$${p_seed_$(2)_segment}.mk
        p_seed_$(2)_name := $(call To-Shell-Var,$(3))

# The seed project config file is retained in the new project for reference.
$(1)-create-project: $${p_seed_$(2)_mk}
> cp -r $${p_seed_$(2)_path}/ $${p_$(2)_path}
>  echo "# Derived from seed project - $(3)" > $${p_$(2)_mk}
>  sed \
    -e 's/$${p_seed_$(2)_name}/$${p_$(2)_name}/g' \
    -e 's/$${p_seed_$(2)}/$${p_$(2)}/g' \
    $${p_seed_$(2)_mk} >> $${p_$(2)_mk}

      $.endif # Use seed project.
    $.else # NO, don't create a new project.
      $$(call Signal-Error,$(1) does not exist.)

$(1)-create-project:

    $.endif # Confirm create the project.
  $.endif # Create project.
$.endif # Project config does not exist.

$.endif # Project already declared.

endef # use-project

ifneq ($(call Is-Goal,create-project),)
create-project: ${PROJECT}-create-project
endif

$(eval $(call \
  use-project,${PROJECT},$(call To-Shell-Var,${PROJECT}),${SEED_PROJECT}))

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${prjSeg}),)
define help_${prjSegN}_msg
Make segment: ${prjSeg}.mk

A ModFW project is mostly intended to contain variable definitions needed to
configure mod builds and to create project specific packages using the
output of mod builds. It is possible for one project to be dependent upon the
output of another project.

Different projects can use different versions of the same kits and mods. The
versions and dependencies are specified in the project makefile segment.

This segment uses git to help manage ModFW projects. If the git repo doesn't
exist then it must first be created using the create-project goal. The project
is either created or cloned depending upon the value of PROJECTS_REPO (below).
These configurations define the options for kits and mods within the kits.

Each project has a subdirectory in the repository. The variable PROJECT
specifies which project is active. If a project directory does not exist it
must be created using the create-project goal (below).

A project makefile segment is generated and stored in the project
subdirectory when the project is created. The developer modifies this
file as needed. This is typically used to override kit and mod variables
but project specific variables, goals and recipes can be added. The developer
is also expected to add them to the repo and commit changes as needed.

Sticky variables are stored in the project subdirectory thus allowing each
project to have unique values for sticky variables. This segment changes
STICKY_PATH to point to the project specific sticky variables which are also
maintained in the repo.

A new project can be based upon an existing project by specifying the
existing project using the SEED_PROJECT command line option. In this case
the existing project files are copied to the new project. The project
specific segment is renamed for the new project and all project references
in the new project are changed to reference the new project. For reference
the seed project makefile segment is copied to the new project but not used.

Required sticky command line variables:
  PROJECT = ${PROJECT}
    The name of the active project. This is used to create or switch to the
    project specific directory in the projects repo. This variable is stored
    in the default sticky directory.
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
  use-project
    Declare project specific variables, macros and, goals (a namespace). This
    allows having one project depend upon the output of another. If the project
    segment exists then it is loaded.
    Command line goals:
      <project>-create-project
        This goal is fully defined only when the create-project goal (below) is
        used. To reduce the possibility of accidental creation of new projects
        this goal does nothing if the create-project goal is not in the list of
        command line goals.
    Parameters:
      1 = The project file name. This is used to name:
            The project make segment file.
            The project directory.
            Project specific goals.
      2 = The project variable name. This is used as part of variable
          names to create variables specific to the project. Typically
          this should be equal to $$(call To-Shell-Var,<project file base name>).
      3 = The optional seed project to use if creating a new project. The
          contents of the seed project directory are copied to the new
          project. The seed project makefile segment is used to generate the
          new project makefile segment.

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
