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
# If this is not equal to "local" then a remote repo is cloned to create
# the project specific configurations. Otherwise, a new git repository is
# created and initialized.
$(call Overridable,DEFAULT_PROJECT_REPO,local)
# The branch used by the active project.
$(call Overridable,DEFAULT_PROJECT_BRANCH,main)

# These variables are in the default sticky directory.
$(call Sticky,PROJECT)
$(call Sticky,PROJECT_REPO,${DEFAULT_PROJECT_REPO})
$(call Sticky,PROJECT_BRANCH,${DEFAULT_PROJECT_BRANCH})

$(call Require,PROJECT)

# Add a search path for all projects.
$(call Add-Segment-Path,${PROJECTS_PATH})

# Redirect the sticky variables to the active project directory.
project_path := ${PROJECTS_PATH}/${PROJECT}
# Sticky variables are stored in the active project.
STICKY_PATH := ${PROJECTS_PATH}/${PROJECT}/sticky
projects = $(call Directories-In,${PROJECTS_PATH})

projects_deps :=

${PROJECTS_PATH}/.git:
ifeq (${PROJECTS_REPO},local)
> git init -b ${PROJECTS_BRANCH} ${PROJECTS_PATH}
else
> git clone ${PROJECTS_REPO} ${PROJECTS_PATH}
> cd ${PROJECTS_PATH} && \
    git checkout ${PROJECTS_BRANCH} && \
    git config pull.rebase true
endif

projects-branches:
ifneq ($(wildcard ${PROJECTS_PATH}/.git),)
> cd ${PROJECTS_PATH} && git branch -a
else # Local projects repo doesn't exist.
  ifeq (${PROJECTS_REPO},local)
> @echo "Local projects repo does not exist."
  else
> git ls-remote -h ${PROJECTS_REPO}
  endif
endif

define use-project
$(if $(1),
  $(if ${(1)_seg},
    $(call Signal-Error,use-project:Project $(1) is already declared.)
  ,
    $(call declare-comp,$(1),${PROJECTS_PATH})
    $(call Sticky,$(1)_REPO)
    $(call Sticky,$(1)_BRANCH)
    $(if $(wildcard ${$(1)_mk}),
      $(call Info,use-project:Using project: $(1))
      $(call Add-Segment-Path,${$(1)_path})
      $(call Use-Segment,${$(1)_mk})
    ,
      $(if ${$(1)_REPO},
        $(call gen-repo-goal,$(1))
        $(eval projects += $(1))
        $(eval projects_deps += ${$(1)_mk})
      ,
        $(call Signal-Error,\
          use-project:Project $(1) does not exist. Use create-project.)
      )
    )
  )
,
  $(call Signal-Error,use-project:The project has not been specified.)
)
endef

define new-project-n

endef

define use-project-REMOVE
$.ifeq ($(1),)
$$(call Signal-Error,use-project:The project has not been specified.)
$.else $.ifdef $(1)_seg
$$(call Signal-Error,use-project:Project $(1) is already in use.)
$.else
$$(call Verbose,Using project: $(1))

# Project specific variables.
$(1)_seg := $(1)
$(1)_path := ${PROJECTS_PATH}/$(1)
$(1)_mk := $${$(1)_path}/$(1).mk
$(1)_var := $$(call To-Shell-Var,$(1))

$.ifneq ($$(wildcard $${$(1)_path}),)

  # Project segment exists
  project_deps += $${$(1)_mk}
  $$(call Verbose,Using project: $(1))

  $$(call Use-Segment,$(1))
  # This installs kits and uses a mod within a kit. A kit and mod add
  # segment search paths as needed.
  $$(call Use-Segment,kits)

$(1)-create-project:

$.else # Project segment does not exist.

  $.ifeq ($$(call Is-Goal,create-project),)
    # Project does not exist and is not being created.
    $$(call Signal-Error,The project $(1) does not exist. See help-${Seg}.)
  $.else # Create a new project
    $.ifneq ($$(call Confirm,Create new project $(1)?,y),)
      # Yes, create a new project.
      $.ifeq ($(2),)
        # Not using a BASIS_PROJECT
        $$(call Info,Creating project: $(1))
        p_$${$(1)_var}_seg := \
          $$(call Gen-Segment,\
          Project specific definitions for project: $(1),$(1):)
        $.export p_$${$(1)_var}_seg

