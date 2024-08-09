#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Macros to support ModFW repos.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,Macros to support ModFW repos.)
# -----

$(call Use-Segment,nodes)

define _help
Make segment: ${Seg}.mk

This segment defines macros for managing ModFW repos. They are intended to
be called only by the higher level macros (see help-projects, help-kits, and
help-mods).

A ModFW repo contains, at minimum, a makefile segment having the same name as
the repo. The full path to this segment is available in the <repo>.seg_f
attribute.

Command line goals:
  help-${SegUN}   Display this help.
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Add-Help-Section,repo-vars,Variables for managing repos.)

_var := repos
${_var} :=
define _help
${_var}
  The list of declared repos.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := repo_attributes
${_var} := seg_f seg_un repo_url repo_branch
define _help
${_var}
  A ModFW at minimum contains a makefile segment which is named using the
  repo node name.

  A repo extends a node with the following additional attributes:

  <repo>.seg_f
    The path and file name of the makefile segment for the repo. NOTE: If
    this file exists then the repo is a ModFW repo.
  <repo>.seg_un
    The unique name for the repo derived from <repo>.seg_f.
  <repo>.repo_url
    The URL of the server for cloning the repo from either a remote server
    or a local directory. Note that the name of the repo does not need to be
    the same as the name of the repo in the URL. If this is empty then the repo
    is not a clone and therefore cannot be pushed.
  <repo>.repo_branch
    The branch to switch to after cloning the repo. This is also used to derive
    the name of the node in which the repo resides.


  The node attributes are:
${help-node_attributes}
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

$(call Add-Help-Section,repo-ifs,Macros for checking repo status.)

_macro := repo-is-declared
define _help
${_macro}
  Returns a non-empty value if the repo has been declared.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(if $(filter $(1),${repos}),1)

$(call Add-Help-Section,repo-decl,Macros for declaring repos.)

_macro := declare-repo
define _help
${_macro}
  Declare a previously declared node to be a repo and define the repo
  attributes.
  Parameters:
    1 = <repo>: The name of the node which will contain the repo.
    2 = The URL for cloning the repo. This can reference either a remote
        server (e.g. https://<server>/<repo> or git@<server>/<repo>) or full
        path to an existing local repo.
        If this is empty and <repo>.URL is empty then DEFAULT_URL/<repo> is
        used.
        If this is equal to "${LOCAL_REPO}" then the repo is not a clone of
        another repo.
    3 = The repo branch to switch to when cloning or creating the repo.
        If this is empty and <repo>.repo_branch is empty then DEFAULT_BRANCH is used.
${help-repo_attributes}
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repo=$(1) url=$(2) branch=$(3))
$(if $(call repo-is-declared,$(1)),
  $(call Warn,Repo $(1) has already been declared.)
,
  $(if $(call node-is-declared,$(1)),
    $(call Verbose,Declaring repo $(1).)
    $(if $(2),
      $(eval _u := $(2))
    ,
      $(if ${$(1).URL},
        $(eval _u := ${$(1).URL})
      ,
        $(eval _u := ${DEFAULT_URL}/$(1))
      )
    )
    $(if $(filter ${_u},${LOCAL_REPO}),
      $(eval $(1).repo_url :=)
    ,
      $(eval $(1).repo_url := ${_u})
    )
    $(call Verbose,Repo URL is:${$(1).repo_url})

    $(if $(3),
      $(eval $(1).repo_branch := $(3))
    ,
      $(if ${$(1).BRANCH},
        $(eval $(1).repo_branch := ${$(1).BRANCH})
      ,
        $(eval $(1).repo_branch := ${DEFAULT_BRANCH})
      )
    )
    $(call Verbose,Seg path is:${$(1).path})
    $(if ${$(1).path},
      $(eval $(1).seg_f := ${$(1).path}/$(1).mk)
      $(call Path-To-UN,${$(1).seg_f},$(1).seg_un)
      $(eval repos += $(1))
    ,
      $(call Signal-Error,The path for node $(1) is empty.)
      $(call display-node,$(1))
    )
  ,
    $(call Signal-Error,The node for repo $(1) has not been declared.)
  )
)
$(call Exit-Macro)
endef

_macro := undeclare-repo
define _help
${_macro}
  Undeclare node as a repo and undefine the repo attributes.
  NOTE: The node containing the repo is not affected.
  NOTE: See help-repo_attributes for more information.
  Parameters:
    1 = <repo>: The name of the node previously declared as a repo.
