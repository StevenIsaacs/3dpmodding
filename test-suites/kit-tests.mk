#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW - kit test suite.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,ModFW - kit test suite.)
# -----
define _help
Make segment: ${Seg}.mk

This test suite verifies the macros related to managing ModFW kits.

The focus is on managing a standard ModFW kit directory structure. To do
so the variables PROJECTS_NODE, PROJECTS_PATH, and PROJECT are used. These
should be defined either in config.mk or test-modfw.mk.

Command line goals:
  help-${Seg} or help-${SegUN} or help-${SegID}
    Display this help.
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Use-Segment,kits)

$(call Add-Help-Section,verifiers,Macros to verify kit features.)

_var := kit_project_node
${_var} := ${Seg}
define _help
${_var}
  The name of the project node in which test kits are created.
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_macro := declare-kit-parents
define _help
  Declare the parents for a kit. The parent structure conforms to a normal
  project structure where kits reside within projects. This basically declares
  a test node to contain the kit testing nodes.
  None of the parent nodes should have been previously declared.
  If the preconditions for a kits test are not correct an error is emitted and
  the test exits.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),\
  TESTING_PATH=${TESTING_PATH}\
  PROJECTS_NODE=${PROJECTS_NODE}\
  kit_project_node=${kit_project_node}\
  KITS_NODE=${KITS_NODE}\
)

$(if ${TESTING_PATH},
  $(call PASS,TESTING_PATH=${TESTING_PATH})
,
  $(call FAIL,TESTING_PATH is not defined.)
)

$(foreach _v,PROJECTS_NODE kit_project_node KITS_NODE,
  $(if ${${_v}},
    $(call PASS,Var ${_v} = ${${_v}})
    $(if $(call node-is-declared,${_v}),
      $(call FAIL,The node ${_v} should NOT be declared.)
    ,
      $(call PASS,The node ${_v} is not declared.)
    )
  ,
    $(call FAIL,Var ${_v} is NOT defined.)
  )
)

$(call declare-root-node,${PROJECTS_NODE},${TESTING_PATH})
$(call declare-child-node,${kit_project_node},${PROJECTS_NODE})
$(call declare-child-node,${KITS_NODE},${kit_project_node})

$(if $(call node-exists,${kit_project_node}),
  $(call FAIL,The node ${kit_project_node} should NOT exist.)
,
  $(call PASS,The node ${kit_project_node} does not exist.)
)

$(if ${.Failed},
  $(call FAIL,Prerequisites for a kit test are not correct.,exit)
)

$(call Exit-Macro)
endef

_macro := undeclare-kit-parents
define _help
  Teardown a kit test. This reverses what was done in declare-kit-parents.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0))

$(call undeclare-node-descendants,${PROJECTS_NODE})
$(call undeclare-root-node,${PROJECTS_NODE})

$(call Exit-Macro)
endef

_macro := verify-kit-attributes
define _help
  Verify that the attributes for a kit have or have not been defined.
  Parameters:
    1 = The name of the kit.
    2 = When non-empty then the attributes should be defined.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),kit=$(1) verify-atts=$(2))

