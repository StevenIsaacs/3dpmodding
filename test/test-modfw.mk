#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Test the ModFW features.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----

TESTING := 1

_macro := report-comp
define _help
${_macro}
  Display component attributes.
  Parameters:
    1 = The name of the component.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,report-comp)
  $(call Display-Vars,\
    $(1)_seg \
    $(1)_dir \
    $(1)_path \
    $(1)_mk \
    $(1)_var \
    comps \
  )
  $(call Exit-Macro)
endef

_macro := verify-comp-vars
define _help
${_macro}
  Verify component variables.
  Parameters:
    1 = The name of the component to verify.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,verify-comp-vars)
  $(call Expect-Vars,\
    $(2)_seg:$(2) \
    $(2)_dir:$(2) \
    $(2)_path:$(1)/$(2) \
    $(2)_mk:$(1)/$(2)/$(2).mk \
    $(2)_var:_$(2) \
  )
  $(call Exit-Macro)
endef

_macro := report-repo
define _help
${_macro}
  Display repo attributes.
  Parameters:
    1 = The name of the repo.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,report-repo)
  $(call report-comp,$(1))
  $(call Display-Vars,\
    $(1)_SERVER \
    $(1)_ACCOUNT \
    $(1)_REPO \
    $(1)_URL \
    $(1)_BRANCH \
    $(1)_repo_class \
    $(1)_repo_dir \
    $(1)_repo_path \
    $(1)_repo_dep \
    $(1)_repo_mk \
    repos \
  )
  $(Exit-Macro)
endef

_macro := verify-repo-vars
define _help
${_macro}
  Verify repo variables.
  Parameters:
    1 = The repo class.
    2 = The name of the repo to verify.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,verify-repo-vars)
  $(call verify-comp-vars,$(1),$(2))
  $(call Expect-Vars,\
    $(2)_repo_dir:${$(2)_dir} \
    $(2)_repo_path:${$(2)_path} \
    $(2)_repo_dep:${$(2)_repo_path}/.git \
    $(2)_repo_mk:${$(2)_repo_path}/$(2).mk \
  )
  $(call Exit-Macro)
endef

_macro := report-mod
define _help
${_macro}
  Display mod attributes.
    1 = The name of the mod.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,report-mod)

  $(call Exit-Macro)
endef

_macro := verify-mod-vars
define _help
${_macro}
  Verify the mod variables.
  Parameters:
    1 = The name of the mod.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,verify-mod-vars)

  $(call Exit-Macro)
endef

_macro := verify-mod-contents
define _help
${_macro}
  Verify the required contents of a mod.
  Parameters:
    1 = The name of the mod.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,verify-mod)

  $(call Exit-Macro)
endef

# Where test data is placed.
$(call Overridable,TESTING_DIR,testing)
$(call Overridable,TESTING_PATH,${WorkingPath}/${TESTING_DIR})

# Reroute all output to the testing directory.
STICKY_PATH := ${TESTING_PATH}/sticky
BUILD_DIR := build
BUILD_PATH := ${TESTING_PATH}/${BUILD_DIR}
STAGING_DIR := staging
STAGING_PATH := ${TESTING_PATH}/${STAGING_DIR}
TOOLS_DIR := tools
TOOLS_PATH := ${TESTING_PATH}/${TOOLS_DIR}
BIN_DIR := bin
BIN_PATH := ${TESTING_PATH}/${BIN_DIR}
DOWNLOADS_DIR := downloads
DOWNLOADS_PATH := ${TESTING_PATH}/${DOWNLOADS_DIR}
COMPS_DIR := comps
COMPS_PATH := ${TESTING_PATH}/$(COMPS_DIR)
REPOS_DIR := repos
REPOS_PATH := ${TESTING_PATH}/$(REPOS_DIR)
PROJECTS_DIR := projects
PROJECTS_PATH := ${TESTING_PATH}/${PROJECTS_DIR}
KITS_DIR := kits
KITS_PATH := ${TESTING_PATH}/${KITS_DIR}

# This is also loaded in makefile and should trigger a segment conflict at
# that time.
$(call Use-Segment,config)

# Search path for loading segments. This can be extended by kits and mods.
$(call Add-Segment-Path,$(MK_PATH))

$(call Use-Segment,helpers/test/test-helpers)

# These are also loaded in makefile which should trigger a segment conflict
# error at that time.
$(call Use-Segment,comp-macros)
$(call Use-Segment,repo-macros)
$(call Use-Segment,mod-macros)

$(call Next-Suite,Testing configuration.)
$(call Display-Vars,\
  STICKY_PATH \
  TESTING \
  DEBUG \
  TESTING_DIR TESTING_PATH \
  BUILD_DIR BUILD_PATH \
  STAGING_DIR STAGING_PATH \
  TOOLS_DIR TOOLS_PATH \
  BIN_DIR BIN_PATH \
  DOWNLOADS_DIR DOWNLOADS_PATH \
  COMPS_DIR COMPS_PATH \
  REPOS_DIR REPOS_PATH \
  PROJECTS_DIR PROJECTS_PATH \
  KITS_DIR KITS_PATH \
)