${help-repo_attributes}
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repo=$(1))
$(if $(call repo-is-declared,$(1)),
  $(foreach _a_,${repo_attributes},
    $(eval undefine $(1).${_a_})
  )
  $(eval repos := $(filter-out $(1),${repos}))
,
  $(call Signal-Error,Repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

_macro := repo-exists
define _help
${_macro}
  This returns a non-empty value if a node contains a git repo.
  Parameters:
    1 = The name of a previously declared repo.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(if $(wildcard ${$(1).path}/.git/HEAD),1)

_macro := is-modfw-repo
define _help
${_macro}
  This returns a non-empty value if a node contains a ModFW style repo.
  Parameters:
    1 = The name of a previously declared repo.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = \
  $(and \
    $(call repo-is-declared,$(1)),\
    $(call node-exists,$(1)),\
    $(call repo-exists,$(1)),\
    $(wildcard ${$(1).seg_f}) \
  )

_macro := is-a-clone-repo
define _help
${_macro}
  Returns non-empty if the repo is a clone of another repo.
  Paramters:
    1 = The repo to check.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = {$(1).repo_url}

$(call Add-Help-Section,repo-info,Macros for getting repo information.)

_macro := get-repo-url
define _help
${_macro}
  Use git to get the URL for the repo.
  Parameters:
    1 = The name of a previously declared and existing repo.
  Returns:
    The url for the repo.
    Run_Rc and Run_Output
      See Run (help-helpers).
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),repo=$(1))
  $(if $(call repo-is-declared,$(1)),
    $(if $(call repo-exists,$(1)),
      $(call Run,git -C ${$(1).path} ls-remote | grep From)
      $(if ${Run_Rc},
        $(call Signal-Error,Git returned an error when getting URL for repo $(1).)
      ,
        $(word 2,${Run_Output})
      )
    ,
      $(call Signal-Error,$(1) is NOT a repo.)
    )
  ,
    $(call Signal-Error,Repo $(1) has not been declared.)
  )
  $(call Exit-Macro)
)
endef

_macro := get-active-branch
define _help
${_macro}
  Use git to get the active branch for the repo.
  Parameters:
    1 = The name of an existing and previously declared repo.
  Returns:
    The active branch for the repo. This is empty if git returned an error.
    Run_Rc and Run_Output
      See Run (help-helpers).
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),repo=$(1))
  $(if $(call repo-is-declared,$(1)),
    $(if $(call repo-exists,$(1)),
      $(call Run,git -C ${$(1).path} symbolic-ref --short HEAD)
      $(if ${Run_Rc},
        $(call Signal-Error,Could not get branch from repo:$(1))
      ,
        $(word 1,${Run_Output})
      )
    ,
      $(call Signal-Error,$(1) is NOT a repo.)
    )
  ,
    $(call Signal-Error,Repo $(1) has not been declared.)
  )
  $(call Exit-Macro)
)
endef

$(call Add-Help-Section,repo-reports,Macros for reporting repo information.)

_macro := display-repo
define _help
${_macro}
  Display repo attributes.
  Parameters:
    1 = The name of the repo.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),repo=$(1))
  $(if $(call repo-is-declared,$(1))
    $(call Display-Vars,\
      $(foreach _a,${repo_attributes},$(1).${_a})
    )
    $(call display-node,$(1))
  ,
    $(call Test-Info,Node $(1) is not a member of ${repos})
  )
  $(call Exit-Macro)
endef

$(call Add-Help-Section,repo-ifs,Macros for checking repo status.)

_macro := repo-branch-exists
define _help
${_macro}
  Check to see if a repo has a given branch. A non-empty value is returned if
  the branch exists.
  NOTE: This is designed to be callable from the make command line using the
  helpers call-${_macro} goal.
  For example:
    make ${_macro}.PARMS=<repo>:<branch> call-${_macro}
  Parameters:
    1 = The repo to check.
    2 = The name of the branch to check. If this is empty then the
        <repo>.repo_branch attribute is used.
  Returns:
    The the branch name. This is empty if the branch does not exist.
    Run_Rc and Run_Output
      See Run (help-helpers).
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),repo=$(1) branch=$(2))
  $(if $(call repo-is-declared,$(1)),
    $(if $(call repo-exists,$(1)),
      $(if $(2),
        $(eval _b_ := $(2)),
      ,
        $(eval _b_ := ${$(1).repo_branch})
      )
      $(call Run,git -C ${$(1).path} branch --list ${_b_})
      $(call Verbose,Branch:${Run_Output})
      $(filter ${_b_},${Run_Output})
    ,
      $(call Signal-Error,$(1) is NOT a repo.)
    )
  ,
    $(call Signal-Error,Repo $(1) has not been declared.)
  )
  $(call Exit-Macro)
)
endef

