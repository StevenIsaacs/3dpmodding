#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Macros to support ModFW repos.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,Macros to support ModFW repos.)
# -----

_var := repos
${_var} :=
define _help
${_var}
  The list of declared repos.
endef

_var := repo_attributes
${_var} := URL BRANCH seg_f dep
define _help
${_var}
  A repo extends a node with the following additional attributes:

  Sticky variables:
  <repo>.URL
    The URL of the server for cloning the repo from either a remote server
    or a local directory. Note that the name of the repo does not need to be
    the same as the name of the repo in the URL.
  <repo>.BRANCH
    The branch to switch to after cloning the repo. This is also used to derive
    the name of the node in which the repo resides.

  Additional attributes:
  <repo>.seg_f
    The path and file name of the makefile segment for the repo.
  <repo>.dep
    A dependency used to determine if a node is a repo.

  The node attributes are:
${help-${node_attributes}}
endef
help-${_var} := $(call _help)

_macro := repo-is-declared
define _help
${_macro}
  Returns a non-empty value if the repo has been declared.
endef
help-${_macro} := $(call _help)
${_macro} = $(if $(filter $(1),${repos}),1)

_macro := repo-exists
define _help
${_macro}
  This returns a non-empty value if a node contains a git repo.
  Parameters:
    1 = The name of a previously declared repo.
endef
help-${_macro} := $(call _help)
${_macro} = $(if $(wildcard ${$(1).dep}),1)

_macro := is-modfw-repo
define _help
${_macro}
  Returns a non-empty value if the repo conforms to the ModFW pattern. A ModFW
  repo will always have a makefile segment having the same name as the repo.
  The repo is contained in a node of the same name. The makefile segment file
  will contain the same name to indicate it is customized for the repo.
  Parameters:
    1 = The name of an existing and previously declared repo.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),$(1))
  $(if $(and \
        $(call repo-is-declared,$(1)),\
        $(call node-exists,$(1)),\
        $(call repo-exists,$(1)))
    $(call Run,grep $(1) ${$(1).seg_f})
    $(if ${Run_Rc},
      $(call Debug,grep returned:${Run_Rc})
    ,
      1
    )
  )
  $(call Exit-Macro)
)
endef

_macro := get-repo-url
define _help
${_macro}
  Use git to get the URL for the repo. If the repo is local then the
  LOCAL_REPO (${LOCAL_REPO}) is returned.
  returned.
  Parameters:
    1 = The name of an existing and previously declared repo.
  Returns:
    The url for the repo.
    Run_Rc and Run_Output
      See Run (help-helpers).
endef
help-${_macro} := $(call _help)
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),$(1))
  $(call Run,cd ${$(1).path} && git ls-remote --get-url)
  $(if ${Run_Rc},
    $(call Debug,Using LOCAL_REPO:${LOCAL_REPO})
    ${LOCAL_REPO}
  ,
    $(word 1,${Run_Output})
  )
  $(call Exit-Macro)
)
endef

_macro := get-repo-branch
define _help
${_macro}
  Use git to get the active branch for the repo.
  Parameters:
    1 = The name of an existing and previously declared repo.
  Returns:
    The url for the repo. This is empty if git returned an error.
    Run_Rc and Run_Output
      See Run (help-helpers).
endef
help-${_macro} := $(call _help)
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),$(1))
  $(call Run,cd ${$(1).path} && git symbolic-ref --short HEAD)
  $(if ${Run_Rc},
    $(call Signal-Error,Could not get branch from repo:$(1))
  ,
    $(word 1,${Run_Output})
  )
  $(call Exit-Macro)
)
endef

_macro := declare-repo
define _help
${_macro}
  Declare a previously declared node to be a repo and add the repo attributes
  to the node.
  NOTE: See help-repo_attributes for more information.
  Parameters:
    1 = <repo>: The name of the node which will contain the repo.
