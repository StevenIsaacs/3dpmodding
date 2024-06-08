#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW - project test suite.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,ModFW - project test suite.)
# -----
define _help
Make segment: ${Seg}.mk

This test suite verifies the macros related to managing ModFW projects.

The focus is on managing a standard ModFW project directory structure. To do
so the variables PROJECTS_NODE, PROJECTS_PATH, and PROJECT are used. These
should be defined either in config.mk or test-modfw.mk.

Command line goals:
  help-${Seg} or help-${SegUN} or help-${SegID}
    Display this help.
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Add-Help-Section,verifiers,Macros to verify project features.)

_macro := verify-project-preconditions
define _help
  Verify that the variables used by the project tests are either defined or
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

_macro := verify-project-attributes
define _help
  Verify that the attributes for a project have or have not been defined.
  Parameters:
    1 = The name of the project.
    2 = When non-empty then the attributes should be defined.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))

$(if $(2),
  $(call Test-Info,Verifying attributes are defined.)
  $(foreach _att,${project_attributes},
    $(if ${$(1).${_att}},
      $(call PASS,Attribute ${$(1).${_att}} is defined.)
    ,
      $(call FAIL,Attribute ${$(1).${_att}} is NOT defined.)
    )
  )
,
  $(call Test-Info,Verifying attributes are NOT defined.)
  $(foreach _att,${project_attributes},
    $(if ${$(1).${_att}},
      $(call FAIL,Attribute ${$(1).${_att}} is defined.)
    ,
      $(call PASS,Attribute ${$(1).${_att}} is not defined.)
    )
  )
)
$(call Exit-Macro)
endef

_macro := verify-project-nodes
define _help
  Verify that the child nodes for a project exist.
  Parameters:
    1 = The name of the project.
    2 = When non-empty then the nodes should exist.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))

$(if $(2),
  $(call Test-Info,Verifying attributes are defined.)
  $(foreach _node,$(1) ${project_node_names},
    $(if $(call node-exists,${_node}),
      $(call PASS,Node ${_att} exists.)
    ,
      $(call FAIL,Node ${_att} does not exist.)
    )
  )
,
  $(call Test-Info,Verifying attributes are NOT defined.)
  $(foreach _node,$(1) ${project_node_names},
    $(if $(call node-exists,${_node}),
      $(call FAIL,Node ${_att} exists.)
    ,
      $(call PASS,Node ${_att} does not exist.)
    )
  )
)
$(call Exit-Macro)
endef

$(call Add-Help-Section,test-list,Project macro tests.)

$(call Declare-Suite,${Seg},Verify the projects macros.)

$(call Declare-Test,declare-project)
define _help
${.TestUN}
  Verify declaring and undeclaring projects.