_macro := branches
define _help
${_macro}
  Run git to get a list of branches for a repo. The repo must have been
  declared at some point and must exist.
  NOTE: This is designed to be callable from the make command line using the
  helpers call-${_macro} goal.
  For example:
    make ${_macro}.PARMS=<repo> call-${_macro}
  Parameters:
    1 = The repo for which to display the branches.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),repo=$(1))
  $(if $(call repo-is-declared,$(1)),
    $(if $(call repo-exists,$(1)),
      $(call Run,git -C ${$(1).path} branch)
      $(if ${Run_Rc},
        $(call Signal-Error,Error when listing branches for repo $(1).)
      ,
        $(call Info,Repo $(1) branches:${Run_Output})
        ${Run_Output}
      )
    ,
      $(call Signal-Error,$(1) is NOT a repo.)
    )
  ,
    $(call Signal-Error,Repo $(1) has not been declared.)
  )
  $(call Exit-Macro)
)
endef

$(call Add-Help-Section,repo-branching,Macros for managing repo branches.)

_macro := switch-branch
define _help
${_macro}
  Switch a repo to a different branch. The <repo>.repo_branch attribute is
  updated to indicate which branch.
  NOTE: This is designed to be callable from the make command line using the
  helpers call-${_macro} goal.

  For example:
    make ${_macro}.PARMS=<repo>:<branch> call-${_macro}
  Parameters:
    1 = The repo to switch the branch.
    2 = The name of the branch to switch to. If this is empty then
        <repo>.BRANCH is used.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repo=$(1) branch=$(2))
