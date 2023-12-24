#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Macros to support ModFW repos.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----
$(call Use-Segment,comp-macros)

repos :=
repo_goals :=
repo_classes :=

_macro := add-repo-class
define _help
${_macro}
  Add a repo container name. A repo container MUST be declared before a repo of that
  container can be declared. A container of the same name is also defined.
  Parameters:
    1 = The name of the container for the repo (<repo>).
    2 = The path to the directory where repos of that container are stored.
        The repos are stored in a subdirectory named using the container name.
  Defines:
    repo_classes
      The container name is added to this list.
    <repo>s_name
      The name of the directory where the container files are stored.
      The name of the directory is the plural form of <repo> (an s is
      appended to the name).
    <repo>s_path
      The full path to the component directory.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))
$(call declare-container,$(1),$(2))
$(eval repo_classes += $(1))
$(eval $(1)s_repo_name := $(1)s)
$(eval $(1)s_repo_path := $(2)/${$(1)s_name})
$(call Exit-Macro)
endef

_macro := gen-branching-goals
define _help
${_macro}
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
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))
$(call Gen-Command-Goal,$(1)-branches,\
  > cd ${$(1)_repo_path} && git branch)

$(call Gen-Command-Goal,$(1)-switch-branch,\
  > cd ${$(1)_repo_path} && git switch ${$(1)_BRANCH})

$(call Gen-Command-Goal,$(1)-new-branch,\
  > cd ${$(1)_repo_path} && \
    git branch ${$(1)_BRANCH},\
  Create branch ${$(1)_BRANCH} in $(1)?)

$(call Gen-Command-Goal,$(1)-remove-branch,\
  > cd ${$(1)_repo_path} && \
    git branch -d ${$(1)_BRANCH},\
  Delete branch ${$(1)_BRANCH} from $(1)?)
$(call Exit-Macro)
endef

_macro := repo-is-declared
define _help
${_macro}
  Returns a non-empty value if the repo has been declared.
endef
help-${_macro} := $(call _help)
${_macro} = $(if $(filter $(1),${repos}),1)

_macro := is-repo
define _help
${_macro}
  This returns a non-empty value if the repo exists.
  Parameters:
    1 = The name of a previously declared repo.
endef
help-${_macro} := $(call _help)
${_macro} = $(if $(wildcard ${$(1)_repo_dep}/HEAD),1)

_macro := declare-repo
define _help
${_macro}
  Define the attributes of a component repo. A repo must be declared before
  it can be used, created or cloned. A component of the same name is first
  declared.
  NOTE: See help-<repo> for more information.
  Parameters:
    1 = The repo <ctnr> must be one of: ${repo_classes}.
    2 = The name of the repo and its corresponding component (<repo>).
        NOTE: This can be different than the sticky variable.
  Defines variables:
    Sticky variables:
    <repo>_SERVER
      Default: <ctnr>_SERVER
      The repo server.
    <repo>_ACCOUNT
      Default: <ctnr>_ACCOUNT
      The account on the server.
    <repo>_REPO
      Default: <ctnr>_REPO
      The repo on the server.
    <repo>_URL
      Default: <repo>_SERVER<repo>_ACCOUNT/<repo>_REPO
      The full URL for the remote repo or full PATH for a local repo.
    <repo>_BRANCH     The branch to switch to.
      Default: <ctnr>_BRANCH
    Attributes:
    <repo>_repo_class The container of the repo.
    <repo>_repo_name   The name of the repo directory which is equal to <comp>.
    <repo>_repo_path  The full path to the repo. This is a combination of
                      <ctnr>S_PATH and the <repo> name.
    <repo>_repo_dep   A dependency for the repo. This uses the .git directory in
                      the repo directory as the dependency.
    repos             Adds the repo to the list of repos.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))