endef
help-${.TestUN} := $(call ${_help})
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  node-tests.declare-child-node \
  repo-tests.declare-repo
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call verify-project-preconditions)
  $(if ${.Failed},
    $(call FAIL,Preconditions for ${.TestUN} are not correct.)
  ,
    $(call Expect-Error\
              Undefined variables:${PROJECT}.URL ${PROJECT}.BRANCH)
    $(call declare-project,${PROJECT})
    $(call Verify-Error)

    $(eval ${PROJECT}.URL := local)
    $(eval ${PROJECT}.BRANCH := main)

    $(call Expect-Error,\
      Parent node ${PROJECTS_NODE} for project ${PROJECT} is not declared.)
    $(call declare-project,${PROJECT},${PROJECTS_NODE})
    $(call Verify-Error)
    $(call verify-project-attributes,${PROJECT})
    $(call verify-project-nodes,${PROJECT})

    $(call declare-root-node,${PROJECTS_NODE},${TESTING_PATH})

    $(call Expect-No-Error)
    $(call declare-project,${PROJECT},${PROJECTS_NODE})
    $(call Verify-No-Error)
    $(call verify-project-attributes,${PROJECT},defined)
    $(call verify-project-nodes,${PROJECT},defined)

    $(call Expect-No-Error)
    $(call Expect-Message,Project ${PROJECT} has already been declared.)
    $(call declare-project,${PROJECT})
    $(call Verify-No-Error)
    $(call Verify-Message)

    $(call Expect-No-Error)
    $(call undeclare-project,${PROJECT})
    $(call Verify-No-Error)
    $(call verify-project-attributes,${PROJECT})
    $(call verify-project-nodes,${PROJECT})

    $(call declare-child-node,${PROJECT},${PROJECTS_NODE})

    $(call Expect-Error,\
      A node using project name ${PROJECT} has already been declared.)
    $(call declare-project,${PROJECT},${PROJECTS_NODE})
    $(call Verify-Error)

    $(call declare-repo,${PROJECT})

    $(call Expect-Error,\
      A repo using project name ${PROJECT} has already been declared.)
    $(call declare-project,${PROJECT},${PROJECTS_NODE})
    $(call Verify-Error)

    $(call undeclare-repo,${PROJECT})
    $(call undeclare-child-node,${PROJECT})

    $(call Expect-Error,The project ${PROJECT} has not been declared.)
    $(call undeclare-project,${PROJECT})
    $(call Verify-Error)

    $(call declare-project,${PROJECT})
    $(foreach _node,${${PROJECT}.children},
      $(call undeclare-child-node,${_node})
    )
    $(call undeclare-child-node,${PROJECT})

    $(call Expect-Error,Project ${PROJECT} does not have a declared node.)
    $(call undeclare-project,${PROJECT})
    $(call Verify-Error)

    $(call undeclare-repo,${PROJECT})

    $(call Expect-Error,Project ${PROJECT} does not have a declared repo.)
    $(call undeclare-project,${PROJECT})
    $(call Verify-Error)

    $(call declare-child-node,${PROJECT})
    $(call declare-repo,${PROJECT})

    $(call Expect-No-Error)
    $(call undeclare-project,${PROJECT})
    $(call Verify-No-Error)
    $(call verify-project-attributes,${PROJECT})

    $(call Expect-Error,The project ${PROJECT} has not been declared.)
    $(call undeclare-project,${PROJECT})
    $(call Verify-Error)

    $(call undeclare-root-node,${PROJECTS_NODE})

    $(eval undefine ${PROJECT}.URL)
    $(eval undefine ${PROJECT}.BRANCH)
  )
  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,mk-project)
define _help
${.TestUN}
  Verify making and removing project repositories.