$(if $(call repo-is-declared,$(1)),
  $(if $(call repo-exists,$(1)),
    $(if $(2),
      $(eval _b_ := $(2))
    ,
      $(eval _b_ := ${$(1).BRANCH})
    )
    $(eval _ab_ := $(call get-active-branch,$(1)))
    $(if $(filter ${_b_},${_ab_}),
      $(call Attention,Branch ${_ab_} is already active.)
    ,
      $(if $(call repo-branch-exists,$(1),${_b_}),
        $(call Run,git -C ${$(1).path} switch ${_b_})
        $(if ${Run_Rc},
          $(call Signal-Error,Switch to branch ${_b_} failed.)
          $(call Info,${Run_Output})
        ,
          $(eval $(1).repo_branch := ${_b_})
        )
      ,
        $(call Signal-Error,Repo $(1) does not have a branch named ${_b_}.)
      )
    )
  ,
    $(call Signal-Error,$(1) is NOT a repo.)
  )
,
  $(call Signal-Error,Repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

_macro := mk-branch
define _help
${_macro}
  Create a new branch in a repo and switch to the new branch. This does NOT
  change the <repo>.BRANCH sticky variable.
  NOTE: This is designed to be callable from the make command line using the
  helpers call-${_macro} goal.
  For example:
    make ${_macro}.PARMS=<repo>:<branch> call-$(_macro)
  Parameters:
    1 = The repo in which to create the new branch.
    2 = The name of the branch to create.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repo=$(1) branch=$(2))
$(if $(call repo-is-declared,$(1)),
  $(if $(call repo-exists,$(1)),
    $(if $(call repo-branch-exists,$(1),$(2)),
      $(call Signal-Error,Branch $(2) already exists in repo $(1).)
    ,
      $(call Run,git -C ${$(1).path} switch -c $(2))
      $(if ${Run_Rc},
        $(call Signal-Error,Creating new branch ${_2} failed.)
        $(call Warn,${Run_Output})
      ,
        $(eval $(1).repo_branch := $(2))
      )
    )
  ,
    $(call Signal-Error,$(1) is NOT a repo.)
  )
,
  $(call Signal-Error,Repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

_macro := rm-branch
define _help
${_macro}
  Remove an existing branch from a repo.
  NOTE: This is designed to be callable from the make command line using the
  helpers call-${_macro} goal.
  For example:
    make ${_macro}.PARMS=<repo>:<branch> call-$(_macro)
  Parameters:
    1 = The repo to switch the branch.
    2 = The name of the branch to create.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repo=$(1) branch=$(2))
$(if $(call repo-is-declared,$(1)),
  $(if $(call repo-exists,$(1)),
    $(if $(call repo-branch-exists,$(1),$(2)),
      $(call Run,git -C ${$(1).path} branch -d $(2))
      $(call Info,${Run_Output})
    ,
      $(call Signal-Error,Repo $(1) does not contain branch $(2).)
    )
  ,
    $(call Signal-Error,$(1) is NOT a repo.)
  )
,
  $(call Signal-Error,Repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

$(call Add-Help-Section,repo-branching,Macros for managing repo revisions.)

_macro := add-file-to-repo
define _help
${_macro}
  Use git to add a file to an existing repository.

  NOTE: This is designed to be callable from the make command line using the
  helpers call-${_macro} goal.
  For example:
    make ${_macro}.PARMS=<repo>+<file> call-${_macro}
  Parameters:
    1 = The repo to which to add the file.
    2 = The file to add.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repo=$(1) file=$(2))
$(if $(call is-modfw-repo,$(1)),
  $(call Run, \
    cd ${$(1).path} && \
    git add $(2) && git commit $(2) -m "Added file $(2)."
  )
,
  $(call Signal-Error,Node $(1) is not a ModFW repo.)
)
$(call Exit-Macro)
endef

$(call Add-Help-Section,repo-remote,Macros for updating remote repos.)

_macro := diff-repos
define _help
${_macro}
  Display the differences of one or more repos.

  This is provided help the dev avoid having to navigate to repo directories.

  NOTE: This is designed to be callable from the make command line using the
  helpers call-${_macro} goal.
  For example:
    make ${_macro}.PARMS="<repo> <repo>..." call-${_macro}
  Parameters:
    1 = The list of repos to display differences. If this is empty then all
        repos which have been declared will be displayed.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repos=$(1))

$(if $(1),
  $(eval _repos := $(1))
,
  $(eval _repos := ${repos})
)
$(call Attention,Displaying differences for repos:${_repos})
$(foreach _r,${_repos},
  $(if $(call repo-is-declared,${_r}),
    $(if $(call repo-exists,${_r}),
      $(call Info,Differences for repo ${_r}.)
      $(call Run,git -C ${${_r}.path} diff)
      $(if ${Run_Rc},
        $(call Signal-Error,\
          An error occurred when getting status for repo ${_r}.)
      )
    ,
      $(call Signal-Error,The repo ${_r} does not exist.)
    )
  ,
    $(call Signal-Error,The repo ${_r} has not been declared.)
  )
)
$(call Exit-Macro)
endef

_macro := status-repos
define _help
${_macro}
  Display the status of one or more repos.

  This is provided help the dev avoid having to navigate to repo directories.

  NOTE: This is designed to be callable from the make command line using the
  helpers call-${_macro} goal.
  For example:
    make ${_macro}.PARMS="<repo> <repo>..." call-${_macro}
  Parameters:
    1 = The list of repos to display. If this is empty then all
        repos which have been declared will be displayed.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repos=$(1))

$(if $(1),
  $(eval _repos := $(1))
,
  $(eval _repos := ${repos})
)
$(call Attention,Displaying status for repos:${_repos})
$(foreach _r,${_repos},
  $(if $(call repo-is-declared,${_r}),
    $(if $(call repo-exists,${_r}),
      $(call Info,Status for repo ${_r}.)
      $(call Run,git -C ${${_r}.path} status)
      $(if ${Run_Rc},
        $(call Signal-Error,\
          An error occurred when getting status for repo ${_r}.)
      )
    ,
      $(call Signal-Error,The repo ${_r} does not exist.)
    )
  ,
    $(call Signal-Error,The repo ${_r} has not been declared.)
  )
)
$(call Exit-Macro)
endef

_macro := log-repos
define _help
${_macro}
  Display the commit log for one or more repos.

  This is provided help the dev avoid having to navigate to repo directories.

  WARNING: Because of the potential size of commit logs the output is routed to
  the log file. Because of this this the log file must be enabled.
  See help-LOG_FILE for more information.

  NOTE: This is designed to be callable from the make command line using the
  helpers call-${_macro} goal.
  For example:
    make ${_macro}.PARMS="<repo> <repo>..." call-${_macro}
  Parameters:
    1 = The list of repos to display. If this is empty then all
        repos which have been declared will be displayed.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repos=$(1))

