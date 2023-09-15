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
$(eval
  $(1)_seg := $(1)
  $(1)_path := $(2)/$(1)
  $(1)_mk := ${$(1)_path}/$(1).mk
  $(1)_var := $(call To-Shell-Var,$(1))
  comps += $(1)
)
endef

repos :=

define declare-repo
$(call Sticky,$(1)_REPO)
$(if $(2),
  $(if $(filter $(2),${$(1)_REPO}),
    $(call Verbose,declare-repo:$(1)_REPO unchanged.)
  ,
    $(call Verbose,declare-repo:Redefining $(1)_REPO.)
    $(call Redefine-Sticky($(1)_REPO=$(2)))
  )
)

$(call Sticky,$(1)_BRANCH)
$(if $(3),
  $(if $(filter $(3),${$(1)_BRANCH}),
    $(call Verbose,declare-repo:$(1)_BRANCH unchanged.)
  ,
    $(call Verbose,declare-repo:Redefining $(1)_BRANCH.)
    $(call Redefine-Sticky($(1)_BRANCH=$(3)))
  )
)

$(eval
  $(1)_repo_dir := ${$(1)_dir}-${$(1)_BRANCH}
  $(1)_repo_path := ${$(1)_path}-${$(1)_repo_dir}
  repos += $(1)
)
endef

repo_goals :=

define gen-clone-repo-goal
$  $(eval
$(1)_goal := ${$(1)_repo_path}/.git
repo_goals += ${$(1)_goal}

${$(1)_goal}:
> mkdir -p $$@D && git clone ${$(1)_REPO} $$@D
> cd $$@D && git switch ${$(1)_BRANCH}

  )
endef

define gen-basis-to-new-goal
$(eval
repo_goals += ${(2)_mk}


${$(2)_mk}: ${$(1)_mk}
>  echo "# Derived from basis - $(3)" > $$@
>  sed \
    -e 's/${$(3)_var}/${$(4)_var}/g' \
    -e 's/$(3)/$(4)/g' \
    $$< >> $$@

)
endef

