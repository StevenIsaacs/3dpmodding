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

$(call Add-Help-Section,verifiers,Macros to verify kit features.)

_macro := verify-kit-preconditions
define _help
  Verify that the variables used by the kit tests are either defined or
  undefined.

  This verifies PROJECT_NODE and PROJECT have been defined. This also verifies
  $${PROJECT}.URL and $${PROJECT}.BRANCH have not been defined.

  The $${PROJECTS_NODE} directory should not exist.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0))

$(if ${TESTING_PATH},
  $(call PASS,PROJECTS_PATH=${TESTING_PATH})
,
  $(call FAIL,PROJECTS_PATH is not defined.)
)

$(foreach _v,PROJECTS_NODE PROJECT,
  $(if ${${_v}},
    $(call PASS,Var ${_v} = ${${_v}})
    $(if $(call node-is-declared,${_v}),
      $(call FAIL,The node ${_v} should NOT be declared.)
    ,
      $(call PASS,The node ${_v} is not declared.)
      $(if $(wildcard ${TESTING_PATH}/${PROJECTS_NODE}),
        $(call FAIL,The PROJECTS_NODE directory should NOT exist.)
      ,
        $(call PASS,The PROJECTS_NODE directory does not exist.)
      )
    )
  ,
    $(call FAIL,Var ${_v} is NOT defined.)
  )
)

$(foreach _v,${PROJECT}.URL ${PROJECT}.BRANCH,
  $(if ${${_v}},
    $(call FAIL,Var ${_v} = ${${_v}})
  ,
    $(call PASS,Var ${_v} is NOT defined.)
  )
)

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
$(call Enter-Macro,$(0),$(1) $(2))