${help-repo_attributes}
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))
$(if $(call repo-is-declared,$(1)),
  $(call Signal-Error,Repo $(1) has already been declared.)
,
  $(if $(call node-is-declared,$(1)),
    $(call Sticky,$(1).URL,${DEFAULT_SERVER}/$(1))
    $(call Sticky,$(1).BRANCH,${DEFAULT_BRANCH})
    $(eval _udef := $(call Require,$(1).URL $(1).BRANCH))
    $(if ${_udef},
      $(call Signal-Error,These sticky variables must be defined:${_udef})
    ,
      $(call Verbose,Declaring repo $(1).)
      $(eval $(1).seg_f := ${$(1).path}/$(1).mk)
      $(eval $(1).dep := ${$(1).path}/.git/HEAD)
      $(eval repos += $(1))
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
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))
$(if $(call repo-is-declared,$(1)),
  $(foreach _a,${repo_attributes},
    $(eval undefine $(1).${_a})
  )
  $(eval repos := $(filter-out $(1),${repos}))
,
  $(call Signal-Error,Repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

_macro := display-repo
define _help
${_macro}
  Display repo attributes.
  Parameters:
    1 = The name of the repo.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
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

_macro := clone-repo
define _help
${_macro}
  Use git to clone either a local or remote repo to a new repo and switch to
  the specified branch.
  Parameters:
    1 = The name of an existing and previously declared repo.
    2 = The branch to switch to after cloning the repo. If this is empty then
        <repo>.BRANCH is used.
  Returns:
    Run_Rc and Run_Output
      See Run (help-helpers).
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))
$(if $(call repo-exists,$(1)),
  $(call Verbose,The repo for $(1) exists -- not cloning.)
,
  $(if $(2),
    $(eval _b := $(2))
  ,
    $(eval _b := $(1).BRANCH)
  )
  $(call Run, \
    mkdir -p ${$(1).path} && \
    git clone ${$(1).URL} ${$(1).path} && \
    cd ${$(1).path} && \
    git switch ${_b}\
  )
  $(if $(call is-modfw-repo,$(1)),
  ,
    $(call Signal-Error,Makefile segment for repo $(1) does not exist.)
  )
)
$(call Exit-Macro)
endef

_macro := clone-basis-to-create-repo
define _help
${_macro}
  Clone an existing local or remote repo and use the existing makefile segment
  as the basis to create a new makefile segment for the new segment. The new
  makefile segment is then added and committed to the repo. The origin of the
  new repo is removed to avoid accidental commits to the basis repo.
  Parameters:
    1 = The existing local or remote repo to use as the basis for the new repo.
    2 = The name of the new repo.
  Returns:
    Run_Rc and Run_Output
      See Run (help-helpers).
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))
$(if $(call is-modfw-repo,$(2)),
  $(call Warn,Using existing repo $(2).)
,
  $(if $(call repo-exists,$(2)),
    $(call Warn,Repo $(2) exists -- not cloning.)
  ,
    $(if $(call repo-exists,$(1)),
      $(if $(call is-modfw-repo,$(1)),
        $(if $(call Require,$(2).URL),
          $(call Signal-Error,URL for $(2) is not defined.)
        ,
          $(call clone-repo,$(2))
          $(call Run,cd ${$(2).repo_path} && git remote remove origin)
          $(call Debug,Git RC:(${Run_Rc}))
          $(if ${Run_Rc},
            $(call Signal-Error,Error cloning basis repo.)
          ,
            $(call Verbose,Editing:${$(2).seg_f})
            $(call Run, \
                echo "# Derived from basis - $(1)" > ${$(2).seg_f} &&\
                sed \
                    -e 's/$(1)/$(2)/g' \
                    -e 's/${$(1).var}/${$(2).var}/g' \
                    ${$(1).seg_f} >> ${$(2).seg_f} && \
                cd ${$(2).path} && \
                git add . && \
                git commit . -m "New repo $(2) derived from $(1)." \
            )
            $(call Debug,Edit RC:(${Run_Rc}))
            $(if ${Run_Rc},
              $(call Signal-Error,Error during edit of repo mk file.)
            )
          )
        )
      ,
        $(call Signal-Error,Basis repo $(1) is not a ModFW repo.)
      )
    ,
      $(call Signal-Error,Basis node $(1) is not a repo.)
    )
  )
)
$(call Exit-Macro)
endef