$(if $(2),
  $(call Test-Info,Verifying attributes are defined.)
  $(if $(call kit-is-declared,$(1)),
    $(call PASS,Kit $(1) is declared.)
  ,
    $(call FAIL,Kit $(1) is NOT declared.)
  )
  $(foreach _att,${kit_attributes},
    $(if $(filter undefined,$(origin $(1).${_att})),
      $(call FAIL,Attribute $(1).${_att} is NOT defined.)
    ,
      $(call PASS,Attribute $(1).${_att}=${$(1).${_att}})
    )
  )
  $(call Test-Info,Verifying child nodes are declared.)
  $(foreach _node,${kit_node_names},
    $(if $(call node-is-declared,$(1).${${_node}}),
      $(call PASS,Node $(1).${${_node}} is declared.)
    ,
      $(call FAIL,Node $(1).${${_node}} is NOT declared.)
    )
    $(if $(call is-a-child-of,$(1).${${_node}},$(1)),
      $(call PASS,Node $(1).${${_node}} is a child of kit $(1).)
    ,
      $(call Test-Info,Children:${$(1).children})
      $(call FAIL,Node $(1).${${_node}} is NOT a child of kit $(1).)
    )
  )
,
  $(call Test-Info,Verifying attributes are NOT defined.)
  $(if $(call kit-is-declared,$(1)),
    $(call FAIL,Kit $(1) is declared.)
  ,
    $(call PASS,Kit $(1) is NOT declared.)
  )
  $(foreach _att,${kit_attributes},
    $(if $(filter undefined,$(origin $(1).${_att})),
      $(call PASS,Attribute $(1).${_att} is not defined.)
    ,
      $(call FAIL,Attribute $(1).${_att}=${$(1).${_att}})
    )
  )
  $(call Test-Info,Verifying child nodes are NOT declared.)
  $(foreach _node,${kit_node_names},
    $(if $(call node-is-declared,$(1).${${_node}}),
      $(call FAIL,Node $(1).${${_node}} should NOT be declared.)
    ,
      $(call PASS,Node $(1).${${_node}} is NOT declared.)
    )
    $(if $(call is-a-child-of,$(1).${${_node}},$(1)),
      $(call FAIL,Node $(1).${${_node}} is a child of kit $(1).)
    ,
      $(call PASS,Node $(1).${${_node}} is NOT a child of kit $(1).)
    )
  )
)
$(call Exit-Macro)
endef

_macro := verify-kit-nodes
define _help
  Verify that the child nodes for a kit exist.
  Parameters:
    1 = The name of the kit.
    2 = When non-empty then the nodes should exist.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),kit=$(1) verify-nodes=$(2))

$(if $(2),
  $(call Test-Info,Verifying kit nodes exist.)

  $(foreach _node,${kit_node_names},
    $(if $(call node-exists,$(1).${${_node}}),
      $(call PASS,Node $(1).${${_node}} exists.)
    ,
      $(call FAIL,Node $(1).${${_node}} does not exist.)
    )
  )
,
  $(call Test-Info,Verifying kit nodes do NOT exist.)
  $(foreach _node,${kit_node_names},
    $(if $(call node-exists,$(1).${${_node}}),
      $(call FAIL,Node $(1).${${_node}} exists.)
    ,
      $(call PASS,Node $(1).${${_node}} does not exist.)
    )
  )
)
$(call Exit-Macro)
endef

$(call Add-Help-Section,test-list,Kit macro tests.)

$(call Declare-Suite,${Seg},Verify the kits macros.)

$(call Declare-Test,declare-kit)
define _help
${.TestUN}
  Verify declaring and undeclaring kits.
