#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW - repo test suite.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,ModFW - repo test suite.)
# -----
define _help
Make segment: ${Seg}.mk

This test suite verifies the macros related to managing repos.

endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Add-Help-Section,verifiers,Macros to verify repo features.)

_macro := verify-repo-not-declared
define _help
${_macro}
  Verify a repo is not declared and its attributes are not defined.
  Parameters:
    1 = The repo to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared,$(1)),
    $(call FAIL,Node $(1) should not be declared.)
  ,
    $(call PASS,Node $(1) is not declared.)
  )
  $(if $(call repo-is-declared,$(1)),
    $(call FAIL,Repo $(1) should not be declared.)
  ,
    $(call PASS,Repo $(1) is not declared.)
  )
  $(foreach _a,${repo_attributes},
    $(if $(call Is-Not-Defined,${_a}),
      $(call PASS,Repo attribute ${_a} is not defined.)
    ,
      $(call FAIL,Repo attribute ${_a} is defined.)
    )
  )
  $(call Exit-Macro)
endef

_macro := verify-repo-is-declared
define _help
${_macro}
  Verify that a repo is declared and its attributes have been defined.
  Parameters:
    1 = The repo to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared,$(1)),
    $(call PASS,Node $(1) is declared.)
  ,
    $(call FAIL,Node $(1) is not be declared.)
  )
  $(if $(call repo-is-declared,$(1)),
    $(call PASS,Repo $(1) is declared.)
  ,
    $(call FAIL,Repo $(1) is not be declared.)
  )
  $(foreach _a,${repo_attributes},
    $(if $(call Is-Not-Defined,${_a}),
      $(call FAIL,Repo attribute ${_a} is not defined.)
    ,
      $(call PASS,Repo attribute ${_a} is defined.)
    )
  )
  $(call Exit-Macro)
endef

_macro := verify-repo-exists
define _help
${_macro}
  Verify a node exists and contains a git repo.
  The repo must have been previously declared.
  Parameters:
    1 = The node to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call verify-repo-is-declared,$(1))
  $(if $(call node-exists,$(1)),
    $(call PASS,Node for repo $(1) exists.)
    $(if $(call repo-exists,$(1)),
      $(call PASS,Node $(1) contains a git repo.)
    ,
      $(call FAIL,Node $(1) path does not does not contain a git repo.)
    )
  ,
    $(call FAIL,Node for repo $(1) does not exist.)
  )
  $(call Exit-Macro)
endef

_macro := verify-repo-does-not-exist
define _help
${_macro}
  Verify a node exists but does not contain a git repo.
  The node must have been previously declared.
  Parameters:
    1 = The node to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call verify-repo-is-declared,$(1))
  $(if $(call node-exists,$(1)),
    $(call PASS,Node for repo $(1) exists.)
  ,
    $(call FAIL,Node for repo $(1) does not exist.)
  )
  $(if $(call repo-exists,$(1)),
    $(call FAIL,Node $(1) contains a git repo and should not.)
  ,
    $(call PASS,Node $(1) path does not does not contain a git repo.)
  )
  $(call Exit-Macro)
endef

_macro := verify-is-modfw-repo
define _help
${_macro}
  Verify a node contains a ModFW style repo.
  The repo must have been previously declared.
  Parameters:
    1 = The repo to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call verify-repo-is-declared,$(1))
  $(if $(call node-exists,$(1)),
    $(call PASS,Repo $(1) has a valid path.)
    $(if $(call repo-exists,$(1)),
      $(call PASS,Repo $(1) is a git repo.)
      $(if $(call is-modfw-repo,$(1)),
        $(call PASS,Repo $(1) is a modfw repo.)
      ,
        $(call FAIL,Repo $(1) is NOT a ModFW repo.)
      )
    ,
      $(call FAIL,Repo $(1) is NOT a git repo.)
    )
  ,
    $(call FAIL,Repo $(1) path does not exist.)
  )
  $(call Exit-Macro)
endef