_macro := init-repo
define _help
${_macro}
  Use git to initialize a new repo. A new makefile segment is generated from a
  template and committed to the repo. After initialization the dev needs to
  customize the makefile segment for its intended use.
  Parameters:
    1 = The name of a previously declared repo.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(if $(call is-modfw-repo,$(1)),
  $(call Info,The node $(1) is a ModFW repo -- no init.)
,
  $(if $(call repo-is-declared,$(1)),
    $(call Run,git init -b ${$(1).BRANCH} ${$(1).path})
    $(call Debug,git init return code:(${Run_Rc}))
    $(if ${Run_Rc},
      $(call Debug,Run returned:${Run_Output})
      $(call Signal-Error,Error when initializing repo $(1).)
    ,
      $(call Verbose,Generating makefile segment for repo:$(1))
      $(call Gen-Segment-File,$(1),$(1).path,<edit this description for>:$(1))
      $(call Run, \
        cd ${$(1).path} && \
        git add . && git commit . -m "New component initialized."
      )
      $(if ${Run_Rc},
        $(call Signal-Error,\
          Error when committing $(1) makefile segment.)
      )
    )
  ,
    $(call Signal-Error,Repo $(1) has not been declared.)
  )
)
$(call Exit-Macro)
endef

_macro := branches
define _help
${_macro}
  Run git to get a list of branches for a repo and then display the list.
  NOTE: This is designed to be callable from the make command line using the
  helpers call-<macro> goal.
  For example:
    make ${_macro}.PARMS=<repo> call-${_macro}
  Parameters:
    1 = The repo for which to display the branches.