$${$(1)_mk}: ${PROJECTS_PATH}/.git
> mkdir -p $$(@D) && printf "%s" "$${Dlr}p_$${$(1)_var}_seg" > $$@

# New projects must be initialized using this goal to avoid typos creating
# useless projects.
$(1)-create-project: $${$(1)_mk}
> @echo Project $(1) has been created.

      $.else # Use existing basis project.
        $$(call Info,Creating project: $(1) using $(2))
        p_basis_$(1)_seg := $(2)
        p_basis_$(1)_path := ${PROJECTS_PATH}/$(2)
        p_basis_$(1)_mk := \
          $${p_basis_$(1)_path}/$${p_basis_$(1)_seg}.mk
        p_basis_$(1)_var := $(call To-Shell-Var,$(2))

# The basis project config file is retained in the new project for reference.
$(1)-create-project: $${p_basis_$(1)_mk}
> cp -r $${p_basis_$(1)_path}/ $${$(1)_path}
>  echo "# Derived from basis project - $(2)" > $${$(1)_mk}
>  sed \
    -e 's/$${p_basis_$(1)_var}/$${$(1)_var}/g' \
    -e 's/$(2)/$(1)/g' \
    $${p_basis_$(1)_mk} >> $${$(1)_mk}

      $.endif # Use basis project.
    $.else # NO, don't create a new project.
      $$(call Signal-Error,Project $(1) does not exist.)

$(1)-create-project:

    $.endif # Confirm create the project.
  $.endif # Create project.
$.endif # Project config does not exist.

$.endif # Project already declared.

endef # use-project

# Automatically use the active project.
ifneq (${NEW_PROJECT},)
  $(call new-repo,${NEW_PROJECT},${PROJECTS_PATH},${BASIS_PROJECT})
else
  $(call use-repo,${PROJECT},${PROJECTS_PATH})
endif

$(call Use-Segment,kits)

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

A ModFW project is mostly intended to contain variable definitions needed to
configure mod builds and to create project specific packages using the output
of mod builds. It is possible for one project to be dependent upon the output
of another project. Each project is maintained in a separate git repo.

Although several projects can exists side by side only one can be active at one
time. The active project is indicated by the value of the PROJECT variable, The
"activate" goal is provided for switching between projects. Different projects
can use different versions of the same kits and mods. The versions and
dependencies are typically specified in the project makefile segment. Kit repos
are switched to the project specified branch when the project is activated.

This segment uses git to help manage ModFW projects. If the project repo doesn't
exist then it must first be created using the "create-project" goal. The project
is either created or cloned depending upon the value of PROJECT_REPO (below).
These configurations define the options for kits and mods within the kits.

Sticky variables are stored in the project subdirectory thus allowing each project to have unique values for sticky variables. This segment (${Seg}) changes STICKY_PATH to point to the project specific sticky variables which are also maintained in the repo.

When a project repo is created, a project makefile segment is generated and stored in the project subdirectory. The developer modifies this file as needed. The project makefile segment is typically used to override kit and mod variables. Project specific variables, goals and recipes can also be added. This is also used to define the repos and branches for the various kits used in the project.

A new project can be based upon an existing project by specifying the
existing project using the BASIS_PROJECT command line option. In this case
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

Command line options:
  NEW_PROJECT = ${NEW_PROJECT}
    The name of a new project to create. If this is not empty then a new
    project is declared and the "create-project" goal will create the new
    project.
    This creates new sticky variables for the new project:
      <NEW_PROJECT>_REPO
      <NEW_PROJECTS>_BRANCH
    These are not defined unless the variable NEW_PROJECT is defined on the
    command line.
  BASIS_PROJECT = ${BASIS_PROJECT}
    When defined and creating a new project using "create-project" the new
    project is initialized by copying files from the basis project to the new
    project. e.g. make BASIS_PROJECT=<existing> create-project

Macros:
  use-project
    Declare project specific variables, macros and, goals (a namespace). This
    allows having one project depend upon the output of another. If the project
    segment exists then it is loaded.
    Command line goals:
      <project>-create-project
        This goal is fully defined only when the "create-project" goal (below)
        is used. To reduce the possibility of accidental creation of new
        projects this goal does nothing if the "create-project" goal is not in
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
  create-project
    Create a new project in the projects repo. If the repo does not exist
    it is either cloned from a remote repo or a new local repo is created
    depending upon the PROJECTS_REPO variable.
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
