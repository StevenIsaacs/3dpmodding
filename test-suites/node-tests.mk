#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW - node test suite.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,ModFW - node test suite.)
# -----
define _help
Make segment: ${Seg}.mk

This test suite verifies the macros related to managing nodes.

Command line goals:
  help-${Seg} or help-${SegUN} or help-${SegID}
    Display this help.
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Use-Segment,nodes)

$(call Add-Help-Section,verifiers,Macros for verifying nodes.)

$(call Declare-Suite,${Seg},Verify the node macros.)

_macro := verify-node-not-declared
define _help
${_macro}
  Verify a node is not declared and its attributes are not defined.
  Parameters:
    1 = The node to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),node=$(1))
  $(if $(call node-is-declared,$(1)),
    $(call FAIL,Node $(1) should not be declared.)
  ,
    $(call PASS,Node $(1) is not declared.)
  )
  $(foreach _a,${node_attributes},
    $(if $(call Is-Not-Defined,$(1).${_a}),
      $(call PASS,Node attribute $(1).${_a} is not defined.)
    ,
      $(call FAIL,Node attribute $(1).${_a} is defined.)
    )
  )
  $(call Exit-Macro)
endef

_macro := verify-node-is-declared
define _help
${_macro}
  Verify that a node is declared and its attributes are defined.
  Parameters:
    1 = The node to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),node=$(1))
  $(if $(call node-is-declared,$(1)),
    $(call PASS,Node $(1) is declared.)
  ,
    $(call FAIL,Node $(1) is not declared.)
  )
  $(foreach _a,${node_attributes},
    $(if $(call Is-Not-Defined,$(1).${_a}),
      $(call FAIL,Node attribute $(1).${_a} is not defined.)
    ,
      $(call PASS,Node attribute $(1).${_a} is defined.)
    )
  )
  $(call Exit-Macro)
endef

_macro := verify-node-exists
define _help
${_macro}
  Verify a node exists meaning the node path is a valid file system path.
  The node must have been previously declared.
  Parameters:
    1 = The node to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),node=$(1))
  $(call verify-node-is-declared,$(1))
  $(if $(call node-exists,$(1)),
    $(call PASS,Node $(1) has a valid path.)
  ,
    $(call FAIL,Node $(1) path does not exist.)
  )
  $(call Exit-Macro)
endef

_macro := verify-node-does-not-exist
define _help
${_macro}
  Verify a node does not exist meaning the node path is not a valid file system
  path.
  The node must have been previously declared.
  Parameters:
    1 = The node to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),node=$(1))
  $(call verify-node-is-declared,$(1))
  $(if $(call node-exists,$(1)),
    $(call FAIL,Node $(1) has a valid path and should not.)
  ,
    $(call PASS,Node $(1) path does not exist.)
  )
  $(call Exit-Macro)
endef

_macro := verify-is-root-node
define _help
${_macro}
  Verify a node is correctly structured as a root node. A root node has no
  parent.
  Parameters:
    1 = The node to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),node=$(1))
  $(call verify-node-is-declared,$(1))
  $(if ${$(1).parent},
    $(call FAIL,Node $(1) has a parent and should not.)
  ,
    $(call PASS,Node $(1) is a root node.)
  )
  $(call Exit-Macro)
endef

_macro := verify-is-child-node
define _help
${_macro}
  Verify a node is correctly structured as a child node. A child node has a
  parent.
  Parameters:
    1 = The node to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),node=$(1))
  $(call verify-node-is-declared,$(1))
  $(if ${$(1).parent},
    $(call PASS,Node $(1) is a child node.)
    $(call Test-Info,Verifying parent node ${$(1).parent} is declared.)
    $(call verify-node-is-declared,${$(1).parent})
  ,
    $(call FAIL,Child node $(1) has no parent and should.)
  )
  $(call Exit-Macro)
endef