$(if ${LogFile},
  $(if $(1),
    $(eval _repos := $(1))
  ,
    $(eval _repos := ${repos})
  )
  $(call Attention,Displaying commit logs for repos:${_repos})
  $(foreach _r,${_repos},
    $(if $(call repo-is-declared,${_r}),
      $(if $(call repo-exists,${_r}),
        $(call Info,Commit log for repo ${_r}.)
        $(call Run,git -C ${${_r}.path} log)
        $(if ${Run_Rc},
          $(call Signal-Error,\
            An error occurred when getting log for repo ${_r}.)
        )
      ,
        $(call Signal-Error,The repo ${_r} does not exist.)
      )
    ,
      $(call Signal-Error,The repo ${_r} has not been declared.)
    )
  )
,
  $(call Signal-Error,Logging must be enabled to get the commit logs.)
)
$(call Exit-Macro)
endef

_macro := repo-has-changes
define _help
${_macro}
  Returns a non-empty string if there are files which have changed since the
  last commit.
  Parameters:
    1 = The name of the repo.
  Returns:
    _changed_files
      The list of changed files returned by git.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),repo=$(1))
  $(if $(call repo-is-declared,$(1)),
    $(call Run,git -C ${$(1).path} status -s)
    $(if ${Run_Rc},
      $(call Signal-Error,An error occurred when checking status of $(1).)
    ,
      $(call Attention,Changed files:${Run_Output})
      $(eval _l := $(words ${Run_Output}))
      $(if $(filter 0,${_l}),
      ,
        $(call Dec-Var,_l)
        $(if $(filter 0,${_l}),
          $(eval _changed_files := )
        ,
          $(eval _changed_files := $(wordlist 1,${_l},${Run_Output}))
          $(call Info,Returning:${_changed_files})
        )
      )
    )
  ,
    $(call Test-Info,Repo $(1) has not been declared.)
  )
  $(call Exit-Macro)
endef

_var := repo_commit_msg
${_var} := Checkpoint commit.
define _help
${_var}
  The last repo commit message.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_macro := commit-repos
define _help
${_macro}
  Commit all changes to one or more repos. The dev is prompted to enter a
  commit message which will be used for all repos being committed.

  This is provided help the dev avoid having to navigate to repo directories.

  NOTE: This is designed to be callable from the make command line using the
  helpers call-${_macro} goal.
  For example:
    make ${_macro}.PARMS="<repo> <repo>..." call-${_macro}
  Parameters:
    1 = The list of repos to commit changes to. If this is empty then all
        repos which have been declared will be committed.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repos=$(1))

$(if $(1),
  $(eval _repos := $(1))
,
  $(eval _repos := ${repos})
)
$(foreach _r,${_repos},
  $(if $(call repo-is-declared,${_r}),
    $(if $(call repo-exists,${_r}),
      $(call repo-has-changes,${_r})
      $(if ${_changed_files},
        $(call Info,Changed files:${_changed_files})
        $(info Previous message:${repo_commit_msg})
        $(info Enter an empty string to use the previous message.)
        $(info Enter a single line commit message for repo ${_r}.)
        $(eval _msg := $(call Input,Commit message))
        $(if ${_msg},
        ,
          $(eval _msg := ${repo_commit_msg})
        )
        $(call Attention,Message:${_msg})
        $(eval _y := $(call Confirm,Commit ${_r}?,y))
        $(if ${_y},
          $(call Info,Commit for repo ${_r}.)
          $(call Run,git -C ${${_r}.path} commit . -m "${_msg}")
          $(if ${Run_Rc},
            $(if $(filter 1,${Run_Rc}),
              $(call Attention,No files to commit to repo ${_r})
            ,
              $(call Signal-Error,An error occurred when committing repo ${_r}.)
            )
          ,
            $(call Attention,Committed files in repo ${_r}.)
            $(eval repo_commit_msg := ${_msg})
          )
        ,
          $(call Attention,Skipping commit for ${_r}.)
        )
      ,
        $(call Attention,Repo ${_r} has no changes to commit.)
      )
    ,
      $(call Signal-Error,The repo ${_r} does not exist.)
    )
  ,
    $(call Signal-Error,The repo ${_r} has not been declared.)
  )
)
$(call Exit-Macro)
endef