_macro := verify-repo
define _help
${_macro}
  Verify the required contents of a repo.
  1 = The name of the repo to verify.
  2 = If not empty then verify the setup as well.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,verify-repo)
  $(call Test-Info,Verifying repo:$(1))
  $(if $$(call is-repo-dir,$(1)),
    $(call PASS,Repo $(1) is a git repo.)
  ,
    $(call FAIL,Repo $(1) is NOT a git repo.)
  )
  $(eval _u := $(call get-repo-url,$(1)))
  $(call Debug,get-repo-url returned:(${_u}))
  $(call Debug,$(1)_REPO = (${$(1)_REPO}) LOCAL_REPO = (${LOCAL_REPO}))
  $(if $(filter ${$(1)_REPO},${LOCAL_REPO}),
    $(call Expect-String,\
      ${Run_Output},fatal: No remote configured to list refs from. 128)
  ,
    $(call Expect-Vars,$(1)_REPO:${_u})
  )
  $(eval _b := $(call get-repo-branch,$(1)))
  $(call Debug,get-repo-branch returned:${_b})
  $(call Debug,Return code:(${Run_Rc}))
  $(if ${Run_Rc},
    $(call FAIL,Could not retrieve the active branch.)
  ,
    $(call Debug,Branch:${_b})
    $(call Expect-Vars,$(1)_BRANCH:${_b})
  )
  $(if $(2),
    $(call Debug,Verifying repo $(1) setup.)
    $(if $(call repo-is-setup,$(1)),
      $(call PASS,Repo $(1) has been setup.)
    ,
      $(call FAIL,Repo $(1) has not been setup.)
    )
  )
  $(call Exit-Macro)
endef

_macro := verify-declare
define _help
${_macro}
  Test declaration of components. These can be a <comp>, <repo>, <kit>,
  or <mod>.
  Parameters:
    1 = The type of component:
      comp = A general component.
      repo = A repo.
      project = A project.
      kit  = A kit.
      mod  = A mod.
    2 = The path to the component.
    3 = The name of the component.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2) $(3))
  $(call Test-Info,Class:$(1) Name:$(3))
  $(call declare-$(1),$(2),$(3))
  $(call report-$(1),$(3))
  $(call verify-$(1)-vars,$(2),$(3))
  $(call Test-Info,Expect an already declared error.)
  $(call Expect-Error,Component $(3) has already been declared.)
  $(call declare-$(1),$(2),$(3))
  $(call Verify-Error)
  $(call Exit-Macro)
endef

#+++++++++++ Test Suites +++++++++++++
ifneq ($(call Is-Goal,test-comps),)
  $(call Next-Suite,test-comps)

  $(call Test-Info,Testing:declare-comp)
  $(call verify-declare,comp,${COMPS_PATH},comp$(SuiteID))

test-comps: display-errors display-messages

endif

ifneq ($(call Is-Goal,test-repos),)
  $(call Next-Suite,test-repos)

  $(call Test-Info,Testing:declare-repo)
  $(call verify-declare,repo,${REPOS_PATH},repo$(SuiteID))
  $(call Expect_Vars,\
    repo${SuiteID}_REPO:${LOCAL_REPO}\
    repo${SuiteID}_BRANCH:${DEFAULT_BRANCH}\
  )
  $(call Debug,Repo dep:(${repo${SuiteID}_repo_dep}))
  $(call Debug,Repo path:(${repo${SuiteID}_repo_path}))
  $(call remove-repo,repo${SuiteID},Warn)
  ifneq ($(wildcard ${repo${SuiteID}_repo_path}),)
    $(call FAIL,Repo repo${SuiteID} was NOT removed.)
  else
    $(call PASS,Repo repo${SuiteID} was removed.)
  endif
  $(call init-repo,repo${SuiteID})
  ifneq ($(call is-repo-dir,repo${SuiteID}x),)
    $(call FAIL,is-repo-dir:repo${SuiteID}x:returned non-empty value.)
  else
    $(call PASS,is-repo-dir:repo${SuiteID}x:returned empty value.)
  endif
  ifneq ($(call is-repo-dir,repo${SuiteID}),)
    $(call PASS,is-repo-dir:repo${SuiteID}:returned non-empty value.)
  else
    $(call FAIL,is-repo-dir:repo${SuiteID}:returned empty value.)
  endif
  _r := $(call is-repo-dir,repo${SuiteID}x)
  $(call Debug,is-repo-dir repo${SuiteID}x returned: ${_r})
  _r := $(call is-repo-dir,repo${SuiteID})
  $(call Debug,is-repo-dir repo${SuiteID} returned: ${_r})
  ifneq ($(call is-repo-dir,repo${SuiteID}),)
    $(call PASS,Repo repo${SuiteID} was initialized.)
  else
    $(call FAIL,Repo repo${SuiteID} was NOT initialized.)
  endif
  $(call verify-repo,repo${SuiteID})

  $(call remove-repo,repo${SuiteID},Warn)