$(if $(2),
  $(call Test-Info,Verifying attributes are defined.)
  $(foreach _att,${kit_attributes},
    $(if ${$(1).${_att}},
      $(call PASS,Attribute ${$(1).${_att}} is defined.)
    ,
      $(call FAIL,Attribute ${$(1).${_att}} is NOT defined.)
    )
  )
,
  $(call Test-Info,Verifying attributes are NOT defined.)
  $(foreach _att,${kit_attributes},
    $(if ${$(1).${_att}},
      $(call FAIL,Attribute ${$(1).${_att}} is defined.)
    ,
      $(call PASS,Attribute ${$(1).${_att}} is not defined.)
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
$(call Enter-Macro,$(0),$(1) $(2))

$(if $(2),
  $(call Test-Info,Verifying attributes are defined.)
  $(foreach _node,$(1) ${kit_node_names},
    $(if $(call node-exists,${_node}),
      $(call PASS,Node ${_att} exists.)
    ,
      $(call FAIL,Node ${_att} does not exist.)
    )
  )
,
  $(call Test-Info,Verifying attributes are NOT defined.)
  $(foreach _node,$(1) ${kit_node_names},
    $(if $(call node-exists,${_node}),
      $(call FAIL,Node ${_att} exists.)
    ,
      $(call PASS,Node ${_att} does not exist.)
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

  $(call verify-kit-preconditions)
  $(if ${.Failed},
    $(call FAIL,Preconditions for ${.TestUN} are not correct.)
  ,
    $(call Expect-Error\
              Undefined variables:${PROJECT}.URL ${PROJECT}.BRANCH)
    $(call declare-kit,${PROJECT})
    $(call Verify-Error)

    $(eval ${PROJECT}.URL := local)
    $(eval ${PROJECT}.BRANCH := main)

    $(call Expect-Error,\
      Parent node ${PROJECTS_NODE} for kit ${PROJECT} is not declared.)
    $(call declare-kit,${PROJECT},${PROJECTS_NODE})
    $(call Verify-Error)
    $(call verify-kit-attributes,${PROJECT})
    $(call verify-kit-nodes,${PROJECT})

    $(call declare-root-node,${PROJECTS_NODE},${TESTING_PATH})

    $(call Expect-No-Error)
    $(call declare-kit,${PROJECT},${PROJECTS_NODE})
    $(call Verify-No-Error)
    $(call verify-kit-attributes,${PROJECT},defined)
    $(call verify-kit-nodes,${PROJECT},defined)

    $(call Expect-No-Error)
    $(call Expect-Message,Kit ${PROJECT} has already been declared.)
    $(call declare-kit,${PROJECT})
    $(call Verify-No-Error)
    $(call Verify-Message)

    $(call Expect-No-Error)
    $(call undeclare-kit,${PROJECT})
    $(call Verify-No-Error)
    $(call verify-kit-attributes,${PROJECT})
    $(call verify-kit-nodes,${PROJECT})

    $(call declare-child-node,${PROJECT},${PROJECTS_NODE})

    $(call Expect-Error,\
      A node using kit name ${PROJECT} has already been declared.)
    $(call declare-kit,${PROJECT},${PROJECTS_NODE})
    $(call Verify-Error)

    $(call declare-repo,${PROJECT})

    $(call Expect-Error,\
      A repo using kit name ${PROJECT} has already been declared.)
    $(call declare-kit,${PROJECT},${PROJECTS_NODE})
    $(call Verify-Error)

    $(call undeclare-repo,${PROJECT})
    $(call undeclare-child-node,${PROJECT})

    $(call Expect-Error,The kit ${PROJECT} has not been declared.)
    $(call undeclare-kit,${PROJECT})
    $(call Verify-Error)

    $(call declare-kit,${PROJECT})
    $(foreach _node,${${PROJECT}.children},
      $(call undeclare-child-node,${_node})
    )
    $(call undeclare-child-node,${PROJECT})

    $(call Expect-Error,Kit ${PROJECT} does not have a declared node.)
    $(call undeclare-kit,${PROJECT})
    $(call Verify-Error)

    $(call undeclare-repo,${PROJECT})

    $(call Expect-Error,Kit ${PROJECT} does not have a declared repo.)
    $(call undeclare-kit,${PROJECT})
    $(call Verify-Error)

    $(call declare-child-node,${PROJECT})
    $(call declare-repo,${PROJECT})

    $(call Expect-No-Error)
    $(call undeclare-kit,${PROJECT})
    $(call Verify-No-Error)
    $(call verify-kit-attributes,${PROJECT})

    $(call Expect-Error,The kit ${PROJECT} has not been declared.)
    $(call undeclare-kit,${PROJECT})
    $(call Verify-Error)

    $(call undeclare-root-node,${PROJECTS_NODE})

    $(eval undefine ${PROJECT}.URL)
    $(eval undefine ${PROJECT}.BRANCH)
  )
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

  $(call verify-kit-preconditions)
  $(if ${.Failed},
    $(call FAIL,Preconditions for ${.TestUN} are not correct.)
  ,
    $(eval ${PROJECT}.URL := local)
    $(eval ${PROJECT}.BRANCH := main)

    $(call declare-root-node,${PROJECTS_NODE},${TESTING_PATH})

    $(call Expect-No-Error)
    $(call mk-kit,${PROJECT})
    $(call Verify-No-Error)

    $(if $(call is-modfw-kit,${PROJECT}),
      $(call PASS,Kit ${PROJECT} is expected format.)
    ,
      $(call FAIL,Kit ${PROJECT} does not conform to ModFW kit format.)
    )

    $(call verify-kit-attributes,defined)
    $(call verify-kit-nodes,exist)

    $(call Expect-Error,\
      A node named ${PROJECT} has already been declared.)
    $(call mk-kit,${PROJECT})
    $(call Verify-Error)

    $(call rm-repo,${PROJECT})

    $(if $(call node-exists,${PROJECT}),
      $(call PASS,Node ${PROJECT} still exists.)
    ,
      $(call FAIL,Node ${PROJECT} was removed.)
    )

    $(call rm-kit,${PROJECT})
    $(call verify-kit-attributes,${PROJECT})

    $(if $(call kit-is-declared,${PROJECT}),
      $(call FAIL,Kit ${PROJECT} was not undeclared after removal.)
    ,
      $(call PASS,Kit ${PROJECT} was undeclared.)
      $(if $(call repo-is-declared,${PROJECT}),
        $(call FAIL,Kit repo ${PROJECT} was not undeclared.)
      ,
        $(call PASS,Kit repo ${PROJECT} was undeclared.)
        $(if $(call node-is-declared,${PROJECT}),
          $(call FAIL,Node ${PROJECT} was not undeclared.)
        ,
          $(call PASS,Node ${PROJECT} as undeclared,)
          $(call declare-kit,${PROJECT})
          $(if $(call node-exists,${PROJECT}),
            $(call FAIL,Kit node ${PROJECT} was not removed.)
            $(call verify-kit-nodes,${PROJECT})
          ,
            $(call PASS,Kit node ${PROJECT} was removed.)
          )
          $(call undeclare-kit,${PROJECT})
        )
      )
    )
    $(call undeclare-root-node,${PROJECTS_NODE})
    $(eval undefine ${PROJECT}.URL)
    $(eval undefine ${PROJECT}.BRANCH)
  )
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

  $(call verify-kit-preconditions)
  $(if ${.Failed},
    $(call FAIL,Preconditions for ${.TestUN} are not correct.)
  ,
    $(call declare-root-node,${PROJECTS_NODE},${TESTING_PATH})

    $(eval ${PROJECT}.URL := local)
    $(eval ${PROJECT}.BRANCH := main)

    $(call mk-kit,${PROJECT})

    $(eval ${newPROJECT}.URL := local)
    $(eval ${newPROJECT}.BRANCH := main)

    $(call Expect-No-Error)
    $(call mk-kit-from-template,${newPROJECT},${PROJECT})
    $(call Verify-No-Error)

    $(call verify-kit-attributes,${newPROJECT},defined)
    $(call verify-kit-nodes,${newPROJECT},exist)

    $(if $(call is-modfw-kit,${newPROJECT}),
      $(call PASS,Kit ${newPROJECT} is expected format.)
    ,
      $(call FAIL,Kit ${newPROJECT} does not conform to ModFW kit format.)
    )
    $(call rm-kit,${newPROJECT})
    $(call rm-kit,${PROJECT})
    $(call undeclare-root-node,${PROJECTS_NODE})

    $(eval undefine ${newPROJECT}.URL)
    $(eval undefine ${newPROJECT}.BRANCH)
    $(eval undefine ${PROJECT}.URL)
    $(eval undefine ${PROJECT}.BRANCH)
  )

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

  $(call verify-kit-preconditions)
  $(if ${.Failed},
    $(call FAIL,Preconditions for ${.TestUN} are not correct.)
  ,
    $(eval ${PROJECT}.URL := local)
    $(eval ${PROJECT}.BRANCH := main)

    $(call declare-root-node,${PROJECTS_NODE},${TESTING_PATH})
    $(call mk-node,${PROJECTS_NODE})

    $(call declare-kit,${_srcPROJECT},${PROJECTS_NODE})

    $(call mk-kit,${PROJECT})

    $(eval ${PROJECT}.URL := ${${PROJECT}.path})

    $(call Expect-No-Error)
    $(call use-kit,${PROJECT},$(PROJECTS_NODE))
    $(call Verify-No-Error)

    $(if ${Errors},
      $(call FAIL,An error occurred when using kit ${PROJECT})
    ,
      $(if ${${PROJECT}.SegID},
        $(call PASS,Make segment for kit ${PROJECT} was loaded.)
      ,
        $(call FAIL,Make segment for kit ${PROJECT} was NOT loaded.)
      )
    )
    $(call rm-kit,${PROJECT})

    $(call rm-node,${PROJECTS_NODE})
    $(call undeclare-root-node,${PROJECTS_NODE})

    $(eval undefine ${PROJECT}.URL)
    $(eval undefine ${PROJECT}.BRANCH)
  )
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