_macro := push-repos
define _help
${_macro}
  Push all commits to one or more remote repos.

  This is provided help the dev avoid having to navigate to repo directories.

  NOTE: This is designed to be callable from the make command line using the
  helpers call-${_macro} goal.
  For example:
    make ${_macro}.PARMS="<repo> <repo>..." call-${_macro}
  Parameters:
    1 = The list of repos to push. If this is empty then all repos which have
        been declared will be pushed.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repos=$(1))

$(if $(1),
  $(eval _repos := $(1))
,
  $(eval _repos := ${repos})
)
$(foreach _r,${_repos},
  $(if $(call repo-is-declared,${_r}),
    $(if $(call repo-exists,${_r}),
      $(if $(call is-a-clone-repo(${_r})),
        $(call Run,git -C ${${_r}.path} push)
        $(if ${Run_Rc},
          $(call Signal-Error,An error occurred when pushing repo ${_r}.)
        ,
          $(call Attention,Pushed files to remote repo ${_r}.)
        )
      ,
        $(call Attention,Repo ${_r} is not a clone -- not pushing.)
      )
    ,
      $(call Signal-Error,The repo ${_r} does not exist.)
    )
  ,
    $(call Signal-Error,The repo ${_r} has not been declared.)
  )
)
$(call Exit-Macro)
endef

$(call Add-Help-Section,repo-install,Macros for cloning and creating repos.)