_macro := verify-is-child-of-parent
define _help
${_macro}
  Verify a node is a child of its parent node.
  Parameters:
    1 = The node to verify.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),node=$(1))
  $(call verify-node-is-declared,$(1))
  $(if ${$(1).parent},
    $(call PASS,Node $(1) is a child node.)
    $(if $(filter $(1),${${$(1).parent}.children}),
      $(call PASS,Node $(1) is a child of ${$(1).parent}.)
    ,
      $(call FAIL,Node $(1) is NOT a child of ${$(1).parent}.)
    )
  ,
    $(call FAIL,Child node $(1) has no parent and should.)
  )
  $(call Exit-Macro)
endef

_macro := verify-is-child-of-node
define _help
${_macro}
  Verify a node is a child of the parent node.
  Parameters:
    1 = The node to verify.
    2 = The parent node.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),node=$(1) parent=$(2))
  $(call verify-node-is-declared,$(1))
  $(call verify-node-is-declared,$(2))
  $(if ${$(1).parent},
    $(call PASS,Node $(1) is a child node.)
    $(if $(filter $(1),${$(2).children}),
      $(call PASS,Node $(1) is a child of $(2).)
    ,
      $(call FAIL,Node $(1) is NOT a child of $(2).)
    )
  ,
    $(call FAIL,Child node $(1) has no parent and should.)
  )
  $(call Exit-Macro)
endef

_macro := verify-is-not-child-of-node
define _help
${_macro}
  Verify a node is not a child of the parent node. The child node must have
  been undeclared.
  Parameters:
    1 = The node to verify.
    2 = The parent node.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
  $(call Enter-Macro,$(0),node=$(1) parent=$(2))
  $(call verify-node-is-declared,$(2))
  $(if $(call is-a-child-of,$(1),$(2)),
    $(call FAIL,Node $(1) is a child of $(2).)
  ,
    $(call PASS,Node $(1) is NOT a child of $(2).)
  )
  $(call Exit-Macro)
endef

$(call Add-Help-Section,test_list,Tests for verifying nodes.)

$(call Declare-Test,declare-root-nodes)
define _help
${.TestUN}
  Verify declaring and undeclaring root nodes.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs :=
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := drn1)
  $(call verify-node-not-declared,${_rn})

  $(call Test-Info,Verify root node must have a path.)

  $(call Expect-Error,Path for root node ${_rn} has not been provided.)
  $(call declare-root-node,${_rn})
  $(call Verify-Error)

  $(call verify-node-not-declared,${_rn})

  $(call Test-Info,Verify root node can be declared.)

  $(call Expect-No-Error)
  $(call declare-root-node,${_rn},${TESTING_PATH})
  $(call Verify-No-Error)

  $(call verify-node-is-declared,${_rn})

  $(call Test-Info,Verify root node can be undeclared.)

  $(call Expect-No-Error)
  $(call undeclare-root-node,${_rn})
  $(call Verify-No-Error)

  $(call verify-node-not-declared,${_rn})

  $(call Test-Info,Verify root node cannot be undeclared more than once.)

  $(call Expect-Error,Node ${_rn} is NOT declared -- NOT undeclaring.)
  $(call undeclare-root-node,${_rn})
  $(call Verify-Error)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,nonexistent-nodes)