define gen-command-goal
$(if $(call Is-Goal,$(1)),
  $(call Verbose,gen-goal:Generating $(1) to do "$(2)")
  $(if $(3),
    $(if $(call Confirm,$(3),y),
      $(eval
$(1):
$(2)
      )
    ,
    $(call Info,Not doing $(1))
    )
  ,
    $(eval
$(1):
$(2)
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
> cd ${$(1)_repo_path} && git switch $(2))

$(call gen-command-goal,$(1)-new-branch,\
> cd ${$(1)_repo_path} && git branch $(2),Create branch $(2) in $(1)?)

$(call gen-command-goal,$(1)-remove-branch,\
> cd ${$(1)_repo_path} && git branch -d $(2),Delete branch $(2) from $(1)?)
endef

define use-repo
$(if $(1),
  $(if ${(1)_seg},
    $(call Signal-Error,use-repo:Component $(1) is already declared.)
  ,
    $(call declare-comp,$(1),$(2))
    $(call declare-repo,$(1))
    $(if $(wildcard ${$(1)_mk}),
      $(call Info,use-repo:Using repo: $(1))
      $(call Add-Segment-Path,${$(1)_path})
      $(call Use-Segment,${$(1)_mk})
    ,
      $(if ${$(1)_REPO},
        $(call Info,use-repo:Generating goal to clone repo: $(1))
        $(call gen-clone-repo-goal,$(1))
      ,
        $(call Signal-Error,\
          use-repo:Repo $(1) is not defined. Use create-repo.)
      )
    )
  )
,
  $(call Signal-Error,use-repo:The repo has not been specified.)
)
endef

define dup-repo
$(if $(1),
  $(if $(2),
    $(if $(3),
      $(call use-repo,$(2),$(3))
      $(call gen-basis-to-new-goal,$(1),$(2))

      ,
        $(call declare-comp,$(2))
        $(if $(wildcard $(2)_mk),
        ,
        )
      )
    ,
      $(call Signal-Error,dup-repo:The basis repo path has not been specified.)
    )
  ,
    $(call Signal-Error,dup-repo:The basis repo has not been specified.)
  )
,
  $(call Signal-Error,dup-repo:The new repo has not been specified.)
)
endef

define create-repo

endef

define new-repo
$(if $(1),
  $(if ${(1)_seg},
    $(call Signal-Error,new-repo:Repo $(1) is already declared.)
  ,
    $(if $(call Confirm,Create new repo $(1)?,y),
      $(call declare-comp,$(1),$(2))
      $(if $(3),
        $(call declare-comp,basis_$(3),$(2))
        $(if $(filter,local,${$(3)_REPO}),
          $(call dup-repo,$(1),${basis_$(3)_path})
        ,
          $(call dup-repo,$(1),${$(3)_REPO})
        )
      ,
        $(call create-repo,$(1),$(2))
      )
    ,
      $(call Signal-Error,new-repo:Not creating repo $(1).)
    )
  )
,
  $(call Signal-Error,new-repo:The repo has not been specified.)

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
    1 = The name of the component.
    2 = The path to the directory containing the component directory.
  Defines variables:
    <seg>_seg   The segment defining the component.
    <seg>_path  The path to the directory containing the component files.
    <seg>_mk    The makefile segment defining the component.
    <seg>_var   The shell variable name corresponding to the component.

declare-repo
  Define the attributes of a component repo. A repo must be declared before
  any other repo related macros can be used.
  Parameters:
    1 = The name of the component.
    2 = Optional default repo URL.
    3 = Optional default repo branch.
  Defines variables:
    <1>_REPO      A sticky variable containing the repo URL.
    <1>_BRANCH    A sticky variable containing the brach to switch to.
    <1>_repo_dir  The name of the repo directory. This is a combination of
                  the <seg> name and the <seg>_BRANCH.
    <1>_repo_path The full path to the repo.
    repos         Adds the repo to the list of repos.

gen-clone-repo-goal
  Generate a goal to clone a remote project or kit repo to a local directory and
  switch to the specified branch.
  Parameters:
    1 = The name of the segment corresponding to the repo. This is used to
        reference the associated variables.
  Defines variables:
    <1>_goal    The goal to use to trigger cloning or creating the repo.
    repo_goals  Adds the repo goal to the list of repo goals. This variable
                can be used to trigger clones of all repos in the list.
  Uses:
    <1>_REPO    The URL for the repo.
    <1>_BRANCH  The branch to switch to after cloning the repo. The branch
                must exist.

gen-basis-to-new-goal
  Generate a goal to use a basis component segment to create a new component segment. The basis segment references are changed to the new segment references.
  Parameters:
    1 = The basis segment.
    2 = The new segment.
  Uses variables:
    <1>_mk  The makefile segment for the basis component.
    <2>_mk  The makefile segment for the new component.

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
    1 = The component.
    2 = The branch.
  Generated goals are:
    <1>-branches
      Display a list of available branches.
    <1>-switch-branch
      Switches to the branch.
    <1>-new-branch
      Prompts to create a new branch and if yes creates the branch.
    <1>-remove-branch
      Prompts to remove an existing branch and if yes deletes the branch.

use-repo
  Use a project or kit repo. If the repo doesn't exist locally a goal is
  generated to clone the repo from a remote server.
  Parameters:
    1 = The name of the segment corresponding to the repo. This is used to
        name the repo directory and associated variables.
    2 = The path to where the repo will be created.

dup-repo
  Copy an existing repo to serve as the basis for a new repo. The makefile
  segment for the basis repo is used to generate the new makefile segment with
  references to the basis component changed to reference the new component. The
  basis makefile segment is retained for reference but no longer used. This
  also generates a "create-repo" goal which must be used on the command line
  which helps avoid accidental creation of useless repos.
  Parameters:
    1 = The name of the segment corresponding to the new repo. This is used to
        name the repo directory and associated variables.
    2 = The path to the container where the repo will be stored.
    3 = The basis repo to clone when creating the new repo.
  Uses:
    <1>_REPO    The URL for the new repo.
    <1>_BRANCH  The default branch for the new repo.
    <1>_path    Where to clone the new repo to.
    <1>_mk      The full path to the makefile segment for the new repo.
    <2>_REPO    The URL for the basis repo.
    <2>_BRANCH  The default branch for the basis repo.
    <2>_path    Where the basis repo resides or is cloned to.
    <2>_mk      The full path to the makefile segment for the basis repo.

new-repo
  Create a new local repo for a project or a kit. This generates the
  "create-repo" goal which must be used on the command line to create the new
  repo which helps avoid accidental creation of useless repos.
  Parameters:
    1 = The name of the segment corresponding to the repo. This is used to
        name the repo directory and associated variables.
    2 = The path to where the repo will be stored.
    3 = Optional basis repo to clone when creating the new repo. If used this
        triggers a call to dup-repo.

Command line goals:
  help-${Seg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