_macro := verify-is-not-modfw-repo
define _help
${_macro}
  Verify a repo does not contain a ModFW style git repo.
  The repo must have been previously declared and its node must exist.
  Parameters:
    1 = The repo to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call verify-repo-is-declared,$(1))
  $(if $(call node-exists,$(1)),
    $(call PASS,Repo $(1) has a valid path.)
    $(if $(call repo-exists,$(1)),
      $(call PASS,Repo $(1) is a git repo.)
      $(if $(call is-modfw-repo,$(1)),
        $(call FAIL,Repo $(1) is a modfw repo.)
      ,
        $(call PASS,Repo $(1) is NOT a ModFW repo.)
      )
    ,
      $(call FAIL,Repo $(1) is NOT a git repo.)
    )
  ,
    $(call FAIL,Repo $(1) path does not exist.)
  )
  $(call Exit-Macro)
endef

$(call Add-Help-Section,test-list,Repo macro tests.)

$(call Declare-Suite,${Seg},Verify the repo management macros.)

$(call Declare-Test,nonexistent-repos)
define _help
${.TestUN}
  Verify messages, warnings and, errors for when repos do not exist.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  node-tests.nonexistent-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Test-Info,Testing repo has not been declared.)
  $(eval _repo := does-not-exist)
  $(call verify-repo-not-declared,${_repo})

  $(call Test-Info,Testing repo does not exist.)
  $(call verify-repo-does-not-exist,${_repo})

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,declare-repo)
define _help
${.TestUN}
  Verify declaring and undeclaring repos.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  ${SuiteN}.nonexistent-repos \
  node-tests.declare-root-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := ${Seg}.drnr1)
  $(eval ${_rn}.URL := test)
  $(eval ${_rn}.BRANCH := test)

  $(call verify-repo-not-declared,${_rn})

  $(call Expect-Error,The node for repo ${_rn} has not been declared.)
  $(call declare-repo,${_rn})
  $(call Verify-Error)
  $(call verify-repo-not-declared,${_rn})

  $(call declare-root-node,${_rn},${PROJECTS_PATH})

  $(call Test-Info,Checking the default URL.)
  $(call Expect-Error)
  $(call declare-repo,${_rn})
  $(call Verify-No-Error)
  $(call verify-repo-is-declared,${_rn})
  $(call Expect-Vars,\
    ${_rn}.url:${DEFAULT_URL}:${_rn} ${_rn}.branch:${DEFAULT_BRANCH})

  $(call Test-Info,Verify repo can be undeclared.)
  $(call Expect-No-Error)
  $(call undeclare-repo,${_rn})
  $(call Verify-No-Error)
  $(call verify-repo-not-declared,${_rn})

  $(call Test-Info,Also verifying repo attributes are case sensitive.)

  $(call Test-Info,Verify repo can be declared using the default branch.)
  $(call Expect-No-Error)
  $(call declare-repo,${_rn},${${_rn}.URL}1)
  $(call Verify-No-Error)
  $(call verify-repo-is-declared,${_rn})
  $(call Expect-Vars,\
    ${_rn}.url:${${_rn}.URL}1 ${_rn}.branch:${DEFAULT_BRANCH})

  $(call Test-Info,Verify same repo can't be re-declared.)
  $(call Expect-Error,Repo ${_rn} has already been declared.)
  $(call declare-repo,${_rn},${${_rn}.URL},${${_rn}.BRANCH})
  $(call Verify-Error)
  $(call Expect-Vars,\
    ${_rn}.url:${${_rn}.URL}1 ${_rn}.branch:${DEFAULT_BRANCH})

  $(call Expect-No-Error)
  $(call undeclare-repo,${_rn})
  $(call Verify-No-Error)
  $(call verify-repo-not-declared,${_rn})

  $(call Test-Info,Verify repo cannot be undeclared when it is not declared.)
  $(call Expect-Error,Repo ${_rn} has not been declared.)
  $(call undeclare-repo,${_rn})
  $(call Verify-Error)

  $(call Test-Info,Verify repo can be declared with a specified branch.)

  $(call Expect-No-Error)
  $(call declare-repo,${_rn},${${_rn}.URL},${${_rn}.BRANCH})
  $(call Verify-No-Error)
  $(call verify-repo-is-declared,${_rn})
  $(call Expect-Vars,\
    ${_rn}.url:${${_rn}.URL} ${_rn}.branch:${${_rn}.BRANCH})

  $(call Expect-No-Error)
  $(call undeclare-repo,${_rn})
  $(call Verify-No-Error)
  $(call verify-repo-not-declared,${_rn})

  $(call undeclare-root-node,${_rn})
  $(eval undefine ${_rn}.URL)
  $(eval undefine ${_rn}.BRANCH)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,mk-modfw-repo)