endef
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(if $(call repo-is-declared,$(1)),
  $(if $(call repo-exists,$(1)),
    $(call Run,cd ${$(1).path} && git branch)
    $(call Info,${Run_Output})
    $(call Exit-Macro)
  ,
    $(call Signal-Error,$(1) is NOT a repo.)
  )
,
  $(call Signal-Error,Repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

_macro := switch-branch
define _help
${_macro}
  Switch a repo to a different branch. This does NOT change the <repo>.BRANCH
  sticky variable.
  NOTE: This is designed to be callable from the make command line using the
  helpers call-<macro> goal.
  For example:
    make ${_macro}.PARMS=<repo>:<branch> call-${_macro}
  Parameters:
    1 = The repo to switch the branch.
    2 = The name of the branch to switch to.
endef
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(if $(call repo-is-declared,$(1)),
  $(if $(call repo-exists,$(1)),
    $(call Run,cd ${$(1).path} && git switch $(2))
    $(call Info,${Run_Output})
    $(call Exit-Macro)
  ,
    $(call Signal-Error,$(1) is NOT a repo.)
  )
,
  $(call Signal-Error,Repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

_macro := new-branch
define _help
${_macro}
  Create a new branch in a repo and switch to the new branch. This does NOT
  change the <repo>.BRANCH sticky variable.
  NOTE: This is designed to be callable from the make command line using the
  helpers call-<macro> goal.
  For example:
    make ${_macro}.PARMS=<repo>:<branch> call-$(_macro)
  Parameters:
    1 = The repo in which to create the new branch.
    2 = The name of the branch to create.
endef
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(if $(call repo-is-declared,$(1)),
  $(if $(call repo-exists,$(1)),
    $(if $(call Confirm,Create branch $(2) in repo $(1)?),
      $(call Run,cd ${$(1).path} && git switch $(2))
      $(call Info,${Run_Output})
    )
  ,
    $(call Signal-Error,$(1) is NOT a repo.)
  )
,
  $(call Signal-Error,Repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

_macro := remove-branch
define _help
${_macro}
  Remove an existing branch from a repo.
  NOTE: This is designed to be callable from the make command line using the
  helpers call-<macro> goal.
  For example:
    make ${_macro}.PARMS=<repo>:<branch> call-$(_macro)
  Parameters:
    1 = The repo to switch the branch.
    2 = The name of the branch to create.
endef
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(if $(call repo-is-declared,$(1)),
  $(if $(call repo-exists,$(1)),
    $(if $(call Confirm,Remove branch $(2) from repo $(1)?),
      $(call Run,cd ${$(1).repo_path} && git branch -d $(2))
      $(call Info,${Run_Output})
    )
  ,
    $(call Signal-Error,$(1) is NOT a repo.)
  )
,
  $(call Signal-Error,Repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

_macro := create-repo
define _help
${_macro}
  Create a new local repo. The new repo can be based on an existing repo. If the
  new repo is based upon an existing repo, clone-basis-to-create-repo is called
  to create the new repo.
  Parameters:
    1 = The name of the new repo.
    2 = The name of the parent node which will contain the new repo.
    3 = Optional basis repo.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2) $(3))
$(if ${$(2).REPO},
  $(if $(call repo-is-declared,$(1)),
    $(call Signal-Error,Repo $(1) has already been declared.)
  ,
    $(call Info,Creating new repo for: $(1))
    $(call declare-repo,$(1),$(2))
    $(if $(3),
      $(call Verbose,Using $(3) as basis for repo $(1).)
      $(call clone-basis-to-create-repo,$(3),$(1))
    ,
      $(call Verbose,Creating repo $(1).)
      $(call init-repo,$(1))
    )
  )
,
  $(call Signal-Error,The new repo has not been defined.)
)
$(call Exit-Macro)
endef

_macro := destroy-repo
define _help
${_macro}
  Remove a repo. This deletes the repo directory. To help avoid accidental
  deletions the action is first confirmed.
  WARNING: Use with care! This can have serious consequences.
  Parameters:
    1 = The name of the repo to remove.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-exists,$(1)),
    $(if $(call is-repo,$(1)),
      $(call destroy-node,$(1),Remove repo:$(1)?)
    ,
      $(call Signal-Error,Node $(1) is not a repo -- not removing node.)
    )
  ,
    $(call Signal-Error,Repo $(1) node does not exist.)
  )
  $(call Exit-Macro)
endef

_macro := use-repo
define _help
${_macro}
  Use a previously declared repo. If the repo doesn't exist locally the repo is
  cloned either from a local repo or from a remote server depending upon
  <2>.URL. Commits to the repo can be pushed to the origin repo. Once the repo
  is in use Use-Segment should be called to load the repo makefile segment. The
  path to the repo is added to the segment search paths to simplify the call to
  Use-Segment. e.g. $$(call Use-Segment,<repo>)
  Parameters:
    1 = <repo>: The name of the repo. This is also the name of the tree node
        for the repo.
    2 = The branch of the repo to use. If this is empty then <repo>.BRANCH is
        used.
  Returns:
    Run_Rc and Run_Output
      See Run (help-helpers).
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))
$(if $(call node-is-declared,$(1)),
  $(if ${(1).SegID},
    $(call Info,Repo $(1) is already in use.)
  ,
    $(if $(wildcard ${$(1).seg_f}),
      $(call Info,Using existing repo: $(1))
    ,
      $(if ${$(1).URL},
        $(call Info,Cloning repo: $(1))
        $(call clone-repo,$(1),$(2))
      ,
        $(call Signal-Error,Repo $(1) is not defined. Use create-new.)
      )
    )
    $(call Add-Segment-Path,${$(1).path})
  )
,
  $(call Signal-Error,The tree node for repo $(1) has not been declared.)
)
$(call Exit-Macro)
endef

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

This segment defines macros for managing ModFW repos. They are not intended to
be called only by the higher level macros (see help-projects, help-kits, and
help-mods).

A ModFW repo contains, at minimum, a makefile segment having the same name as
the repo. The full path to this segment is available in the <repo>.seg_f
attribute.

The repo attributes are:
${help-repo_attributes}

Defines the support macros:
${help-repo-is-declared}

${help-add-repo-class}

${help-declare-repo}

${help-gen-repo-mk}

${help-init-repo}

${help-repo-exists}

${help-is-modfw-repo}

${help-get-repo-url}

${help-get-repo-branch}

${help-clone-repo}

${help-destroy-repo}

${help-clone-basis-to-create-repo}

${help-branches}

${help-switch-branch}

${help-new-branch}

${help-remove-branch}

These are the primary API macros:
${help-create-repo}

${help-use-repo}

Command line goals:
  help-${SegUN}   Display this help.
endef
${__h} := ${__help}
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