$(if $(call repo-is-declared,$(2)),
  $(call Warn,Repo $(2) has already been declared.)
,
  $(if $(call Must-Be-One-Of,$(1),${repo_classes}),
    $(call Verbose,Declaring repo $(2).)
    $(call declare-comp,${$(1)S_PATH},$(2))

    $(call Sticky,$(2)_SERVER=${$(2)_SERVER},${$(1)_SERVER})
    $(call Sticky,$(2)_ACCOUNT=${$(2)_ACCOUNT},${$(1)_ACCOUNT})
    $(call Sticky,$(2)_REPO=${$(2)_REPO},${$(1)})
    $(call Sticky,\
      $(2)_URL=${$(2)_URL},${$(2)_SERVER}${$(2)_ACCOUNT}/${$(2)_REPO})
    $(call Sticky,$(2)_BRANCH=${$(2)_BRANCH},${$(1)_BRANCH})

    $(eval $(2)_repo_class := $(1))
    $(eval $(2)_repo_name := ${$(2)_name})
    $(eval $(2)_repo_path := ${$(2)_path})
    $(eval $(2)_repo_dep := ${$(2)_repo_path}/.git)
    $(eval $(2)_repo_mk := ${$(2)_repo_path}/$(2).mk)
    $(eval  repos += $(2))
  ,
    $(call Signal-Error,The repo container must be one of ${repo_classes}.)
  )
)
$(call Exit-Macro)

endef

_macro := init-repo
define _help
${_macro}
  Use git to initialize a new repo.
  Parameters:
    1 = The name of a previously declared repo to init.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(if $(wildcard ${$(1)_repo_dep}),
  $(call Warn,The repo for $(1) exists -- no init.)
,
  $(call Run,git init -b ${$(1)_BRANCH} ${$(1)_repo_path})
  $(call Debug,git init return code:(${Run_Rc}))
  $(if ${Run_Rc},
    $(call Debug,Run returned:${Run_Output})
    $(call Signal-Error,Error when initializing repo $(1).)
  )
)
$(call Exit-Macro)
endef

_macro := repo-is-setup
define _help
${_macro}
  Returns a non-empty value if the repo has been setup.
  Parameters:
    1 = The name of an existing and previously declared repo.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),$(1))
  $(if $(and $$(call is-comp-dir,$(1)),$$(call is-repo,$(1))),
    $(call Run,grep $(1) ${$(1)_repo_mk})
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
  $(call Run,cd ${$(1)_repo_path} && git ls-remote --get-url)
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
  $(call Run,cd ${$(1)_repo_path} && git symbolic-ref --short HEAD)
  $(if ${Run_Rc},
    $(call Signal-Error,Could not get branch from ${$(1)_repo})
  ,
    $(word 1,${Run_Output})
  )
  $(call Exit-Macro)
)
endef

_macro := clone-repo
define _help
${_macro}
  Use git to clone either a local or remote repo to a new repo and switch to
  the specified branch.
  Parameters:
    1 = The name of an existing and previously declared repo.
  Uses:
    <1>_REPO
      The URL of the repo to clone from.
    <1>_BRANCH
      The branch to switch to.
  Returns:
    Run_Rc and Run_Output
      See Run (help-helpers).
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(if $(wildcard ${$(1)_repo_dep}),
  $(call Verbose,The repo for $(1) exists -- no init.)
,
  $(call Run, \
    mkdir -p ${$(1)_repo_path} && \
    git clone ${$(1)_URL} ${$(1)_repo_path} && \
    cd ${$(1)_repo_path} && \
    git switch ${$(1)_BRANCH}\
  )
)
$(call Exit-Macro)
endef

_macro := remove-repo
define _help
${_macro}
  Remove a repo. This deletes the repo directory. To help mitigate accidental
  deletions the action is first confirmed.
  WARNING: Use with care! This can have serious consequences.
  Parameters:
    1 = The name of the repo to remove.
    2 = Optional error severity level. This is the name of the macro to call
        to report an error after attempting to remove the repo directory. This
        must be one of Info, Warn, or Signal-Error.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2))
  $(if $(wildcard ${$(1)_repo_path}),
    $(if $(call Confirm,Remove ${$(1)_repo_path}?,y),
      $(call Run,rm -rf ${$(1)_repo_path})
      $(call Debug,Returned:${Run_Output})
      $(if ${Run_Rc},
        $(call Signal-Error,Removing directory failed.)
      )
    ,
      $(call Info,Declined -- not removing $(1).)
    )
  ,
    $(eval _expect := Repo $(1) directory does not exist.)
    $(call Debug,Error action is:$(2))
    $(if $(2),
      $(call $(2),${_expect})
    ,
      $(call Signal-Error,${_expect})
    )
  )
  $(call Exit-Macro)
endef

