#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Macros to support ModFW segments.
#----------------------------------------------------------------------------
# The prefix $(call This-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call This-Segment-Basename)SegId
$(call Enter-Segment)
# -----

comps :=

define declare-comp
$(if ${$(2)_seg},
  $(call Warn,declare-comp:Component $(2) has already been declared.)
,
  $(call Verbose,declare-comp:Declaring component $(2).)
  $(eval $(2)_seg := $(2))
  $(eval $(2)_dir := $(2))
  $(eval $(2)_path := $(1)/$(2))
  $(eval $(2)_mk := ${$(2)_path}/$(2).mk)
  $(eval $(2)_var := $(call To-Shell-Var,$(2)))
  $(eval comps += $(2))
)
endef

repos :=

define declare-repo
$(call Verbose,declare-repo:Declaring repo $(1).)
$(if $(2),
  $(if $(filter $(2),${$(1)_REPO}),
    $(call Verbose,declare-repo:$(1)_REPO unchanged.)
  ,
    $(call Verbose,declare-repo:Redefining $(1)_REPO.)
    $(call Redefine-Sticky($(1)_REPO=$(2)))
  )
)

$(if $(3),
  $(if $(filter $(3),${$(1)_BRANCH}),
    $(call Verbose,declare-repo:$(1)_BRANCH unchanged.)
  ,
    $(call Verbose,declare-repo:Redefining $(1)_BRANCH.)
    $(call Redefine-Sticky($(1)_BRANCH=$(3)))
  )
)

$(eval $(1)_repo_dir := ${$(1)_dir})
$(eval $(1)_repo_path := ${$(1)_path})
$(eval $(1)_repo_dep := ${$(1)_repo_path}/.git)
$(eval $(1)_repo_mk := ${$(1)_repo_path}/$(1).mk)

$(eval  repos += $(1))

endef

repo_goals :=

define gen-init-dep-goal
$(call Verbose,gen-init-dep-goal:Goal: ${$(1)_repo_dep})

$(eval

${$(1)_repo_dep}:
> git init -b ${$(1)_BRANCH} $$(@D)

)

endef

define gen-clone-dep-goal
$(call Verbose,gen-clone-dep-goal:Goal: ${$(1)_repo_dep})

$(eval

${$(1)_repo_dep}:
> mkdir -p $$(@D) && git clone ${$(1)_REPO} $$(@D)
> cd $$(@D) && git switch ${$(1)_BRANCH}

)
endef

define gen-repo-goal
$(call Verbose,gen-repo-goal:Generating $(1) goal for $(2).)
$(if $(filter $(1),init clone),
  $(eval repo_goals += ${$(2)_repo_mk})
  $(call gen-$(1)-dep-goal,$(2))

  $(eval _seg_${$(2)_var}_txt := \
    $$(call Gen-Segment,$(2),Makefile segment for repo: $(2)))
  $(eval export _seg_${$(2)_var}_txt)

  $(eval

${$(2)_repo_mk}: ${$(2)_repo_dep}
> if [ -e $$@ ]; \
  then \
    touch $$@; \
  else \
    echo "$$$$_seg_${$(2)_var}_txt" >$$@; \
    cd $$(@D) && git add . && git commit . -m "New component initialized."; \
  fi

  )
,
  $(call Signal-Error,\
    gen-repo-goal:Parameter 1=$(1) must be either init or clone.)
)
endef

define gen-basis-to-new-goal
$(eval repo_goals += ${$(1)_repo_mk})
$(eval

${$(1)_repo_dep}: ${$(2)_repo_mk}
> git clone $$(<D) $$(@D)

${$(1)_repo_mk}: ${$(1)_repo_dep}
>  echo "# Derived from basis - $(2)" > $$@
>  sed \
    -e 's/$(2)/$(1)/g' \
    -e 's/${$(2)_var}/${$(1)_var}/g' \
    ${$(2)_repo_mk} >> $$@
> cd $$(@D) && git add . && git commit . -m "New component derived from $(2)."

)
endef

define gen-command-goal
$(if $(call Is-Goal,$(1)),
  $(call Verbose,gen-goal:Generating $(1) to do "$(2)")
  $(if $(3),
    $(if $(call Confirm,$(3),y),
      $(eval
$(1):
$(strip $(2))
      )
    ,
    $(call Verbose,Not doing $(1))
    )
  ,
    $(eval
$(1):
$(strip $(2))
    )
  )
,
  $(call Verbose,gen-goal:Goal $(1) is not on command line.)
)
endef