$(call Enable-Single-Step)
  $(call setup-repo,init,repo${SuiteID},test)
  $(call verify-repo,repo${SuiteID},setup)

  $(call Test-Info,Cloning repo${SuiteID} to local-${SuiteID}.)
  $(eval local-${SuiteID}_REPO := ${repo${SuiteID}_repo_path})
  $(call declare-repo,${REPOS_PATH},local-${SuiteID})
  $(call setup-repo,clone,local-${SuiteID})
  $(call verify-repo,local-${SuiteID},setup)

  $(call Test-Info,Cloning modfw-toolkits to remote-${SuiteID}.)
  $(eval remote-${SuiteID}_REPO := \
    git@github.com:StevenIsaacs/modfw-toolkits.git)
  $(call declare-repo,${REPOS_PATH},remote-${SuiteID})
  $(call setup-repo,clone,remote-${SuiteID})
  $(call verify-repo,remote-${SuiteID},setup)

  $(call Test-Info,Using local basis for new repo.)
  $(eval local-${SuiteID}-c_REPO := ${local-${SuiteID}_REPO})
  $(call declare-repo,${REPOS_PATH},local-${SuiteID}-c)
  $(call clone-basis-to-new-repo,repo${SuiteID},local-${SuiteID}-c)

  $(call Test-Info,Using remote basis for new repo.)
  $(eval remote-${SuiteID}-c_REPO := ${remote-${SuiteID}_REPO})
  $(call declare-repo,${REPOS_PATH},remote-${SuiteID}-c)
  $(call clone-basis-to-new-repo,remote-${SuiteID},remote-${SuiteID}-c)
$(call Disable-Single-Step)

  $(call Test-Info,removing local and remote repos.)
  $(call remove-repo,local-${SuiteID},Test-Info)
  $(call remove-repo,remote-${SuiteID},Test-Info)
  $(call remove-repo,local-${SuiteID}-c,Test-Info)
  $(call remove-repo,remote-${SuiteID}-c,Test-Info)

test-repos: display-errors display-messages

endif

ifneq ($(call Is-Goal,test-projects),)
  # Basic vars for testing projects.
  PROJECT := prj$(SuiteID)
  PROJECT_REPO := local
  PROJECT_BRANCH := test

  # This will load kits and mods too.
  ifeq (${projectsSeg},)
    $(call Use-Segment,projects)
  endif

  $(call Next-Suite,declare-project)

  $(call Next-Suite,init-project)

  $(call Next-Suite,clone-project)

  $(call Next-Suite,setup-project)

  $(call Next-Suite,clone-basis-to-new-project)

  $(call Next-Suite,use-project)

  $(call Next-Suite,dup-project)

  $(call Next-Suite,create-project)

  $(call Next-Suite,new-project)

  $(call Next-Suite,activate-project)

test-projects: display-errors display-messages

endif

ifneq ($(call Is-Goal,test-kits),)

  ifeq (${projectsSeg},)
    $(call Use-Segment,projects)
  endif

  $(call Next-Suite,declare-kit)

  $(call Next-Suite,init-kit)

  $(call Next-Suite,clone-kit)

  $(call Next-Suite,setup-kit)

  $(call Next-Suite,clone-basis-to-new-kit)

  $(call Next-Suite,use-kit)

  $(call Next-Suite,dup-kit)

  $(call Next-Suite,create-kit)

  $(call Next-Suite,new-kit)

  $(call Next-Suite,activate-kit)

test-kits: display-errors display-messages

endif

ifneq ($(call Is-Goal,test-mods),)

  ifeq (${projectsSeg},)
    $(call Use-Segment,projects)
  endif

  $(call Test-Info,Testing mods.)

  $(call Next-Suite,declare-mod)

  $(call Next-Suite,init-mod)

  $(call Next-Suite,copy-mod)

  $(call Next-Suite,setup-mod)

  $(call Next-Suite,copy-basis-to-new-mod)

  $(call Next-Suite,use-mod)

  $(call Next-Suite,dup-mod)

  $(call Next-Suite,create-mod)

  $(call Next-Suite,new-mod)

  $(call Next-Suite,activate-mod)

test-mods: display-errors display-messages

endif

$(call Next-Suite,\
  Expect already included config${Comma} comp-macros${Comma} and repo-macros.)

$(call Report-Test-Summary)

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

Macros, goals and recipes to test ModFW makefile segments. This is intended to
be run using the PREPEND command line variable (see help).

Defines macros:
${help-report-comp}

${help-verify-comp-vars}

${help-verify-declare}

${help-report-repo}

${help-verify-repo-vars}

${help-verify-repo}

${help-report-mod}

${help-verify-mod-vars}

${help-verify-mod-contents}

Defines:
  TESTING = ${TESTING}
    Shows test mode is active. The projects makefile segment will not be
    loaded in makefile as a result.
  DEBUG = ${DEBUG}
    Debug mode is typically enabled when testing.

Command line goals:
  help-${Seg}   Display this help.
  test-comps    Test component declaration.
  test-projects Test project, kit, and mod macros.

endef
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