_macro := remote-repo-exists
define _help
${_macro}
  Check to see if a remote repo exists. A non-empty value is returned if
  the repo exists.
  Parameters:
    1 = The repo to check.
    2 = The URL to check. If this is empty then the <repo>.repo_url variable.
  Returns:
    True if the remote repo exists.
      See Run (help-helpers).
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repo=$(1) branch=$(2))
$(if $(call repo-is-declared,$(1)),
  $(if $(2),
    $(eval _u_ := $(2))
  ,
    $(eval _u_ := ${$(1).repo_url})
  )
  $(if $(call is-a-clone-repo,$(1)),
    $(call Run,git ls-remote ${_u_} 2>/dev/null)
    $(if ${Run_Rc},
      $(call Attention,Remote repo $(1) does not exist.)
      $(eval Run_Rc := )
      ${False}
    ,
      $(call Attention,Remote repo ${_u_} exists.)
      ${True}
    )
  ,
    $(call Attention,Repo $(1) is not a clone -- cannot check remote.)
    ${False}
  )
,
  $(call Signal-Error,Repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

_macro := set-repo-origin
define _help
${_macro}
  Change the repo origin to a different URL. This is mostly intended to be used
  when creating new repos but can be used to change the origin of an existing
  repo.

  NOTE: This is designed to be callable from the make command line using the
  helpers call-${_macro} goal.
  For example:
    make ${_macro}.PARMS=<repo>:<url> call-$(_macro)
  Parameters:
    1 = The repo for which to set the origin.
    2 = The new url. If this is empty then <repo>.URL is used.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
$(call Declare-Callable-Macro,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repo=$(1) url=$(2))
$(if $(call repo-is-declared,$(1)),
  $(if $(2),
    $(eval _origin_ := $(2))
  ,
    $(if ${$(1).URL},
      $(eval _origin_ := ${$(1).URL})
    ,
      $(call Signal-Error,URL has not been specified.)
    )
  )
  $(if $(Errors),
    $(call Attention,An error occurred -- not setting origin.)
  ,
    $(call Run,git -C ${$(1).path} remote get-url origin)
    $(if ${Run_Rc},
      $(call Run,git -C ${$(1).path} remote add origin ${_origin_})
      $(if $(call remote-repo-exists,$(1),${_origin_}),
      ,
        $(call Attention,Added remote -- be sure to create the remote repo.)
      )
    ,
      $(if $(call remote-repo-exists,$(1),${_origin_}),
        $(call Run,git -C ${$(1).path} remote set-url origin ${_origin_})
      ,
        $(call Signal-Error,\
          Cannot set remote url -- the remote repo does not exist.)
      )
    )
    $(if ${Run_Rc},
      $(call Signal-Error,Setting the remote origin ${_origin_} failed.)
      $(call Warn,${Run_Output})
    ,
      $(eval $(1).repo_url := ${_origin_})
    )
  )
,
  $(call Signal-Error,Repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

_macro := clone-repo
define _help
${_macro}
  Use git to clone either a local or remote repo to a declared repo directory
  and switch to the specified branch. The repo node cannot exist.
  Parameters:
    1 = The name of a previously declared repo.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repo=$(1))
$(if $(call node-exists,$(1)),
  $(call Verbose,The repo node $(1) already exists -- not cloning.)
,
  $(call Run,git clone -b ${$(1).repo_branch} ${$(1).repo_url} ${$(1).path})
  $(if ${Run_Rc},
    $(call Signal-Error,Clone of repo $(1) from ${$(1).repo_url} failed.)
  ,
    $(if $(call repo-exists,$(1)),
      $(call switch-branch,$(1))
    ,
      $(call Signal-Error,Was not able to clone ${$(1).repo_url} to repo $(1).)
    )
  )
)
$(call Exit-Macro)
endef

_macro := mk-repo-from-template
define _help
${_macro}
  Use an existing ModFW repo as a template to create a new ModFW repo. The URL
  of the new repo is set to point to the template repo. The template repo is
  cloned to the new repo node and a new makefile segment is created using the
  origin repo segment as a template. The origin of the new repo is removed to
  avoid accidental commits to the template repo. The new makefile segment is
  then added and committed to the repo.
  Parameters:
    1 = The name of the new repo.
    2 = The existing local or remote repo to use as the template for the new
        repo.
  Returns:
    Run_Rc and Run_Output
      See Run (help-helpers).
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repo=$(1) template=$(2))
$(if $(call node-exists,$(1)),
  $(call Signal-Error,The repo node $(1) already exists -- not cloning.)
,
  $(if $(call repo-exists,$(2)),
    $(if $(call is-modfw-repo,$(2)),
      $(eval $(1).repo_url := ${$(2).path})
      $(call clone-repo,$(1))
      $(call Run,git -C ${$(1).path} remote remove origin)
      $(if ${Run_Rc},
        $(call Signal-Error,Error removing template origin from $(2).)
      ,
        $(call Verbose,Deriving:${$(1).seg_f})
        $(call Derive-Segment-File,$(2),${$(2).seg_f},$(1),${$(1).seg_f})
        $(call Run, \
          cd ${$(1).path} && \
          git add . && \
          git commit . -m "New repo $(1) derived from $(2)." \
        )
        $(if ${Run_Rc},
          $(call Signal-Error,Error during edit of $(1) segment file.)
        )
      )
    ,
      $(call Signal-Error,Template node $(2) is not a ModFW repo.)
    )
  ,
    $(call Signal-Error,Template node $(2) is not a repo.)
  )
)
$(call Exit-Macro)
endef

_macro := init-modfw-repo
define _help
${_macro}
  Use git to initialize a new repo. If a repo makefile segment does not exist
  a new makefile segment is generated from a template and committed to the repo. After initialization the dev needs to customize the makefile segment for its intended use.
  NOTE: Any existing files in the repo directory are automatically added to the
  repo.
  Parameters:
    1 = The name of a previously declared repo.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repo=$(1))
$(if $(call repo-is-declared,$(1)),
  $(if $(call is-modfw-repo,$(1)),
    $(call Info,The node $(1) is already a ModFW repo -- no init.)
  ,
    $(if $(call repo-exists,$(1)),
      $(call Info,Node $(1) is already a repo.)
    ,
      $(call Run,git init -b ${$(1).repo_branch} ${$(1).path})
      $(if ${Run_Rc},
        $(call Signal-Error,Error when initializing repo $(1).)
      ,
        $(if $(wildcard ${$(1).seg_f}),
          $(call Info,Using existing makefile segment.)
        ,
          $(call Info,Generating makefile segment for repo:$(1))
          $(call Gen-Segment-File,\
            $(1),${$(1).seg_f},<edit this description for repo>:$(1))
        )
        $(call Run, \
          cd ${$(1).path} && \
          git add . && git commit . -m "New repo $(1) initialized."
        )
        $(if ${Run_Rc},
          $(call Signal-Error,Error when committing repo $(1) files.)
        ,
          $(if $(call is-remote-repo,$(1)),
            $(call set-repo-origin,$(1))
          ,
            $(call Attention,Repo $(1) is a local repo -- not setting origin.)
          )
        )
      )
    )
  )
,
  $(call Signal-Error,Repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

_macro := mk-modfw-repo
define _help
${_macro}
  Create a new local repo in a previously created node. The node is initialized
  to contain a repo. A makefile segment for the new repo is generated and added
  to the repo along with any other files already existing in the node.
  Parameters:
    1 = The name of the new repo.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repo=$(1))
$(if $(call repo-is-declared,$(1)),
  $(if $(call node-exists,$(1)),
    $(if $(call repo-exists,$(1)),
      $(call Signal-Error,Repo $(1) already exists.)
    ,
      $(call Info,Creating repo $(1).)
      $(call init-modfw-repo,$(1))
    )
  ,
    $(call Signal-Error,The node for repo $(1) does not exist.)
  )
,
  $(call Signal-Error,Repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

_macro := rm-repo
define _help
${_macro}
  Remove a repo. This deletes the repo .git directory and leaves all
  other files intact.
  To completely remove the repository contents use rm-node instead.
  WARNING: Use with care! This can have serious consequences.
  Parameters:
    1 = The name of the repo to destroy.
    2 = An optional prompt for Confirm.
    3 = If not empty then use this as the response. When equal to y then
        remove the repo without a prompt.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),repo=$(1) Prompt=$(call To-String,$(2)) auto=$(3))
  $(if $(call repo-is-declared,$(1)),
    $(if $(call node-exists,$(1)),
      $(if $(call repo-exists,$(1)),
        $(if $(2),
          $(eval _p_ := $(2))
        ,
          $(eval _p_ := Destroy repo $(1)?)
        )
        $(eval _rm := )
        $(if $(3),
          $(call Attention,Setting automatic response to $(3))
          $(if $(filter $(3),y),
            $(eval _rm := y)
          )
        ,
          $(if $(call Confirm,${_p_},y),
            $(eval _rm := y)
          )
        )
        $(call Attention,Response is:${_rm})
        $(if ${_rm},
          $(call Attention,Removing repo $(1))
          $(call Run,rm -rf ${$(1).path}/.git)
        )
      ,
        $(call Signal-Error,Node $(1) is not a repo -- not removing repo.)
      )
    ,
      $(call Signal-Error,Repo $(1) node does not exist.)
    )
  ,
    $(call Signal-Error,Repo $(1) has not been declared.)
  )
  $(call Exit-Macro)
endef

$(call Add-Help-Section,repo-use,The primary macro for using repos.)

_macro := install-repo
define _help
${_macro}
  Install a repo in a declared node. A repo must always have a parent node. The
  parent node must have been previously declared and must exist. Similarly,
  the repo must have been previously declared. If the repo doesn't exist
  locally, the repo is cloned either from a local repo or from a remote server
  depending upon the URL. Commits to the repo can be pushed to the origin repo
  providing correct credentials are used.
  Parameters:
    1 = <repo>: The name of the repo. This is also the name of the tree node
        for the repo.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),repo=$(1))

$(if $(call repo-is-declared,$(1)),
  $(if $(call repo-exists,$(1)),
    $(call Attention,Repo $(1) already exists -- not installing.)
  ,
    $(if $(call node-exists,$(1)),
      $(call Signal-Error,A node having the repo name $(1) already exists.)
    ,
      $(if ${$(1).parent},
        $(if $(call node-exists,${$(1).parent}),
          $(call clone-repo,$(1))
        ,
          $(call Signal-Error,Parent node for repo $(1) does not exist.)
        )
      ,
        $(call Signal-Error,Repo $(1) is not a child node.)
      )
    )
  )
,
  $(call Signal-Error,The repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

# +++++
# Postamble
# Define help only if needed.
_h := \
  $(or \
    $(call Is-Goal,help-${Seg}),\
    $(call Is-Goal,help-${SegUN}),\
    $(call Is-Goal,help-${SegID}))
ifneq (${_h},)
define _help
$(call Display-Help-List,${SegID})
endef
${_h} := ${_help}
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