endef
help-${.TestUN} := $(call ${_help})
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  repo-tests.mk-modfw-repo \
  ${.SuiteN}.declare-project
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call verify-project-preconditions)
  $(if ${.Failed},
    $(call FAIL,Preconditions for ${.TestUN} are not correct.)
  ,
    $(eval ${PROJECT}.URL := local)
    $(eval ${PROJECT}.BRANCH := main)

    $(call declare-root-node,${PROJECTS_NODE},${TESTING_PATH})

    $(call Expect-No-Error)
    $(call mk-project,${PROJECT})
    $(call Verify-No-Error)

    $(if $(call is-modfw-project,${PROJECT}),
      $(call PASS,Project ${PROJECT} is expected format.)
    ,
      $(call FAIL,Project ${PROJECT} does not conform to ModFW project format.)
    )

    $(call verify-project-attributes,defined)
    $(call verify-project-nodes,exist)

    $(call Expect-Error,\
      A node named ${PROJECT} has already been declared.)
    $(call mk-project,${PROJECT})
    $(call Verify-Error)

    $(call rm-repo,${PROJECT})

    $(if $(call node-exists,${PROJECT}),
      $(call PASS,Node ${PROJECT} still exists.)
    ,
      $(call FAIL,Node ${PROJECT} was removed.)
    )

    $(call rm-project,${PROJECT})
    $(call verify-project-attributes,${PROJECT})

    $(if $(call project-is-declared,${PROJECT}),
      $(call FAIL,Project ${PROJECT} was not undeclared after removal.)
    ,
      $(call PASS,Project ${PROJECT} was undeclared.)
      $(if $(call repo-is-declared,${PROJECT}),
        $(call FAIL,Project repo ${PROJECT} was not undeclared.)
      ,
        $(call PASS,Project repo ${PROJECT} was undeclared.)
        $(if $(call node-is-declared,${PROJECT}),
          $(call FAIL,Node ${PROJECT} was not undeclared.)
        ,
          $(call PASS,Node ${PROJECT} as undeclared,)
          $(call declare-project,${PROJECT})
          $(if $(call node-exists,${PROJECT}),
            $(call FAIL,Project node ${PROJECT} was not removed.)
            $(call verify-project-nodes,${PROJECT})
          ,
            $(call PASS,Project node ${PROJECT} was removed.)
          )
          $(call undeclare-project,${PROJECT})
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

$(call Declare-Test,mk-project-from-template)
define _help
${.TestUN}
  Verify making a new project using an existing project as a template.
endef
help-${.TestUN} := $(call ${_help})
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.mk-project
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call verify-project-preconditions)
  $(if ${.Failed},
    $(call FAIL,Preconditions for ${.TestUN} are not correct.)
  ,
    $(call declare-root-node,${PROJECTS_NODE},${TESTING_PATH})

    $(eval ${PROJECT}.URL := local)
    $(eval ${PROJECT}.BRANCH := main)

    $(call mk-project,${PROJECT})

    $(eval ${newPROJECT}.URL := local)
    $(eval ${newPROJECT}.BRANCH := main)

    $(call Expect-No-Error)
    $(call mk-project-from-template,${newPROJECT},${PROJECT})
    $(call Verify-No-Error)

    $(call verify-project-attributes,${newPROJECT},defined)
    $(call verify-project-nodes,${newPROJECT},exist)

    $(if $(call is-modfw-project,${newPROJECT}),
      $(call PASS,Project ${newPROJECT} is expected format.)
    ,
      $(call FAIL,Project ${newPROJECT} does not conform to ModFW project format.)
    )
    $(call rm-project,${newPROJECT})
    $(call rm-project,${PROJECT})
    $(call undeclare-root-node,${PROJECTS_NODE})

    $(eval undefine ${newPROJECT}.URL)
    $(eval undefine ${newPROJECT}.BRANCH)
    $(eval undefine ${PROJECT}.URL)
    $(eval undefine ${PROJECT}.BRANCH)
  )

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,use-project)
define _help
${.TestUN}
  Verify using a project.
endef
help-${.TestUN} := $(call ${_help})
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.mk-project
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call verify-project-preconditions)
  $(if ${.Failed},
    $(call FAIL,Preconditions for ${.TestUN} are not correct.)
  ,
    $(eval ${PROJECT}.URL := local)
    $(eval ${PROJECT}.BRANCH := main)

    $(call declare-root-node,${PROJECTS_NODE},${TESTING_PATH})
    $(call mk-node,${PROJECTS_NODE})

    $(call declare-project,${_srcPROJECT},${PROJECTS_NODE})

    $(call mk-project,${PROJECT})

    $(eval ${PROJECT}.URL := ${${PROJECT}.path})

    $(call Expect-No-Error)
    $(call use-project,${PROJECT},$(PROJECTS_NODE))
    $(call Verify-No-Error)

    $(if ${Errors},
      $(call FAIL,An error occurred when using project ${PROJECT})
    ,
      $(if ${${PROJECT}.SegID},
        $(call PASS,Make segment for project ${PROJECT} was loaded.)
      ,
        $(call FAIL,Make segment for project ${PROJECT} was NOT loaded.)
      )
    )
    $(call rm-project,${PROJECT})

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