define _repo_seg_mk
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Makefile segment for $(1): $(2)
#----------------------------------------------------------------------------
# The prefix $(2) must be unique for all files.
# The format of all the $(2) based names is required.
# +++++
# Preamble
$.ifndef $(2)SegId
$$(call Enter-Segment)
# -----

$$(call Info,New segment: Add variables, macros, goals, and recipes here.)

# The command line goal for the segment.
$${Seg}: $${SegF}

# +++++
# Postamble
# Define help only if needed.
$.ifneq ($$(call Is-Goal,help-$${Seg}),)
$.define help_$${SegV}_msg
Make segment: $${Seg}.mk

# Place overview here.

# Add help messages here.

Attributes:
  Sticky variables:
    $${Seg}_SERVER := $${$${Seg}_SERVER}
      The server on which the repo is maintained. NOTE: If this is equal to
      ${LOCAL_REPO} then there is no remote server for this repo.
    $${Seg}_ACCOUNT := $${$${Seg}_ACCOUNT}
      The account on the server.
    $${Seg}_REPO := $${$${Seg}_REPO}
      The name of the repo on the server.
    $${Seg}_URL := $${$${Seg}_URL}
      The full URL for cloning the repo from either a local repo or a remote
      server.
    $${Seg}_BRANCH := $${$${Seg}_BRANCH}
      The branch to switch to after cloning the repo.
  Defined variables:
    $${Seg}_repo_class := $${$${Seg}_repo_class}
      The container associated with this repo.
      NOTE: This must be equal to one of: ${repo_classes}
    $${Seg}_repo_name := $${$${Seg}_repo_name}
      The name of the directory where the repo is stored locally. This is the
      <comp> name for the repo which can be different than $${Seg}_REPO.
    $${Seg}_repo_path := $${$${Seg}_repo_path}
      The full path to the repo directory.
    $${Seg}_repo_dep := $${$${Seg}_repo_dep}
      A dependency for the repo. This uses the .git directory

Defines:
  # Describe each variable or macro.

Command line goals:
  $${Seg}
    Build this component.
  # Describe additional goals provided by the segment.
  help-$${Seg}
    Display this help.

$.endef
$.endif # help goal message.

$$(call Exit-Segment)
$.else # $$(call Last-Segment-Basename)SegId exists
$$(call Check-Segment-Conflicts)
$.endif # $$(call Last-Segment-Basename)SegId
# -----

endef

_macro := gen-repo-mk
define _help
${_macro}
  Uses _repo_seg_mk to generate a makefile segment for the repo including a
  help section which will display the repo attributes.
  Parameters:
    1 = The repo class.
    2 = The name of a previously declared repo to add the makefile segment to.
  For example:
  $$(call gen-repo-mk,PROJECT,a-repo)
  generates:
$(call _repo_seg_mk,PROJECT,a-repo)
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))
$(file >${$(2)_repo_mk},$(call _repo_seg_mk,$(1),$(2)))
$(call Exit-Macro)
endef

_macro := setup-repo
define _help
${_macro}
  Uses gen-repo-mk to generate a makefile segment for the repo using the
  helpers template (see help-helpers Gen-Segment-File) and use git to commit
  add and commit the file to the repo.
  NOTE: This generates a template only. The dev expected to modify the file to
  suite the project or kit.
  Parameters:
    1 = The action to perform -- init or clone.
    2 = The repo class.
    3 = The name of a previously declared repo to add the makefile segment to.
  Returns:
    Run_Rc and Run_Output
      See Run (help-helpers).
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2) $(3))
$(call Verbose,Performing $(1) for repo $(2):$(3).)
$(if $(filter $(1),init clone),
  $(eval repo_goals += ${$(3)_repo_mk})
  $(call $(1)-repo,$(3))
  $(if $(call repo-is-setup,$(3)),
    $(call Verbose,Using existing repo makefile segment.)
  ,
    $(call Verbose,Generating repo makefile segment.)
    $(call Verbose,Generating segment for class:$(2))
    $(call gen-repo-mk,$(2),$(3))
    $(call Run, \
      cd $(dir ${$(3)_repo_mk}) && \
      git add . && git commit . -m "New component initialized."
    )
    $(if ${Run_Rc},
      $(call Signal-Error,\
        Error when committing $(3) makefile segment.)
    )
  )
,
  $(call Signal-Error,\
    Parameter 1=$(1) but must be either init or clone.)
)
$(call Exit-Macro)
endef