define _help
${.TestUN}
  Verify creating and destroying a repo.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  ${.SuiteN}.declare-repo \
  node-tests.mk-root-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := ${Seg}.crr1)
  $(eval ${_rn}.URL := test)
  $(eval ${_rn}.BRANCH := test)

  $(call Test-Info,Testing repo is not declared.)
  $(call verify-repo-not-declared,${_rn})

  $(call Test-Info,Creating test root node.)
  $(call declare-root-node,${_rn},${PROJECTS_PATH})

  $(call Test-Info,Verify can create repo.)
  $(call Expect-Error,Repo ${_rn} has not been declared.)
  $(call mk-modfw-repo,${_rn})
  $(call Verify-Error)

  $(call declare-repo,${_rn},${${_rn}.URL})

  $(call Expect-Error,The node for repo ${_rn} does not exist.)
  $(call mk-modfw-repo,${_rn})
  $(call Verify-Error)

  $(call mk-node,${_rn})

  $(call Expect-No-Error)
  $(call mk-modfw-repo,${_rn})
  $(call Verify-No-Error)

  $(call verify-repo-exists,${_rn})
  $(call verify-is-modfw-repo,${_rn})

  $(call Test-Info,Verify the repo can't be created if it already exists.)
  $(call Expect-Error,Repo ${_rn} already exists.)
  $(call mk-modfw-repo,${_rn})
  $(call Verify-Error)

  $(call Test-Info,DECLINE deletion of the .git directory.)
  $(call rm-repo,${_rn})
  $(call verify-repo-exists,${_rn})

  $(call Test-Info,ACCEPT deletion of the .git directory.)
  $(call rm-repo,${_rn})
  $(call verify-repo-does-not-exist,${_cn})

  $(call Expect-Error,Node $(1) is not a repo -- not removing repo.)
  $(call rm-repo,${_rn})
  $(call Verify-Error)

  $(call undeclare-repo,${_rn})

  $(call Test-Info,Cleaning up.)
  $(call rm-node,${_rn})
  $(call undeclare-root-node,${_rn})
  $(eval undefine ${_rn}.URL)
  $(eval undefine ${_rn}.BRANCH)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,clone-local-repo)