endef
help-${.TestUN} := $(call ${_help})
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  node-tests.declare-child-node \
  repo-tests.declare-repo
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _kit := $(0).kit)
  $(call Test-Info,Kit node:${_kit})

  $(call declare-kit-parents)

  $(if ${.Failed},
    $(call Signal-Error,Setup for ${.TestUN} failed.,exit)
  ,
    $(call Mark-Step,Verifying kit required variables.)
    $(call Expect-Error,\
              Undefined variables:${_kit}.URL ${_kit}.BRANCH)
    $(call declare-kit,${_kit})
    $(call Verify-Error)

    $(eval ${_kit}.URL := local)
    $(eval ${_kit}.BRANCH := main)

    $(call Mark-Step,Verifying kit is not declared.)
    $(call Expect-Error,\
      Parent node foobar for kit ${_kit} is not declared.)
    $(call declare-kit,${_kit},foobar)
    $(call Verify-Error)
    $(call verify-kit-attributes,${_kit})
    $(call verify-kit-nodes,${_kit})

    $(call Mark-Step,Verifying kit node already declared.)
    $(call declare-child-node,${_kit},${KITS_NODE})

    $(call Expect-Error,\
      A node using kit name ${_kit} has already been declared.)
    $(call declare-kit,${_kit},${KITS_NODE})
    $(call Verify-Error)
    $(call verify-kit-attributes,${_kit})
    $(call verify-kit-nodes,${_kit})

    $(call declare-repo,${_kit})

    $(call Expect-Error,\
      A repo using kit name ${_kit} has already been declared.)
    $(call declare-kit,${_kit},${KITS_NODE})
    $(call Verify-Error)
    $(call verify-kit-attributes,${_kit})
    $(call verify-kit-nodes,${_kit})

    $(call undeclare-repo,${_kit})
    $(call undeclare-child-node,${_kit})

    $(call Mark-Step,Verifying kit can be declared.)
    $(call Expect-No-Error)
    $(call declare-kit,${_kit},${KITS_NODE})
    $(call Verify-No-Error)

    $(call verify-kit-attributes,${_kit},defined)
    $(call verify-kit-nodes,${_kit})

    $(call Expect-No-Error)
    $(call Expect-Message,Kit ${_kit} has already been declared.)
    $(call declare-kit,${_kit},${KITS_NODE})
    $(call Verify-Message)
    $(call Verify-No-Error)

    $(call Mark-Step,Verifying undeclaring the test kit.)
    $(call Expect-No-Error)
    $(call undeclare-kit,${_kit})
    $(call Verify-No-Error)
    $(call verify-kit-attributes,${_kit})
    $(call verify-kit-nodes,${_kit})

    $(call Expect-Error,The kit ${_kit} has not been declared.)
    $(call undeclare-kit,${_kit})
    $(call Verify-Error)

    $(call Mark-Step,Verifying can redeclare the same kit.)
    $(call Expect-No-Error)
    $(call declare-kit,${_kit},${KITS_NODE})
    $(call Verify-No-Error)

    $(call Test-Info,Undeclaring kit nodes.)
    $(foreach _node,${${_kit}.children},
      $(call undeclare-child-node,${_node})
    )
    $(call undeclare-child-node,${_kit})

    $(call Mark-Step,Verifying can't undeclare a broken kit.)
    $(call Expect-Error,Kit ${_kit} does not have a declared node.)
    $(call undeclare-kit,${_kit})
    $(call Verify-Error)

    $(call undeclare-repo,${_kit})

    $(call Expect-Error,Kit ${_kit} does not have a declared repo.)
    $(call undeclare-kit,${_kit})
    $(call Verify-Error)

    $(call declare-child-node,${_kit},${KITS_NODE})
    $(call declare-repo,${_kit})

    $(call Expect-No-Error)
    $(call undeclare-kit,${_kit})
    $(call Verify-No-Error)
    $(call verify-kit-attributes,${_kit})

    $(call Expect-Error,The kit ${_kit} has not been declared.)
    $(call undeclare-kit,${_kit})
    $(call Verify-Error)

    $(eval undefine ${_kit}.URL)
    $(eval undefine ${_kit}.BRANCH)
  )
  $(call undeclare-kit-parents)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,mk-kit)
define _help
${.TestUN}
  Verify making and removing kit repositories.
endef
help-${.TestUN} := $(call ${_help})
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  repo-tests.mk-modfw-repo \
  ${.SuiteN}.declare-kit
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _kit := $(0).kit)
  $(call Test-Info,Kit node:${_kit})

  $(call declare-kit-parents)

  $(if ${.Failed},
    $(call Signal-Error,Setup for ${.TestUN} failed.,exit)
  ,
    $(eval ${_kit}.URL := local)
    $(eval ${_kit}.BRANCH := main)

    $(call Mark-Step,Verifying kit can be created.)
    $(call Expect-No-Error)
    $(call mk-kit,${_kit})
    $(call Verify-No-Error)

    $(call display-kit,${_kit})

    $(if $(call is-modfw-kit,${_kit}),
      $(call PASS,Kit ${_kit} is expected format.)
    ,
      $(call FAIL,Kit ${_kit} does not conform to ModFW kit format.)
    )

    $(call verify-kit-attributes,${_kit},defined)
    $(call verify-kit-nodes,${_kit})

    $(call Mark-Step,Verifying kit can't be created more than once.)
    $(call Expect-Message,Kit ${_kit} has already been declared.)
    $(call Expect-Error,Kit ${_kit} node already exists.)
    $(call mk-kit,${_kit})
    $(call Verify-Error)
    $(call Verify-Message)

    $(call Test-Info,Teardown.)
    $(eval undefine ${_kit}.URL)
    $(eval undefine ${_kit}.BRANCH)

    $(call undeclare-kit,${_kit})
  )
  $(call rm-node,${PROJECTS_NODE})
  $(call undeclare-kit-parents)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,mk-kit-from-template)