define gen-branching-goals
$(call gen-command-goal,$(1)-branches,\
  > cd ${$(1)_repo_path} && git branch)

$(call gen-command-goal,$(1)-switch-branch,\
  > cd ${$(1)_repo_path} && git switch ${$(1)_BRANCH})

$(call gen-command-goal,$(1)-new-branch,\
  > cd ${$(1)_repo_path} && \
    git branch ${$(1)_BRANCH},\
  Create branch ${$(1)_BRANCH} in $(1)?)

$(call gen-command-goal,$(1)-remove-branch,\
  > cd ${$(1)_repo_path} && \
    git branch -d ${$(1)_BRANCH},\
  Delete branch ${$(1)_BRANCH} from $(1)?)
endef

define use-repo
$(if $(1),
  $(if $(2),
    $(if ${(2)_seg},
      $(call Info,use-repo:Component $(2) is already in use.)
    ,
      $(call declare-comp,$(1),$(2))
      $(call declare-repo,$(2))
      $(if $(wildcard ${$(2)_repo_mk}),
        $(call Info,use-repo:Using repo: $(2))
        $(call gen-branching-goals,$(2),)
        $(call Add-Segment-Path,${$(2)_repo_path})
        $(call Use-Segment,$(2))
      ,
        $(if ${$(2)_REPO},
          $(call Info,use-repo:Generating goal to clone repo: $(2))
          $(call gen-repo-goal,clone,$(2))
        ,
          $(call Signal-Error,\
            use-repo:Repo $(2) is not defined. Use create-new.)
        )
      )
    )
  )
,
  $(call Signal-Error,use-repo:The repo path has not been specified.)
)
endef

define dup-repo
$(if $(2),
  $(if $(3),
    $(call Verbose,dup-repo:Using $(3) as basis for $(2).)
    $(if $(1),
      $(call use-repo,$(1),$(3))
      $(call gen-basis-to-new-goal,$(2),$(3))
    ,
      $(call Signal-Error,\
        dup-repo:The new and basis repo path has not been specified.)
    )
  ,
    $(call Signal-Error,dup-repo:The basis repo has not been specified.)
  )
,
  $(call Signal-Error,dup-repo:The new repo has not been specified.)
)
endef

define create-repo
$(call Verbose,create-repo:Creating repo $(1).)
$(call Verbose,create-repo:repo:${$(1)_REPO})
$(call Verbose,create-repo:Filtered:$(filter local,${$(1)_REPO}))
$(if $(filter local,${$(1)_REPO}),
  $(call Verbose,create-repo:Creating $(1).)
  $(call gen-repo-goal,init,$(1))
,
  $(call Signal-Error:create-repo:Can only create a local repo.)
)
endef

define new-repo
$(if $(1),
  $(call Sticky,$(2)_REPO,${DEFAULT_REPO})
  $(call Sticky,$(2)_BRANCH,${DEFAULT_BRANCH})
  $(if ${$(2)_REPO},
    $(if ${(2)_seg},
      $(call Signal-Error,new-repo:Repo $(2) has already been declared.)
    ,
      $(call Info,Creating new repo for: $(2))
      $(call declare-comp,$(1),$(2))
      $(call declare-repo,$(2))
      $(if $(3),
        $(call Verbose,new-repo:Duplicating $(2) to repo $(3).)
        $(call dup-repo,$(1),$(2),$(3))
      ,
        $(call Verbose,new-repo:Creating repo $(2).)
        $(call create-repo,$(2))
      )
    )
  ,
    $(call Signal-Error,new-repo:The new repo has not been defined.)
  )
,
  $(call Signal-Error,new-repo:The new repo path has not been specified.)
)
endef

