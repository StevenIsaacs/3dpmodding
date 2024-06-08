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

$(call Use-Segment,repos)

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
    $(call FAIL,Node $(1) is not declared.)
  )
  $(if $(call repo-is-declared,$(1)),
    $(call PASS,Repo $(1) is declared.)
  ,
    $(call FAIL,Repo $(1) is not declared.)
  )
  $(foreach _a,${repo_attributes},
    $(if $(call Is-Not-Defined,$(1).${_a}),
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

$(call Declare-Test,declare-repo)
define _help
${.TestUN}
  Verify declaring and undeclaring repos.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  node-tests.declare-root-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := $(0).drnr1)

  $(call verify-repo-not-declared,${_rn})

  $(call Test-Info,Checking undeclared node.)
  $(call Expect-Error,The node for repo ${_rn} has not been declared.)
  $(call declare-repo,${_rn})
  $(call Verify-Error)
  $(call verify-repo-not-declared,${_rn})

  $(call declare-root-node,${_rn},${TESTING_PATH})

  $(call Test-Info,Checking the default URL.)
  $(call Expect-No-Error)
  $(call declare-repo,${_rn})
  $(call Verify-No-Error)
  $(call verify-repo-is-declared,${_rn})
  $(call Test-Info,${_rn}.repo_url = ${${_rn}.repo_url})
  $(call Expect-Vars,\
    ${_rn}.repo_url:${DEFAULT_URL}/${_rn} \
    ${_rn}.repo_branch:${DEFAULT_BRANCH} \
    )

  $(call Test-Info,Verify repo can be undeclared.)
  $(call Expect-No-Error)
  $(call undeclare-repo,${_rn})
  $(call Verify-No-Error)
  $(call verify-repo-not-declared,${_rn})

  $(eval ${_rn}.URL := test_url)
  $(eval ${_rn}.BRANCH := test)

  $(call Test-Info,Verify repo can be declared using the defaults.)
  $(call Expect-No-Error)
  $(call declare-repo,${_rn},${${_rn}.URL},${${_rn}.BRANCH})
  $(call Verify-No-Error)
  $(call verify-repo-is-declared,${_rn})
  $(call Expect-Vars,\
    ${_rn}.repo_url:${${_rn}.URL} \
    ${_rn}.repo_branch:${${_rn}.BRANCH} \
    )

  $(call Test-Info,Verify same repo can't be re-declared.)
  $(call Expect-Warning,Repo ${_rn} has already been declared.)
  $(call declare-repo,${_rn},${${_rn}.URL},${${_rn}.BRANCH})
  $(call Verify-Warning)
  $(call Expect-Vars,\
    ${_rn}.repo_url:${${_rn}.URL} \
    ${_rn}.repo_branch:${${_rn}.BRANCH} \
    )

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
    ${_rn}.repo_url:${${_rn}.URL} \
    ${_rn}.repo_branch:${${_rn}.BRANCH} \
    )

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

$(call Declare-Test,nonexistent-repos)
define _help
${.TestUN}
  Verify messages, warnings and, errors for when repos do not exist.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  $(.SuiteN).declare-repo \
  node-tests.mk-root-nodes \
  node-tests.nonexistent-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := $(0).ner)
  $(call declare-root-node,${_rn},${TESTING_PATH})

  $(call Test-Info,Testing repo has not been declared.)
  $(call verify-repo-not-declared,${_rn})

  $(call mk-node,${_rn})
  $(call declare-repo,${_rn})

  $(call Test-Info,Testing repo does not exist.)
  $(call verify-repo-does-not-exist,${_rn})

  $(call rm-node,${_rn})
  $(call undeclare-repo,${_rn})
  $(call undeclare-root-node,${_rn})

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
  node-tests.mk-root-nodes \
  ${.SuiteN}.declare-repo
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := $(0).mmr1)
  $(eval ${_rn}.URL := test)
  $(eval ${_rn}.BRANCH := test)

  $(call Test-Info,Testing repo is not declared.)
  $(call verify-repo-not-declared,${_rn})

  $(call Test-Info,Creating test root node.)
  $(call declare-root-node,${_rn},${TESTING_PATH})

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

  $(call verify-is-modfw-repo,${_rn})

  $(call Test-Info,Verify the repo can't be created if it already exists.)
  $(call Expect-Error,Repo ${_rn} already exists.)
  $(call mk-modfw-repo,${_rn})
  $(call Verify-Error)

  $(call Test-Info,DECLINE deletion of the .git directory.)
  $(call rm-repo,${_rn},DECLINE)
  $(call verify-repo-exists,${_rn})

  $(call Test-Info,ACCEPT deletion of the .git directory.)
  $(call rm-repo,${_rn},ACCEPT)
  $(call verify-repo-does-not-exist,${_rn})

  $(call Expect-Error,Node ${_rn} is not a repo -- not removing repo.)
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

  $(eval _rn := $(0).clnr1)
  $(eval _cn1 := clnc1)
  $(eval _cn2 := clnc2)

  $(call Test-Info,Testing repo is not declared.)
  $(call verify-repo-not-declared,${_cn1})

  $(call Test-Info,Creating root node ${_r1} to contain the test repos.)
  $(call declare-root-node,${_rn},${TESTING_PATH})
  $(call mk-node,${_rn})

  $(call Test-Info,Creating local repo ${_cn1}.)
  $(call declare-child-node,${_cn1},${_rn})
  $(call mk-node,${_cn1})
  $(call declare-repo,${_cn1},test)
  $(call mk-modfw-repo,${_cn1})

  $(call declare-child-node,${_cn2},${_rn})

  $(call Test-Info,Using a bogus URL should trigger an error.)
  $(call declare-repo,${_cn2},bogus)
  $(call Expect-Error,Clone of repo ${_cn2} from ${${_cn2}.repo_url} failed.)
  $(call clone-repo,${_cn2})
  $(call Verify-Error)
  $(if ${Run_Rc},
    $(call PASS,After clone-repo with bogus URL Run_Rc equals ${Run_Rc})
  ,
    $(call FAIL,After clone-repo with bogus URL should have Run_Rc.)
  )
  $(if $(call repo-exists,${_cn2}),
    $(call FAIL,Repo ${_cn2} should not exist.)
    $(call rm-repo,${_cn2})
  ,
    $(call PASS,Repo ${_cn2} was not created using a bogus url.)
  )
  $(call undeclare-repo,${_cn2})

  $(call Test-Info,Declaring repo ${_cn2} as clone of ${_cn1})
  $(call declare-repo,${_cn2},${${_cn1}.path})

  $(call Test-Info,Cloning local repo ${_cn1} to ${_cn2})
  $(call Expect-No-Error)
  $(call clone-repo,${_cn2})
  $(call Verify-No-Error)
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

$(call Declare-Test,mk-repo-from-template)
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

  $(eval _rn := $(0).btnr1)
  $(eval _cn1 := btnc1)
  $(eval _cn2 := btnc2)

  $(call Test-Info,Setup.)
  $(call declare-root-node,${_rn},${TESTING_PATH})
  $(call mk-node,${_rn})

  $(call Test-Info,Testing repo is not declared.)
  $(call verify-repo-not-declared,${_cn1})

  $(call declare-child-node,${_cn1},${_rn})
  $(call mk-node,${_cn1})

  $(call Test-Info,Testing template is not a repo.)
  $(call Expect-Error,Template node ${_cn1} is not a repo.)
  $(call mk-repo-from-template,${_cn2},${_cn1})
  $(call Verify-Error)

  $(call declare-repo,${_cn1},test)

  $(call mk-modfw-repo,${_cn1})

  $(call declare-child-node,${_cn2},${_rn})
  $(call declare-repo,${_cn2})

  $(call Test-Info,Using ${_cn1} as template for ${_cn2})
  $(call Expect-No-Error)
  $(call mk-repo-from-template,${_cn2},${_cn1})
  $(call Verify-No-Error)
  $(call verify-repo-exists,${_cn2})
  $(call verify-is-modfw-repo,${_cn2})

  $(call Test-Info,Check the errors if the new repo node exists.)
  $(call Expect-Error,The repo node ${_cn2} already exists -- not cloning.)
  $(call mk-repo-from-template,${_cn2},${_cn1})
  $(call Verify-Error)

  $(call Test-Info,Verify template repo errors.)
  $(call rm-node,${_cn2})
  $(if $(wildcard ${${_cn1}.seg_f}),
    $(call PASS,The segment file for ${_cn1} exists -- removing.)
    $(call Run,rm ${${_cn1}.seg_f})
  ,
    $(call FAIL,The segment file for ${_cn1} does not exist.)
  )

  $(call Expect-Error,Template node ${_cn1} is not a ModFW repo.)
  $(call mk-repo-from-template,${_cn2},${_cn1})
  $(call Verify-Error)
  $(call verify-node-does-not-exist,${_cn2})

  $(call rm-repo,${_cn1})
  $(call Expect-Error,Template node ${_cn1} is not a repo.)
  $(call mk-repo-from-template,${_cn2},${_cn1})
  $(call Verify-Error)
  $(call verify-node-does-not-exist,${_cn2})

  $(call Test-Info,Teardown.)
  $(call undeclare-repo,${_cn2})
  $(call rm-node,${_cn2})
  $(call undeclare-child-node,${_cn2})

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

  $(eval _pn := $(0).urp1)
  $(eval _r1 := urr1)
  $(eval _r2 := urr2)

  $(call Test-Info,Checking undeclared repo.)
  $(call Expect-Error,The repo ${_r2} has not been declared.)
  $(call install-repo,${_r2})
  $(call Verify-Error)

  $(call declare-root-node,${_r2},${TESTING_PATH})
  $(call declare-repo,${_r2},bogus)

  $(call Test-Info,Checking cannot use a root node.)
  $(call Expect-Error,Repo ${_r2} is not a child node.)
  $(call install-repo,${_r2})
  $(call Verify-Error)

  $(call undeclare-repo,${_r2})
  $(call undeclare-root-node,${_r2})

  $(call declare-root-node,${_pn},${TESTING_PATH})
  $(call declare-child-node,${_r2},${_pn})
  $(call declare-repo,${_r2},null)

  $(call Test-Info,Checking parent does not exist.)
  $(call Expect-Error,Parent node for repo ${_r2} does not exist.)
  $(call install-repo,${_r2})
  $(call Verify-Error)

  $(call mk-node,${_pn})

  $(call Test-Info,Creating source repo.)
  $(call declare-child-node,${_r1},${_pn})
  $(call mk-node,${_r1})
  $(call declare-repo,${_r1},null)
  $(call mk-modfw-repo,${_r1})

  $(call Test-Info,Proper declaration.)
  $(call undeclare-repo,${_r2})

  $(call declare-repo,${_r2},${${_r1}.path})

  $(call mk-node,${_r2})

  $(call Test-Info,Checking node name conflict.)
  $(call Expect-Error,A node having the repo name ${_r2} already exists.)
  $(call install-repo,${_r2})
  $(call Verify-Error)
  $(call verify-repo-does-not-exist,${_r2})

  $(call rm-node,${_r2})

  $(call Test-Info,Checking all conditions are correct.)
  $(call Expect-No-Error)
  $(call install-repo,${_r2})
  $(call Verify-No-Error)
  $(call verify-repo-exists,${_r2})

  $(call Test-Info,Checking cannot install a second time.)
  $(call Expect-Warning,Repo ${_r2} already exists -- not installing.)
  $(call install-repo,${_r2})
  $(call Verify-Warning)

  $(call Test-Info,Test teardown.)
  $(call undeclare-repo,${_r2})
  $(call rm-node,${_r2})
  $(call undeclare-child-node,${_r2})

  $(call undeclare-repo,${_r1})
  $(call rm-node,${_r1})
  $(call undeclare-child-node,${_r1})

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

  $(eval _rn := $(0).urr1)
  $(eval _cn := urc1)

  $(call Test-Info,Test setup.)
  $(call declare-root-node,${_rn},${TESTING_PATH})
  $(call mk-node,${_rn})
  $(call declare-child-node,${_cn},${_rn},null)

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
    $(call Expect-Error,Repo ${_cn} has not been declared.)
    $(call ${_m},${_cn},${_b})
    $(call Verify-Error)
    )

  $(call declare-repo,${_cn})

  $(call Test-Info,Verifying error messages when repo does not exist.)
  $(foreach _m,${_bms},
    $(call Expect-Error,${_cn} is NOT a repo.)
    $(call ${_m},${_cn},${_b})
    $(call Verify-Error)
    )

  $(call mk-node,${_cn})
  $(call mk-modfw-repo,${_cn})

  $(call Test-Info,Verifying:repo-branch-exists.)
  $(eval _bl := $(call branches,${_cn}))
  $(call Test-Info,Branch list is: ${_bl})
  $(if $(call repo-branch-exists,${_cn},${DEFAULT_BRANCH}),
    $(call PASS,Branch ${DEFAULT_BRANCH} exists.)
  ,
    $(call FAIL,Branch ${DEFAULT_BRANCH} does not exist.)
  )

  $(if $(call repo-branch-exists,${_cn},${_b}),
    $(call FAIL,Branch ${_b} should not exist.)
  ,
    $(call PASS,Branch ${_b} does not exist.)
  )

  $(call Expect-Error,Repo ${_cn} does not have a branch named ${_b}.)
  $(call switch-branch,${_cn},${_b})
  $(call Verify-Error)

  $(call Test-Info,Verifying:mk-branch)
  $(call mk-branch,${_cn},${_b})
  $(eval _bl := $(call branches,${_cn}))
  $(call Test-Info,Branch list is: ${_bl})
  $(if $(call repo-branch-exists,${_cn},${_b}),
    $(call PASS,Branch ${_b} exists.)
  ,
    $(call FAIL,Branch ${_b} does not exist.)
  )

  $(call Expect-Error,Branch ${_b} already exists in repo ${_cn}.)
  $(call mk-branch,${_cn},${_b})
  $(call Verify-Error)

  $(eval _ab := $(call get-active-branch,${_cn}))
  $(call Test-Info,Active branch is: ${_ab})

  $(call Test-Info,Verifying:switch-branch)
  $(call Expect-No-Error)
  $(call switch-branch,${_cn},$(DEFAULT_BRANCH))
  $(call Verify-No-Error)

  $(eval _ab := $(call get-active-branch,${_cn}))
  $(call Test-Info,Active branch is: ${_ab})

  $(call Test-Info,Verifying:rm-branch)
  $(call Expect-No-Error)
  $(call rm-branch,${_cn},${_b})
  $(eval _bl := $(call branches,${_cn}))
  $(call Test-Info,Branch list is: ${_bl})
  $(call Verify-No-Error)
  $(if $(call repo-branch-exists,${_cn},${_b}),
    $(call FAIL,Branch ${_b} should not exist.)
  ,
    $(call PASS,Branch ${_b} does not exist.)
  )

  $(call Test-Info,Verify cannot delete previously deleted branch.)
  $(call Expect-Error,Repo ${_cn} does not contain branch ${_b}.)
  $(call rm-branch,${_cn},${_b})
  $(call Verify-Error)

  $(call Test-Info,Test teardown.)
  $(call undeclare-repo,${_cn})
  $(call rm-node,${_cn})
  $(call undeclare-child-node,${_cn})

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