define _help
${.TestUN}
  Verify cloning an existing local repo.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  ${.SuiteN}.mk-modfw-repo \
  node-tests.mk-child-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := ${Seg}.clnr1)
  $(eval _cn1 := clnc1)
  $(eval _cn2 := clnc2)

  $(call Test-Info,Testing repo is not declared.)
  $(call verify-repo-not-declared,${_cn1})

  $(call Test-Info,Creating root node ${_r1} to contain the test repos.)
  $(call declare-root-node,${_rn},${PROJECTS_PATH})
  $(call mk-node,${_rn})

  $(call Test-Info,Creating local repo ${_cn1}.)
  $(call declare-child-node,${_c1},${_r1})
  $(call mk-node,${_cn1})
  $(call declare-repo,${_cn1},test)
  $(call mk-modfw-repo,${_cn1})

  $(call declare-child-node,${_cn2},${_rn1})

  $(call Test-Info,Using a bogus URL should trigger an error.)
  $(call declare-repo,${_cn2},bogus)
  $(call Expect-Error,Clone of repo ${_cn2} from ${${_cn2}.url} failed.)
  $(if ${Run_Rc},
    $(call PASS,After clone-repo with bogus URL Run_Rc equals ${Run_Rc})
  ,
    $(call FAIL,After clone-repo with bogus URL should have Run_Rc.)
  )
    $(if $(call repo-exists,${_cn2}),
    $(call FAIL,Repo ${_cn2} should not exist.)
    $(call rm-repo,${_cn2})
  ,
    $(call PASS,Repo ${_cnt} was not created using a bogus url.)
  )
  $(call undeclare-repo,${_cn2})

  $(call Test-Info,Declaring repo ${_cn2} as clone of ${_cn1})
  $(call declare-repo,${_cn2},${${_cn1}.path})

  $(call Test-Info,Cloning local repo ${_cn1} to ${_cn2})
  $(call clone-repo,${_cn2})
  $(call Test-Info,Call to clone-repo result:${Run_Output})
  $(if ${Run_Rc},
    $(call FAIL,Cloning ${_cn1} to ${_cn2} failed.)
  ,
    $(call PASS,Cloning ${_cn1} to ${_cn2} succeeded.)
  )
  $(if $(call repo-exists,${_cn2}),
    $(call PASS,Repo ${_cn2} has been cloned from ${_cn1}.)
  ,
    $(call FAIL,Repo ${_cn2} was not created.)
  )
  $(call verify-repo-exists,${_cn2})

  $(call Test-Info,Teardown.)
  $(call rm-repo,${_cn2})
  $(call undeclare-repo,${_cn2})
  $(call rm-node,${_cn2})
  $(call undeclare-child-node,${_cn2})

  $(call rm-repo,${_cn1})
  $(call undeclare-repo,${_cn1})
  $(call rm-node,${_cn1})
  $(call undeclare-child-node,${_cn1})

  $(call rm-node,${_rn})
  $(call undeclare-root-node,${_rn})

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,local-mk-repo-from-template)
define _help
${.TestUN}
  Verify using a local template repo to create a new repo.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  ${.SuiteN}.mk-modfw-repo
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := ${Seg}.btnr1)
  $(eval _cn1 := btnc1)
  $(eval _cn2 := btnc2)

  $(call Test-Info,Setup.)
  $(call declare-root-node,${_rn},${PROJECTS_PATH})
  $(call mk-node,${_rn})

  $(call Test-Info,Testing repo is not declared.)
  $(call verify-repo-not-declared,${_cn1})

  $(call declare-child-node,${_cn1},${_rn})
  $(call mk-node,${_cn1})

  $(call Test-Info,Testing template is not a repo.)
  $(call Expect-Error,Template node ${_cn1} is not a repo.)
  $(call mk-repo-from-template,${_cn2},${_cn1})
  $(call Verify-Error)
  $(call verify-repo-does-not-exist,${_cn2})

  $(call declare-repo,${_cn1},test)

  $(call mk-modfw-repo,${_cn1})

  $(call declare-child-node,${_cn2},${_rn1})
  $(call declare-repo,${_cn2})

  $(call Test-Info,Using ${_cn1} as template for ${_cn2})
  $(call mk-repo-from-template,${_cn2},${_cn1})
  $(call verify-repo-exists,${_cn2})
  $(call verify-is-modfw-repo,${_cn2})

  $(call Test-Info,Teardown.)
  $(call rm-repo,${_cn2})
  $(call undeclare-repo,${_cn2})
  $(call rm-node,${_cn2})
  $(call undeclare-child-node,${_cn2})

  $(call rm-repo,${_cn1})
  $(call undeclare-repo,${_cn1})
  $(call rm-node,${_cn1})
  $(call undeclare-child-node,${_cn1})

  $(call rm-node,${_rn})
  $(call undeclare-root-node,${_rn})

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,install-repo)
define _help
${.TestUN}
  Verify using repos.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  ${.SuiteN}.clone-local-repo
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _pn := ${Seg}.urp1)
  $(eval _r1 := ${Seg}.urr1)
  $(eval _r2 := ${Seg}.urr2)

  $(call Expect-Error,Parent node ${_pn} for repo ${_r1} has not been declared.)
  $(call install-repo,${_r1},${_pn})
  $(call Verify-Error)
  $(if $(call if-repo-exists,${_r1}),
    $(call FAIL,Repo ${_r1} should not exist.)
  ,
    $(call PASS,Repo ${_r1} does not exist.)
  )

  $(call declare-root-node,${_pn},${PROJECTS_PATH})

  $(call Expect-Error,Parent node ${_pn} for repo ${_r1} does not exist.)
  $(call install-repo,${_r1},${_pn})
  $(call Verify-Error)
  $(if $(call if-repo-exists,${_r1}),
    $(call FAIL,Repo ${_r1} should not exist.)
  ,
    $(call PASS,Repo ${_r1} does not exist.)
  )

  $(call mk-node,${_pn})
  $(call declare-child-node,${_r1},${_pn})
  $(call mk-node,$(_r1))
  $(call mk-modfw-repo,${_r1})

  $(call Expect-No-Error)
  $(call install-repo,${_r2},${_pn},${${_r1}.path})
  $(call Verify-No-Error)
  $(if $(call repo-exists,${r2}),
    $(call PASS,Repo ${_r2} exists.)
  ,
    $(call FAIL,Repo ${_r2} does not exist.)
  )
  $(if ${${${_r2}.seg_un}.SegID},
    $(call PASS,Repo ${_r2} is in use.)
  ,
    $(call FAIL,Repo ${_r2} is NOT in use.)
  )

  $(call Test-Info,Test teardown.)
  $(call rm-repo,${_r1})
  $(call undeclare-repo,${_r1})
  $(call rm-node,${_r1})
  $(call undeclare-child-node,${_r1})

  $(call rm-repo,${_r2})
  $(call undeclare-repo,${_r2})
  $(call rm-node,${_r2})
  $(call undeclare-child-node,${_r2})

  $(call rm-node,${_pn})
  $(call undeclare-root-node,${_pn})

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,branching)
define _help
${.TestUN}
  Verify creating and switching repo branches.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  ${.SuiteN}.mk-modfw-repo
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := ${Seg}.urr1)

  $(call Test-Info,Test setup.)
  $(call declare-root-node,${_rn},${PROJECTS_PATH})
  $(call mk-node,${_rn})

  $(eval _bms := \
    repo-branch-exists \
    branches \
    switch-branch \
    mk-branch \
    rm-branch \
  )

  $(eval _b := testbranch)

  $(call Test-Info,Verifying error messages when repo has not been declared.)
  $(foreach _m,${_bms},
    $(call Expect-Error,Repo ${_rn} has not been declared.)
    $(call ${_m},${_rn},${_b})
    $(call Verify-Error)
    )

  $(call declare-repo,${_rn})

  $(call Test-Info,Verifying error messages when repo does not exist.)
  $(foreach _m,${_bms},
    $(call Expect-Error,${_rn} is NOT a repo.)
    $(call ${_m},${_rn},${_b})
    $(call Verify-Error)
    )

  $(call mk-modfw-repo,${_rn})

  $(call Test-Info,Verifying:repo-branch-exists.)
  $(call branches,${_rn})
  $(if $(call repo-branch-exists,${DEFAULT_BRANCH}),
    $(call PASS,Branch ${DEFAULT_BRANCH} exists.)
  ,
    $(call FAIL,Branch ${DEFAULT_BRANCH} does not exist.)
  )

  $(if $(call repo-branch-exists,${_b}),
    $(call FAIL,Branch ${_b} should not exist.)
  ,
    $(call PASS,Branch ${_b} does not exist.)
  )

  $(call Expect-Error,Repo ${_rn} does not have a branch named ${_b}.)
  $(call Expect-No-Error)
  $(call switch-branch,${_rn},${_b})
  $(call Verify-No-Error)

  $(call Test-Info,Verifying:mk-branch)
  $(call mk-branch,${_rn},${_b})
  $(if $(call repo-branch-exists,${_rn},${_b}),
    $(call PASS,Branch ${_b} exists.)
  ,
    $(call FAIL,Branch ${_b} does not exist.)
  )

  $(call Expect-Error,Branch ${_b} already exists in repo ${_rn}.)
  $(call mk-branch,${_rn},${_b})
  $(call Verify-Error)

  $(call Test-Info,Verifying:rm-branch)
  $(call Expect-No-Error)
  $(call rm-branch,${_rn},${_b})
  $(call Verify-No-Error)
  $(if $(call repo-branch-exists,${_rn},${_b}),
    $(call FAIL,Branch ${_b} should not exist.)
  ,
    $(call PASS,Branch ${_b} does not exist.)
  )

  $(call Expect-Error,Repo ${_rn} does not contain branch ${_b}.)
  $(call rm-branch,${_rn},${_b})
  $(call Verify-Error)

  $(call Test-Info,Test teardown.)
  $(call undeclare-repo,${_rn})
  $(call rm-repo,${_rn})
  $(call rm-node,${_rn})
  $(call undeclare-root-node,${_rn})

  $(call End-Test)
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

$(call End-Declare-Suite)

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