_macro := clone-basis-to-new-repo
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
$(eval repo_goals += ${$(2)_repo_mk})
$(if $(wildcard ${$(2)_repo_mk}),
  $(call Warn,Using existing repo $(2).)
,
  $(if $(wildcard ${$(2)_repo_dep}),
    $(call Warn,Repo $(2) exists -- adding makefile segment.)
  ,
    $(if $(wildcard ${$(1)_repo_dep}),
      $(if $(wildcard ${$(1)_repo_mk}),
        $(if $(call Require,$(2)_URL),
          $(call Signal-Error,URL for $(2) is not defined.)
        ,
          $(call clone-repo,$(2))
          $(call Run, \
            cd ${$(2)_repo_path} && git remote remove origin \
          )
          $(call Debug,Git RC:(${Run_Rc}))
          $(if ${Run_Rc},
            $(call Signal-Error,Error cloning basis repo.)
          ,
            $(call Verbose,Editing:${$(2)_repo_mk})
            $(call Run, \
                echo "# Derived from basis - $(1)" > ${$(2)_repo_mk} &&\
                sed \
                    -e 's/$(1)/$(2)/g' \
                    -e 's/${$(1)_var}/${$(2)_var}/g' \
                    ${$(1)_repo_mk} >> ${$(2)_repo_mk} && \
                cd ${$(2)_repo_path} && \
                git add . && \
                git commit . -m "New component derived from $(2)." \
            )
            $(call Debug,Edit RC:(${Run_Rc}))
            $(if ${Run_Rc},
              $(call Signal-Error,Error during edit of repo mk file.)
            )
          )
        )
      ,
        $(call Signal-Error,Basis repo is not a ModFW repo.)
      )
    ,
      $(call Signal-Error,Basis repo $(1) does not exist.)
    )
  )
)
$(call Exit-Macro)
endef

_macro := new-repo
define _help
${_macro}
  Create a new local repo for a project or a kit. This can be based on an
  existing repo. This is called when NEW_<ctnr> has been defined on the
  command line. This is intended to be called from activate-repo. If the
  new repo is based (cloned from) upon an existing repo clone-basis-to-new-repo
  is called to create the new repo.
  Parameters:
    1 = Repo <ctnr>: PROJECT or KIT
    2 = The component name (<comp>) for the repo. This is used to name the repo
        directory and associated variables.
    3 = Optional basis repo.
  Defines:
    <2>_SERVER
    Default: <ctnr>_SERVER
      The server hosting the repo. If this equals ${LOCAL_REPO} then the
      <ctnr>_PATH is used and <2>_ACCOUNT is ignored.
    <2>_ACCOUNT
    Default: <ctnr>_ACCOUNT
      The account on the server.
    <2>_REPO
    Default: <ctnr>_REPO
      The name of the directory in which the repo is stored. This can be
      different than the <comp> (<2>). Which allows multiple copies of the
      same repo which may be handy for parallel versions.
    <2>_URL
    Default: ${$(1)_SERVER}${$(1)_ACCOUNT}/${$(1)_REPO}
      The URL for the new repo. If the repo is local only then this is the
      full path to the repo.
    <2>_BRANCH
    Default: ${DEFAULT_BRANCH}
      The initial master branch for the new repo.
  Uses:
    If <3> is non-empty then:
    <3>_SERVER
    <3>_ACCOUNT
    <3>_URL
    <3>_BRANCH
      This is the name of the component for which the repo is created.
      e.g make NEW_PROJECT=<project> or make NEW_KIT=<kit>
    BASIS_<ctnr> If not empty clones an existing repo to a new repo.
      i.e BASIS_<ctnr>=<new>
      e.g. make NEW_PROJECT=<project> BASIS_PROJECT=<basis>
    <new>_REPO=<url>
      The URL for the new repo. If undefined this defaults to
      DEFAULT_<CLASS>_REPO.
    <new>_BRANCH=<branch>
      The default branch to specify when creating the new repo. This
      defaults to DEFAULT_<ctnr>_BRANCH.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2) $(3))