define activate-repo
$(if $(filter $(1),PROJECT KIT),
  $(eval $(2) := $(call Directories-In,${$(1)S_PATH}))
  $(if ${NEW_$(1)},
    $(call Verbose,activate-repo:Creating a new $(1) repo.)
    $(if $(call Confirm,Create new repo ${NEW_$(1)}?,y),
      $(call Sticky,${NEW_$(1)}_REPO,${DEFAULT_REPO})
      $(call Sticky,${NEW_$(1)}_BRANCH,${DEFAULT_BRANCH})
      $(if $(filter,${NEW_$(1)},${projects}),
        $(call Signal-Error,New project ${NEW_$(1)} already exists.)
      ,
        $(if ${BASIS_$(1)},
          $(call Sticky,${BASIS_$(1)}_REPO,${DEFAULT_REPO})
          $(call Sticky,${BASIS_$(1)}_BRANCH,${DEFAULT_BRANCH})
        )
        $(call new-repo,${$(1)S_PATH},${NEW_$(1)},${BASIS_$(1)})
      )
    ,
      $(call Signal-Error,Not creating repo ${NEW_$(1)}.)
    )
  ,
    $(call Verbose,activate-repo:Activate an existing $(1) repo.)
    $(call Sticky,${$(1)}_REPO,${$(1)_REPO})
    $(call Sticky,${$(1)}_BRANCH,${$(1)_BRANCH})

    $(if $(filter $(1),PROJECT),
      $(call Verbose,activate-repo:Pointing STICKY_PATH to the active project.)
      $(eval STICKY_PATH := ${$(1)S_PATH}/${$(1)}/${$(1)}-${$(1)_BRANCH}/sticky)
    )
    $(call use-repo,${$(1)S_PATH},${$(1)})
    $(call Use-Segment,$(3))
  )
,
  $(call Signal-Error,activate-repo:Class is $(1) but must be PROJECT or KIT.)
)

endef

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

This segment defines macros callable from other ModFW segments.

Defines the macros:

declare-comp
  Define the attributes for a ModFW component. A ModFW component can be a
  project, kit or mod. The component name is used:
  - As a prefix for associated variable names (attributes).
  - As the name of the component makefile segment.
  - As the name or part of the name of the directory in which the component
    resides.
  - In the case of projects and kits as the name of the repo in which the
    component is maintained.
  A component must be declared before any other component related macros can be
  used.
  Parameters:
    1 = The path to the directory containing the component directory.
    2 = The name of the component (<comp>).
  Defines variables:
    <comp>_seg    The segment defining the component.
    <comp>_dir    The name of the directory containing the component.
    <comp>_path   The path to the directory containing the component files.
    <comp>_mk     The makefile segment defining the component.
    <comp>_var    The shell variable name corresponding to the component.

declare-repo
  Define the attributes of a component repo. A repo must be declared before
  any other repo related macros can be used.
  Parameters:
    1 = The name of the component declared using declare-comp (<comp>).
    2 = Optional default repo URL.
    3 = Optional default repo branch.
  Defines variables:
    <comp>_REPO       A sticky variable containing the repo URL.
    <comp>_BRANCH     A sticky variable containing the brach to switch to.
    <comp>_repo_dir   The name of the repo directory. This is a combination of
                      the <seg> name and the <seg>_BRANCH.
    <comp>_repo_path  The full path to the repo.
    <comp>_repo_dep   A dependency for the repo. This uses the .git directory in
                      the repo directory as the dependency.
    repos             Adds the repo to the list of repos.

gen-init-repo-goal
  Generate a goal to create and initialize a repo in a local directory. A
  makefile segment for the repo having the same name as the repo is also
  generated.
  NOTE: The new component and repo must have already been declared.
  Parameters:
    1 = The name of the new repo (<comp>).
  Uses:
    <comp>_BRANCH = The main branch for the new repo.

gen-clone-repo-goal
  Generate a goal to clone a remote project or kit repo to a local directory and
  switch to the specified branch.
  Parameters:
    1 = The name of the component corresponding to the repo (<comp>). This is
        used to reference the associated variables.
  Defines variables:
    <comp>_goal   The goal to use to trigger cloning or creating the repo.
    repo_goals    Adds the repo goal to the list of repo goals. This variable
                  can be used to trigger clones of all repos in the list.
  Uses:
    <comp>_REPO   The URL for the repo.
    <comp>_BRANCH The branch to switch to after cloning the repo. The branch
                  must exist.

gen-basis-to-new-goal
  Generate a goal to use a basis component to create a new component. The basis
  component references are changed to the new component references.
  Parameters:
    1 = The new component.
    2 = The basis component.
  Uses variables:
    <comp>_mk The makefile segment for the new component.
    <comp>_mk The makefile segment for the basis component.

gen-command-goal
  Generate a goal. This is provided to reduce repetitive typing. The goal is
  generated only if it is referenced on the command line.
  Parameters:
    1 = The name of the goal.
    2 = The commands for the goal.
    3 = An optional prompt. This generates a y/N confirmation and the goal is
        generated only if the response is y.