define _help
${.TestUN}
  Verify making a new kit using an existing kit as a template.
endef
help-${.TestUN} := $(call ${_help})
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.mk-kit
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _kit := $(0).kit)
  $(call Test-Info,Kit node:${_kit})
  $(eval _new_kit := $(0).new-kit)
  $(call Test-Info,New kit node:${_new_kit})

  $(call declare-kit-parents)

  $(if ${.Failed},
    $(call FAIL,Preconditions for ${.TestUN} are not correct.)
  ,
    $(eval ${_kit}.URL := local)
    $(eval ${_kit}.BRANCH := main)

    $(eval ${_new_kit}.URL := local)
    $(eval ${_new_kit}.BRANCH := main)

    $(call Mark-Step,Verifying template kit must exist.)
    $(call Expect-Error,Template kit ${_kit} does not exist.)
    $(call mk-kit-from-template,${_new_kit},${_kit})
    $(call Verify-Error)

    $(call verify-kit-attributes,${_kit})
    $(call verify-kit-nodes,${_kit})

    $(call mk-kit,${_kit})

    $(call Mark-Step,Verifying kit can be created.)
    $(call Expect-No-Error)
    $(call mk-kit-from-template,${_new_kit},${_kit})
    $(call Verify-No-Error)

    $(call verify-kit-attributes,${_new_kit},defined)
    $(call verify-kit-nodes,${_new_kit})

    $(if $(call is-modfw-kit,${_new_kit}),
      $(call PASS,Kit ${_new_kit} is expected format.)
    ,
      $(call FAIL,Kit ${_new_kit} does not conform to ModFW kit format.)
    )

    $(call Mark-Step,\
      Verifying can't make kit if node has already been declared.)
    $(call Expect-Message,Kit ${_new_kit} has already been declared.)
    $(call Expect-Error,Kit ${_new_kit} node already exists.)
    $(call mk-kit-from-template,${_new_kit},${_kit})
    $(call Verify-Error)
    $(call Verify-Message)

    $(eval undefine ${_new_kit}.URL)
    $(eval undefine ${_new_kit}.BRANCH)
    $(eval undefine ${_kit}.URL)
    $(eval undefine ${_kit}.BRANCH)

    $(call undeclare-kit,${_new_kit})
    $(call undeclare-kit,${_kit})
  )

  $(call rm-node,${PROJECTS_NODE})
  $(call undeclare-kit-parents)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,use-kit)
define _help
${.TestUN}
  Verify using a kit.
endef
help-${.TestUN} := $(call ${_help})
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.mk-kit
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _kit := $(0).kit)
  $(call Test-Info,Kit node:${_kit})

  $(call declare-kit-parents)

  $(if ${.Failed},
    $(call FAIL,Preconditions for ${.TestUN} are not correct.)
  ,
    $(eval ${_kit}.URL := local)
    $(eval ${_kit}.BRANCH := main)

    $(call Test-Info,Creating the source kit repo.)
    $(call declare-kit,${_kit},${kit_project_node})
    $(call mk-kit,${_kit})

    $(eval ${_kit}.URL := ${${_kit}.path})

    $(call undeclare-kit,${_kit})

    $(call mk-node,${KITS_NODE})

    $(call Mark-Step,Verifying message that kit segment is incomplete.)
    $(call Expect-Message,\
      Segment ${_kit} has not yet been completed.)
    $(call use-kit,${_kit})
    $(call Verify-Message)
    $(call verify-kit-nodes,${_kit},exist)

    $(if ${${_kit}.${_kit}.SegID},
      $(call PASS,Make segment for kit ${_kit} was loaded.)
    ,
      $(call FAIL,Make segment for kit ${_kit} was NOT loaded.)
    )
    $(eval undefine ${_kit}.URL)
    $(eval undefine ${_kit}.BRANCH)


    $(call undeclare-kit,${_kit})
  )
  $(call rm-node,${PROJECTS_NODE})
  $(call undeclare-kit-parents)

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
${_h} := $(call ${_help})
endif # help goal message.

$(call End-Declare-Suite)

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
