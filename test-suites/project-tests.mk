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
so the variables PROJECTS_DIR, PROJECTS_PATH, and PROJECT are used. These
should be defined either in config.mk or test-modfw.mk.

Command line goals:
  help-${Seg} or help-${SegUN} or help-${SegID}
    Display this help.
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Use-Segment,projects)

$(call Add-Help-Section,verifiers,Macros to verify project features.)

_macro := declare-project-parents
define _help
  Declare the parents for a project. The parent structure conforms to a normal
  project structure where projects reside within projects. This basically
  declares a test node to contain the project testing nodes.
  None of the parent nodes should have been previously declared.
  If the preconditions for a projects test are not correct an error is emitted
  and the test exits.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),\
  TESTING_PATH=${TESTING_PATH}\
  PROJECTS_DIR=${PROJECTS_DIR}\
)

$(if ${TESTING_PATH},
  $(call PASS,TESTING_PATH=${TESTING_PATH})
,
  $(call FAIL,TESTING_PATH is not defined.)
)

$(foreach _v,PROJECTS_DIR,
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

$(call declare-root-node,${PROJECTS_DIR},${TESTING_PATH})

$(call Exit-Macro)
endef

_macro := undeclare-project-parents
define _help
  Teardown a project test. This reverses what was done in declare-project-parents.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0))

$(call undeclare-root-node,${PROJECTS_DIR})

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
$(call Enter-Macro,$(0),project=$(1) verify-atts=$(2))