$(if ${$(2)_REPO},
  $(if $(call comp-is-declared,$(2)),
    $(call Signal-Error,Repo $(2) has already been declared.)
  ,
    $(call Info,Creating new repo for: $(2))
    $(call declare-repo,$(1),$(2))
    $(if $(3),
      $(call Verbose,Using $(2) as basis for repo $(3).)
      $(call clone-basis-to-new-repo,$(2),$(3))
    ,
      $(call Verbose,Creating repo $(2).)
      $(call setup-repo,init,$(1),$(2))
    )
  )
,
  $(call Signal-Error,The new repo has not been defined.)
)
$(call Exit-Macro)
endef

_macro := use-repo
define _help
${_macro}
  Use a project or kit repo. If the repo doesn't exist locally the repo is
  cloned either from a local repo or from a remote server depending upon
  <2>_REPO. This is designed to be called by other components be they projects,
  kits, or mods. NOTE: In this case commits to this repo can be pushed to the
  origin repo.
  Parameters:
    1 = The destination path to the repo clone.
    2 = The name of the component (<comp>) corresponding to the repo. This is
        used to name the repo directory and associated variables.
  Returns:
    Run_Rc and Run_Output
      See Run (help-helpers).
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))
$(if $(1),
  $(if $(2),
    $(if ${(2)_seg},
      $(call Info,Component $(2) is already in use.)
    ,
      $(call declare-repo,$(1),$(2))
      $(call Add-Segment-Path,${$(2)_repo_path})
      $(if $(wildcard ${$(2)_repo_mk}),
        $(call Info,Using repo: $(2))
      ,
        $(if ${$(2)_REPO},
          $(call Info,Cloning repo: $(2))
          $(call clone-repo,$(2))
        ,
          $(call Signal-Error,\
            Repo $(2) is not defined. Use create-new.)
        )
      )
      $(call gen-branching-goals,$(2),)
      $(call Use-Segment,$(2))
    )
  )
,
  $(call Signal-Error,The repo path has not been specified.)
)
$(call Exit-Macro)
endef

_macro := activate-repo
define _help
${_macro}
  Activate a project or kit repo (<comp>) as specified by the <ctnr> variable.
  If the repo has not been installed then it is cloned from an existing repo.
  The existing repo can be either local or remote. In either case commits to
  the active repo can be pushed to the original repo.
  NOTE: Only one PROJECT and one KIT can be active at a time.
  Parameters:
    1 = Repo <ctnr>: PROJECT or KIT
  Uses:
    <ctnr>       The container variable (i.e. PROJECT or KIT) specifying which
                  repo (<comp>) is intended to be the active repo.
    <ctnr>S_PATH The path to the directory where the <ctnr> repos are stored.
                  NOTE: Only repos should exist in this directory. Directories
                  that are not repos will be confused with repos and could
                  produce unexpected results.
    <comp>_REPO     The remote repo to clone if the component exist locally.
    <comp>_BRANCH   The branch to switch to after cloning the repo.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(eval _class := $(call To-Lower,$(1)))
$(call Sticky,$(1))

$(if $(call Require,$(1)),
  $(call Signal-Error,$(1) has not been specified -- not activating.)
,
  $(call Sticky,${$(1)}_REPO)
  $(call Sticky,${$(1)}_BRANCH,${DEFAULT_BRANCH})
  $(if $(call Require,${$(1)}_REPO),
    $(call Signal-Error,$(1)_REPO has not been specified -- not activating.)
  ,
    $(call Attention,Using branch:${$(1)_BRANCH})
    $(call use-repo,${$(1)S_PATH},${$(1)})
  )
)
$(call Exit-Macro)
endef

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help-${Seg}
Make segment: ${Seg}.mk

This segment defines macros for managing ModFW repos. They are not intended to
be called only by the higher level macros (see help-projects, help-kits, and
help-mods).

Defines the support macros:
${help-gen-branching-goals}

${help-repo-is-declared}

${help-add-repo-class}

${help-declare-repo}

${help-init-repo}

${help-repo-is-setup}

${help-get-repo-url}

${help-get-repo-branch}

${help-clone-repo}

${help-remove-repo}

${help-gen-repo-mk}

${help-setup-repo}

${help-clone-basis-to-new-repo}

These are the primary API macros:
${help-new-repo}

${help-use-repo}

${help-activate-repo}

Command line goals:
  help-${Seg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