gen-branching-goals
  Generate goals to help manage repos. These are provided for convenience to
  help the developer avoid having to find directories where repos are stored.
  Parameters:
    1 = The component (<comp>).
    2 = The branch.
  Generated goals are:
    <comp>-branches
      Display a list of available branches.
    <comp>-switch-branch
      Switches to the branch.
    <comp>-new-branch
      Prompts to create a new branch and if yes creates the branch.
    <comp>-remove-branch
      Prompts to remove an existing branch and if yes deletes the branch.

use-repo
  Use a project or kit repo. If the repo doesn't exist locally a goal is
  generated to clone the repo from a remote server.
  NOTE: This macro is also be designed to be called by mods which are dependent
  on the output of another component.
  Parameters:
    1 = The path to the repo.
    2 = The name of the component (<comp>) corresponding to the repo. This is
        used to name the repo directory and associated variables.

dup-repo
  Copy an existing repo to serve as the basis for a new repo. The makefile
  segment for the basis repo is used to generate the new makefile segment with
  references to the basis component changed to reference the new component. The
  basis makefile segment is retained for reference but no longer used. This
  also generates a "create-repo" goal which must be used on the command line
  which helps avoid accidental creation of useless repos.
  Parameters:
    1 = The path to the directory where the repo will be stored.
    2 = The name of the component (<comp>) corresponding to the new repo. This
        is used to name the repo directory and associated variables.
    3 = The basis component (<basis>) to clone when creating the new repo.
  Uses:
    <comp>_REPO     The URL for the new repo.
    <comp>_BRANCH   The default branch for the new repo.
    <comp>_path     Where to clone the new repo to.
    <comp>_mk       The full path to the makefile segment for the new repo.
    <basis>_REPO    The URL for the basis repo.
    <basis>_BRANCH  The default branch for the basis repo.
    <basis>_path    Where the basis repo resides or is cloned to.
    <basis>_mk      The full path to the makefile segment for the basis repo.

create-repo
  Create a new repo. The makefile segment for the new repo is generated using
  the helpers defined template.
  Parameters:
    1 = The name of the component (<comp>) corresponding to the new repo. This
        is used to name the repo directory and the associated variables.
  Uses:
    <comp>_REPO     The URL for the new repo.

new-repo
  Create a new local repo for a project or a kit. This generates the
  "create-repo" goal which must be used on the command line to create the new
  repo which helps avoid accidental creation of useless repos.
  Parameters:
    1 = The path to where the repo will be stored.
    2 = The name of the segment corresponding to the repo. This is used to
        name the repo directory and associated variables.
    3 = Optional basis repo to clone when creating the new repo. If used this
        triggers a call to dup-repo.

activate-repo
  Activate a project or kit repo. This creates, clones or uses project or kit
  repositories. This is the primary repo macro.
  NOTE: Only one PROJECT and one KIT can be active at a time.
  Parameters:
    1 = Repo <class>: PROJECT or KIT
    2 = The name of the variable to use to hold the list of existing repos
        for the <class>. NOTE: Only repos can be stored in this directory.
    3 = The name of the <next> segment to load after handling the repo. In the
        case of a PROJECT this should be "kits". In the case of a KIT this
        should be "mods".
  Uses:
    <class>S_PATH The path to the directory where the class repos are stored.
  Modes:
    This macro supports two mutually exclusive modes; create and use.

    create  This mode is used to create a new repo when NEW_<class> is not
            empty. It adds dependencies to the "create-new" goal (see help).
            Creating a new repo requires an initial run of make to create the
            new repo before the repos can be used in a later run of make. This
            is because the new repo component makefile segment will simply be a
            template which must be completed by the developer before it will
            have any effect.
      Calls:
        new-repo
      Uses:
        NEW_<class>   If not empty creates a new PROJECT or KIT. This is the
                      name of the component for which the repo is created.
        BASIS_<class> If not empty duplicates an existing project to a new
                      project.

    use     This mode uses an existing repo. The goals generated by this mode
            will install the repo from a remote server if it doesn't exist
            locally. The next segment (<next>) is loaded after the goals for
            the component have been generated.
      Calls:
        use-repo
      Uses:
        <class>         The name of the component to use. This is either
                        PROJECT or KIT.
        <class>_REPO    The remote repo to clone if the component exist locally.
        <class>_BRANCH  The branch to switch to after cloning the repo.
        STICKY_PATH     If the <class> is PROJECT then the sticky variables are
                        stored within the project repo.

Command line goals:
  help-${Seg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