$(if $(2),
  $(call Test-Info,Verifying attributes are defined.)
  $(if $(call project-is-declared,$(1)),
    $(call PASS,Project $(1) is declared.)
  ,
    $(call FAIL,Project $(1) is NOT declared.)
  )
  $(foreach _att,${project_attributes},
    $(if $(filter undefined,$(origin $(1).${_att})),
      $(call FAIL,Attribute $(1).${_att} is NOT defined.)
    ,
      $(call PASS,Attribute $(1).${_att}=${$(1).${_att}})
    )
  )
  $(call Test-Info,Verifying child nodes are declared.)
  $(foreach _node,${project_node_names},
    $(if $(call node-is-declared,$(1).${${_node}}),
      $(call PASS,Node $(1).${${_node}} is declared.)
    ,
      $(call FAIL,Node $(1).${${_node}} is NOT declared.)
    )
    $(if $(call is-a-child-of,$(1).${${_node}},$(1)),
      $(call PASS,Node $(1).${${_node}} is a child of project $(1).)
    ,
      $(call Test-Info,Children:${$(1).children})
      $(call FAIL,Node $(1).${${_node}} is NOT a child of project $(1).)
    )
  )
,
  $(call Test-Info,Verifying attributes are NOT defined.)
  $(if $(call project-is-declared,$(1)),
    $(call FAIL,Project $(1) is declared.)
  ,
    $(call PASS,Project $(1) is NOT declared.)
  )
  $(foreach _att,${project_attributes},
    $(if $(filter undefined,$(origin $(1).${_att})),
      $(call PASS,Attribute $(1).${_att} is not defined.)
    ,
      $(call FAIL,Attribute $(1).${_att}=${$(1).${_att}})
    )
  )
  $(call Test-Info,Verifying child nodes are NOT declared.)
  $(foreach _node,${project_node_names},
    $(if $(call node-is-declared,$(1).${${_node}}),
      $(call FAIL,Node $(1).${${_node}} should NOT be declared.)
    ,
      $(call PASS,Node $(1).${${_node}} is NOT declared.)
    )
    $(if $(call is-a-child-of,$(1).${${_node}},$(1)),
      $(call FAIL,Node $(1).${${_node}} is a child of project $(1).)
    ,
      $(call PASS,Node $(1).${${_node}} is NOT a child of project $(1).)
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
$(call Enter-Macro,$(0),project=$(1) verify-nodes=$(2))

$(if $(2),
  $(call Test-Info,Verifying project nodes exist.)

  $(foreach _node,${project_node_names},
    $(if $(call node-exists,$(1).${${_node}}),
      $(call PASS,Node $(1).${${_node}} exists.)
    ,
      $(call FAIL,Node $(1).${${_node}} does not exist.)
    )
  )
,
  $(call Test-Info,Verifying project nodes do NOT exist.)
  $(foreach _node,${project_node_names},
    $(if $(call node-exists,$(1).${${_node}}),
      $(call FAIL,Node $(1).${${_node}} exists.)
    ,
      $(call PASS,Node $(1).${${_node}} does not exist.)
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

  $(eval _project := $(0).project)
  $(call Test-Info,Project node:${_project})

  $(call declare-project-parents)

  $(if ${.Failed},
    $(call Signal-Error,Setup for ${.TestUN} failed.,exit)
  ,
    $(call Mark-Step,Verifying project required variables.)
    $(call Expect-Error,\
              Undefined variables:${_project}.URL ${_project}.BRANCH)
    $(call declare-project,${_project},${PROJECTS_DIR})
    $(call Verify-Error)

    $(eval ${_project}.URL := ${LOCAL_REPO})
    $(eval ${_project}.BRANCH := main)

    $(call Mark-Step,Verifying project is not declared.)
    $(call Expect-Error,\
      Parent node foobar for project ${_project} is not declared.)
    $(call declare-project,${_project},foobar)
    $(call Verify-Error)
    $(call verify-project-attributes,${_project})
    $(call verify-project-nodes,${_project})

    $(call Mark-Step,Verifying project node already declared.)
    $(call declare-child-node,${_project},${PROJECTS_DIR})

    $(call Expect-Error,\
      A node using project name ${_project} has already been declared.)
    $(call declare-project,${_project},${PROJECTS_DIR})
    $(call Verify-Error)
    $(call verify-project-attributes,${_project})
    $(call verify-project-nodes,${_project})

    $(call declare-repo,${_project})

    $(call Expect-Error,\
      A repo using project name ${_project} has already been declared.)
    $(call declare-project,${_project},${PROJECTS_DIR})
    $(call Verify-Error)
    $(call verify-project-attributes,${_project})
    $(call verify-project-nodes,${_project})

    $(call undeclare-repo,${_project})
    $(call undeclare-child-node,${_project})

    $(call Mark-Step,Verifying project can be declared.)
    $(call Expect-No-Error)
    $(call declare-project,${_project},${PROJECTS_DIR})
    $(call Verify-No-Error)

    $(call verify-project-attributes,${_project},defined)
    $(call verify-project-nodes,${_project})

    $(call Expect-No-Error)
    $(call Expect-Message,Using existing declaration for project ${_project}.)
    $(call declare-project,${_project},${PROJECTS_DIR})
    $(call Verify-Message)
    $(call Verify-No-Error)

    $(call Mark-Step,Verifying undeclaring the test project.)
    $(call Expect-No-Error)
    $(call undeclare-project,${_project})
    $(call Verify-No-Error)
    $(call verify-project-attributes,${_project})
    $(call verify-project-nodes,${_project})

    $(call Expect-Error,The project ${_project} has not been declared.)
    $(call undeclare-project,${_project})
    $(call Verify-Error)

    $(call Mark-Step,Verifying can redeclare the same project.)
    $(call Expect-No-Error)
    $(call declare-project,${_project},${PROJECTS_DIR})
    $(call Verify-No-Error)

    $(call Test-Info,Undeclaring project nodes.)
    $(foreach _node,${${_project}.children},
      $(call undeclare-child-node,${_node})
    )
    $(call undeclare-child-node,${_project})

    $(call Mark-Step,Verifying can't undeclare a broken project.)
    $(call Expect-Error,Project ${_project} does not have a declared node.)
    $(call undeclare-project,${_project})
    $(call Verify-Error)

    $(call undeclare-repo,${_project})

    $(call Expect-Error,Project ${_project} does not have a declared repo.)
    $(call undeclare-project,${_project})
    $(call Verify-Error)

    $(call declare-child-node,${_project},${PROJECTS_DIR})
    $(call declare-repo,${_project})

    $(call Expect-No-Error)
    $(call undeclare-project,${_project})
    $(call Verify-No-Error)
    $(call verify-project-attributes,${_project})

    $(call Expect-Error,The project ${_project} has not been declared.)
    $(call undeclare-project,${_project})
    $(call Verify-Error)

    $(eval undefine ${_project}.URL)
    $(eval undefine ${_project}.BRANCH)
  )
  $(call undeclare-project-parents)

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

  $(eval _project := $(0).project)
  $(call Test-Info,Project node:${_project})

  $(call declare-project-parents)

  $(if ${.Failed},
    $(call Signal-Error,Setup for ${.TestUN} failed.,exit)
  ,
    $(eval ${_project}.URL := ${LOCAL_REPO})
    $(eval ${_project}.BRANCH := main)

    $(call Mark-Step,Verifying project can be created.)
    $(call Expect-No-Error)
    $(call mk-project,${_project})
    $(call Verify-No-Error)

    $(call display-project,${_project})

    $(if $(call is-modfw-project,${_project}),
      $(call PASS,Project ${_project} is expected format.)
    ,
      $(call FAIL,Project ${_project} does not conform to ModFW project format.)
    )

    $(call verify-project-attributes,${_project},defined)
    $(call verify-project-nodes,${_project})

    $(call Mark-Step,Verifying project can't be created more than once.)
    $(call Expect-Message,Using existing declaration for project ${_project}.)
    $(call Expect-Error,Project ${_project} node already exists.)
    $(call mk-project,${_project})
    $(call Verify-Error)
    $(call Verify-Message)

    $(call Test-Info,Teardown.)
    $(eval undefine ${_project}.URL)
    $(eval undefine ${_project}.BRANCH)

    $(call rm-node,${PROJECTS_DIR},,y)
    $(call undeclare-project,${_project})
    $(call undeclare-project-parents)
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

  $(call Test-Info,Setup)
  $(eval _project := $(0).project)
  $(call Test-Info,Project node:${_project})
  $(eval _new_project := $(0).new-project)
  $(call Test-Info,New project node:${_new_project})

  $(call declare-project-parents)

  $(if ${.Failed},
    $(call FAIL,Preconditions for ${.TestUN} are not correct.)
  ,
    $(eval ${_project}.URL := ${LOCAL_REPO})
    $(eval ${_project}.BRANCH := main)

    $(eval ${_new_project}.URL := ${LOCAL_REPO})
    $(eval ${_new_project}.BRANCH := main)

    $(call Mark-Step,Verifying template project does NOT exist.)
    $(call Expect-Error,Template project ${_project} does not exist.)
    $(call mk-project-from-template,${_new_project},${_project})
    $(call Verify-Error)

    $(call verify-project-attributes,${_project})
    $(call verify-project-nodes,${_project})

    $(call Mark-Step,Verifying template project exists.)
    $(call mk-project,${_project})
    $(call undeclare-project,${_project})

    $(call Expect-No-Error)
    $(call mk-project-from-template,${_new_project},${_project})
    $(call Verify-No-Error)

    $(call verify-project-attributes,${_new_project},defined)
    $(call verify-project-nodes,${_new_project})

    $(if $(call is-modfw-project,${_new_project}),
      $(call PASS,Project ${_new_project} is expected format.)
    ,
      $(call FAIL,Project ${_new_project} does not conform to ModFW project format.)
    )

    $(call Mark-Step,\
      Verifying using existing project declaration and error when node exists.)

    $(call Expect-Message,\
      Using existing declaration for project ${_new_project}.)
    $(call Expect-Error,Project ${_new_project} node already exists.)
    $(call mk-project-from-template,${_new_project},${_project})
    $(call Verify-Error)
    $(call Verify-Message)

    $(call Test-Info,Teardown)
    $(eval undefine ${_new_project}.URL)
    $(eval undefine ${_new_project}.BRANCH)
    $(eval undefine ${_project}.URL)
    $(eval undefine ${_project}.BRANCH)

    $(call rm-node,${PROJECTS_DIR},,y)

    $(call undeclare-project,${_new_project})
    $(call undeclare-project,${_project})
    $(call undeclare-project-parents)
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

  $(eval _project := $(0).project)
  $(call Test-Info,Project node:${_project})

  $(call declare-project-parents)

  $(if ${.Failed},
    $(call FAIL,Preconditions for ${.TestUN} are not correct.)
  ,
    $(eval ${_project}.URL := ${LOCAL_REPO})
    $(eval ${_project}.BRANCH := main)

    $(eval _src_projects := src-projects)

    $(call Test-Info,Creating the source project repo.)
    $(call declare-root-node,${_src_projects},${TESTING_PATH})
    $(call declare-project,${_project},${_src_projects})
    $(call mk-project,${_project})

    $(eval ${_project}.URL := ${${_project}.path})
    $(call Test-Info,Clone project url:${${_project}.URL})

    $(call undeclare-project,${_project})

    $(call mk-node,${PROJECTS_DIR})

    $(call Mark-Step,Verifying using a clone of a local project.)

    $(call Expect-Message,\
      Segment ${_project} has not yet been completed.)
    $(call use-project,${_project})
    $(call Verify-Message)
    $(call verify-project-nodes,${_project},exist)

    $(if ${${_project}.${_project}.SegID},
      $(call PASS,Make segment for project ${_project} was loaded.)
    ,
      $(call FAIL,Make segment for project ${_project} was NOT loaded.)
    )

    $(call Expect-Message,\
      Project ${_project} is already in use.)
    $(call use-project,${_project})
    $(call Verify-Message)

    $(eval undefine ${_project}.URL)
    $(eval undefine ${_project}.BRANCH)

    $(call rm-node,${_src_projects},,y)

    $(call rm-node,${PROJECTS_DIR},,y)

    $(call undeclare-project,${_project})
    $(call undeclare-node,${_src_projects})
    $(call undeclare-project-parents)
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
