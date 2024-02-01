#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW - repo test suite.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,ModFW - node test suite.)
# -----
$(call Use-Segment,test-nodes)

$(call Declare-Suite,${Seg},Verify the repo macros.)

TESTING_PATH := ${TESTING_PATH}/${Seg}

_macro := verify-repo-not-declared
define _help
${_macro}
  Verify a repo is not declared and its attributes are not defined.
  Parameters:
    1 = The repo to verify.
endef
help-${_macro} := ${_help}
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
help-${_macro} := ${_help}
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
help-${_macro} := ${_help}
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
help-${_macro} := ${_help}
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
help-${_macro} := ${_help}
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
help-${_macro} := ${_help}
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

$(call Declare-Test,nonexistent-repos)
define _help
${.TestUN}
  Verify messages, warnings and, errors for when repos do not exist.
endef
help-${.TestUN} := ${_help}
${.TestUN}.Prereqs := \
  test-nodes.nonexistent-nodes
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

$(call Declare-Test,declare-repos)
define _help
${.TestUN}
  Verify declaring and undeclaring repos.
endef
help-${.TestUN} := ${_help}
${.TestUN}.Prereqs := \
  test-nodes.declare-root-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := ${Seg}.drnr1)

  $(call verify-repo-not-declared,${_rn})

  $(call Expect-Error,The node for repo ${_rn} has not been declared.)
  $(call declare-repo,${_rn})
  $(call Verify-Error)

  $(call declare-root-node,${_rn},${TESTING_PATH})

  $(call Expect-No-Error)
  $(call declare-repo,${_rn})
  $(call Verify-No-Error)

  $(call verify-Repo-is-declared,${_rn})

  $(call Test-Info,Verify repo can be undeclared.)

  $(call Expect-No-Error)
  $(call undeclare-repo,${_rn})
  $(call Verify-No-Error)

  $(call verify-repo-not-declared,${_rn})

  $(call Test-Info,Verify repo cannot be undeclared more than once.)

  $(call Expect-Error,Repo ${_rn} is NOT declared -- NOT undeclaring.)
  $(call undeclare-repo,${_rn})
  $(call Verify-Error)

  $(call undeclare-root-node,${_rn})

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,use-repo)
define _help
${.TestUN}
  Verify cloning and using repos.
endef
help-${.TestUN} := ${_help}
${.TestUN}.Prereqs := \
  ${.SuiteN}.declare-root-nodes \
  ${.SuiteN}.create-root-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := ${Seg}.urr1)
  $(eval _cn := urc1)

  $(call Test-Info,Testing node is not declared.)
  $(call verify-node-not-declared,${_rn})

  $(call Test-Info,Creating test root node.)
  $(call declare-root-node,${_rn},${TESTING_PATH})
  $(call create-node,${_rn})

  $(call Test-Info,Creating test child node.)
  $(call declare-child-node,${_cn},${_rn})
  $(call create-node,${_cn})
  $(call verify-node-exists,${_cn})

  $(call destroy-node,${_cn})
  $(call verify-node-does-not-exist,${_cn})

  $(call undeclare-child-node,${_cn})

  $(call Test-Info,Destroying test child node.)
  $(call destroy-node,${_rn})
  $(call undeclare-root-node,${_rn})


  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,create-repo)
define _help
${.TestUN}
  Verify creating and destroying repos.
endef
help-${.TestUN} := ${_help}
${.TestUN}.Prereqs := \
  test-nodes.declare-child-nodes \
  ${.SuiteN}.create-root-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := ${Seg}.crnr1)
  $(eval _cn := crnc1)

  $(call Test-Info,Testing node is not declared.)
  $(call verify-node-not-declared,${_rn})

  $(call Test-Info,Creating test root node.)
  $(call declare-root-node,${_rn},${TESTING_PATH})
  $(call create-node,${_rn})

  $(call Test-Info,Creating test child node.)
  $(call declare-child-node,${_cn},${_rn})
  $(call create-node,${_cn})
  $(call verify-node-exists,${_cn})

  $(call destroy-node,${_cn})
  $(call verify-node-does-not-exist,${_cn})

  $(call undeclare-child-node,${_cn})

  $(call Test-Info,Destroying test child node.)
  $(call destroy-node,${_rn})
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
Make segment: ${Seg}.mk

This test suite verifies the macros related to managing nodes.

Defines the macros:

${help-display-repo}
${help-display-node-tree}

$(foreach _t,${${.TestUN}.TestL},
${help-${_t}})

Uses:
  TESTING_PATH
    Where the test nodes are stored.

Command line goals:
  help-${Seg} or help-${SegUN} or help-${SegID}
    Display this help.
endef
${_h} := ${_help}
endif # help goal message.

$(call End-Declare-Suite)

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