define _help
${.TestUN}
  Verify messages, warnings and, errors for when nodes do not exist.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.declare-root-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call Test-Info,Testing node has not been declared.)
  $(eval _node := does-not-exist)
  $(call verify-node-not-declared,${_node})

  $(call Test-Info,Testing node does not exist.)
  $(call declare-root-node,${_node},${TESTING_PATH})
  $(call verify-node-does-not-exist,${_node})
  $(call undeclare-root-node,${_node})

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,mk-root-nodes)
define _help
${.TestUN}
  Verify creating and destroying root nodes.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.nonexistent-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := $(0).crn1)

  $(call Test-Info,Testing node is not declared.)
  $(call verify-node-not-declared,${_rn})

  $(call Test-Info,Testing node does not exist.)
  $(call declare-root-node,${_rn},${TESTING_PATH})
  $(call verify-node-does-not-exist,${_rn})

  $(call Test-Info,Testing node can be created.)
  $(call mk-node,${_rn})
  $(call verify-node-exists,${_rn})

  $(call rm-node,${_rn})
  $(call verify-node-does-not-exist,${_rn})

  $(call undeclare-root-node,${_rn})

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,declare-child-nodes)
define _help
${.TestUN}
  Verify declaring and undeclaring child nodes.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.declare-root-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := $(0).dcnr1)
  $(eval _cn := dcnc1)

  $(call verify-node-not-declared,${_rn})
  $(call verify-node-not-declared,${_cn})

  $(call Test-Info,Verify root node must have a path.)

  $(call Expect-Error,The parent node has not been specified.)
  $(call declare-child-node,${_cn})
  $(call Verify-Error)

  $(call Test-Info,Verify parent node must have been declared.)
  $(call Expect-Error,Parent node ${_rn} has not been declared.)
  $(call declare-child-node,${_cn},${_rn})
  $(call Verify-Error)

  $(call verify-node-not-declared,${_cn})

  $(call Test-Info,Verify child node can be declared.)
  $(call declare-root-node,${_rn},${TESTING_PATH})

  $(call Expect-No-Error)
  $(call declare-child-node,${_cn},${_rn})
  $(call Verify-No-Error)

  $(call verify-node-is-declared,${_cn})

  $(call Test-Info,Verify child is a child of its parent.)
  $(call verify-is-child-of-parent,${_cn})

  $(call verify-is-child-of-node,${_cn},${_rn})

  $(call Test-Info,Verify child node can be undeclared.)
  $(call Expect-No-Error)
  $(call undeclare-child-node,${_cn})
  $(call Verify-No-Error)

  $(call verify-node-not-declared,${_cn})

  $(call verify-is-not-child-of-node,${_cn},${_rn})

  $(call Test-Info,Verify child node cannot be undeclared more than once.)
  $(call Expect-Error,Node ${_cn} is NOT declared -- NOT undeclaring.)
  $(call undeclare-child-node,${_cn})
  $(call Verify-Error)

  $(call undeclare-root-node,${_rn})

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,declare-grandchild-nodes)
define _help
${.TestUN}
  Verify declaring and undeclaring grandchild nodes.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  ${.SuiteN}.declare-child-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := $(0).dgcnr1)
  $(eval _cn := dgcnc1)
  $(eval _gcn1 := dgcngc1)
  $(eval _gcn2 := dgcngc2)
  $(eval _ggcn1 := dgcnggc1)

  $(call verify-node-not-declared,${_rn})
  $(call verify-node-not-declared,${_cn})
  $(call verify-node-not-declared,${_gcn1})

  $(call declare-root-node,${_rn},${TESTING_PATH})
  $(call declare-child-node,${_cn},${_rn})

  $(call Expect-No-Error)
  $(call declare-child-node,${_gcn1},${_cn})
  $(call Verify-No-Error)

  $(call verify-node-is-declared,${_gcn1})

  $(call verify-is-child-of-parent,${_gcn1})
  $(call verify-is-child-of-node,${_gcn1},${_cn})
  $(call verify-is-not-child-of-node,${_gcn1},${_rn})

  $(call Test-Info,Verify child node cannot be undeclared.)
  $(call Expect-Error,Child node ${_cn} has children -- NOT undeclaring.)
  $(call undeclare-child-node,${_cn})
  $(call Verify-Error)

  $(call Test-Info,Verify grandchild node can be undeclared.)
  $(call Expect-No-Error)
  $(call undeclare-child-node,${_gcn1})
  $(call Verify-No-Error)

  $(call verify-node-not-declared,${_gcn1})

  $(call verify-is-not-child-of-node,${_gcn1},${_cn})

  $(call Test-Info,Verify child node can now be undeclared.)
  $(call Expect-No-Error)
  $(call undeclare-child-node,${_cn})
  $(call Verify-No-Error)

  $(call verify-node-not-declared,${_cn})
  $(call verify-node-not-declared,${_gcn1})

  $(call Test-Info,Verifying undeclaring descendants.)
  $(call declare-child-node,${_cn},${_rn})
  $(call declare-child-node,${_gcn1},${_cn})
  $(call declare-child-node,${_ggcn1},${_gcn1})
  $(call declare-child-node,${_gcn2},${_cn})

  $(call display-node-descendants,${_rn})
  $(call undeclare-descendants,${_rn})
  $(call display-node-descendants,${_rn})
$(call Pause)
  $(call verify-node-not-declared,${_gcn2})
  $(call verify-node-not-declared,${_ggcn1})
  $(call verify-node-not-declared,${_gcn1})
  $(call verify-node-not-declared,${_cn})

  $(call undeclare-root-node,${_rn})

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,mk-child-nodes)
define _help
${.TestUN}
  Verify creating and destroying child nodes.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  ${.SuiteN}.declare-child-nodes \
  ${.SuiteN}.mk-root-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := $(0).ccnr1)
  $(eval _cn := ccnc1)

  $(call Test-Info,Testing node is not declared.)
  $(call verify-node-not-declared,${_rn})

  $(call Test-Info,Creating test root node.)
  $(call declare-root-node,${_rn},${TESTING_PATH})
  $(call mk-node,${_rn})

  $(call Test-Info,Creating test child node.)
  $(call declare-child-node,${_cn},${_rn})
  $(call mk-node,${_cn})
  $(call verify-node-exists,${_cn})

  $(call rm-node,${_cn})
  $(call verify-node-does-not-exist,${_cn})

  $(call undeclare-child-node,${_cn})

  $(call Test-Info,Destroying test child node.)
  $(call rm-node,${_rn})
  $(call undeclare-root-node,${_rn})


  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,mk-grandchild-nodes)
define _help
${.TestUN}
  Verify creating and destroying grandchild nodes.
endef
help-${.TestUN} := $(call _help)
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  ${.SuiteN}.declare-grandchild-nodes \
  ${.SuiteN}.mk-root-nodes
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _rn := $(0).cgcnr1)
  $(eval _cn := cgcnc1)
  $(eval _gcn := cgcngc1)

  $(call Test-Info,Testing node is not declared.)
  $(call verify-node-not-declared,${_rn})

  $(call Test-Info,Creating test root node.)
  $(call declare-root-node,${_rn},${TESTING_PATH})
  $(call mk-node,${_rn})

  $(call Test-Info,Creating test child node.)
  $(call declare-child-node,${_cn},${_rn})
  $(call mk-node,${_cn})

  $(call Test-Info,Creating test child node.)
  $(call declare-child-node,${_gcn},${_cn})
  $(call mk-node,${_gcn})
  $(call verify-node-exists,${_gcn})

  $(call display-node-tree,${_rn})

  $(call rm-node,${_gcn})
  $(call verify-node-does-not-exist,${_gcn})

  $(call display-node-tree,${_rn})

  $(call rm-node,${_cn})
  $(call verify-node-does-not-exist,${_cn})

  $(call Test-Info,Destroying test child node.)
  $(call rm-node,${_rn})
  $(call undeclare-descendants,${_rn})

  $(call verify-node-not-declared,${_gcn})
  $(call verify-node-not-declared,${_cn})
  $(call display-node-tree,${_rn})
  $(call undeclare-root-node,${_rn})

  $(call End-Test)
  $(call Exit-Macro)
endef

# +++++
# Postamble
# Define help only if needed.
__h := $(or \
  $(call Is-Goal,help-${SegUN}),\
  $(call Is-Goal,help-${SegID}),\
  $(call Is-Goal,help-${Seg}))
ifneq (${__h},)
define __help
$(call Display-Help-List,${SegID})
endef
${__h} := ${__help}
endif # help goal message.

$(call Exit-Segment)
else # SegId exists
$(call Check-Segment-Conflicts)
endif # SegId
# -----
