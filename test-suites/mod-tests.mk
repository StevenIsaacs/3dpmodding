#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW - mod test suite.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,ModFW - mod test suite.)
# -----
define _help
Make segment: ${Seg}.mk

This test suite verifies the macros related to managing ModFW mods.

The focus is on managing a standard ModFW mod directory structure. To do
so the variables PROJECTS_NODE, PROJECTS_PATH, and PROJECT are used. These
should be defined either in config.mk or test-modfw.mk.

Unlike other test suites this suite uses another test suite, namely kit-tests.
This is because mods are contained within kits which means a kit must be
declared and possibly be created before mod tests can be run.

Command line goals:
  help-${Seg} or help-${SegUN} or help-${SegID}
    Display this help.
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Use-Segment,mods)
$(call Use-Segment,kit-tests)

$(call Add-Help-Section,verifiers,Macros to verify mod features.)

_macro := verify-mod-attributes
define _help
  Verify that the attributes for a mod have or have not been defined.
  Parameters:
    1 = The name of the mod.
    2 = When non-empty then the attributes should be defined.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),mod=$(1) verify-atts=$(2))

$(if $(2),
  $(call Test-Info,Verifying attributes are defined.)
  $(if $(call mod-is-declared,$(1)),
    $(call PASS,Mod $(1) is declared.)
  ,
    $(call FAIL,Mod $(1) is NOT declared.)
  )
  $(if $(call node-is-declared,${$(1).parent}),
    $(call PASS,Mod parent ${$(1).parent} is declared.)
  ,
    $(call FAIL,Mod parent ${$(1).parent} is NOT declared.)
  )
  $(if $(call kit-is-declared,${$(1).kit}),
    $(call PASS,Mod kit ${$(1).kit} is declared.)
  ,
    $(call FAIL,Mod kit ${$(1).kit} is NOT declared.)
  )
  $(if $(filter ${$(1).parent},${$(1).kit}),
    $(call Test-Info,Parent=${$(1).parent} Kit=${$(1).kit})
    $(call FAIL,Mod $(1) parent and kit are the same.)
  ,
    $(call PASS,Mod $(1) parent and kit are NOT the same.)
  )
  $(foreach _att,${mod_attributes},
    $(if $(filter undefined,$(origin $(1).${_att})),
      $(call FAIL,Attribute $(1).${_att} is NOT defined.)
    ,
      $(call PASS,Attribute $(1).${_att}=${$(1).${_att}})
    )
  )
  $(call Test-Info,Verifying child nodes are declared.)
  $(foreach _node,${mod_node_names},
    $(if $(call node-is-declared,$(1).${${_node}}),
      $(call PASS,Node $(1).${${_node}} is declared.)
    ,
      $(call FAIL,Node $(1).${${_node}} is NOT declared.)
    )
    $(if $(call is-a-child-of,$(1).${${_node}},$(1)),
      $(call PASS,Node $(1).${${_node}} is a child of mod $(1).)
    ,
      $(call Test-Info,Children:${$(1).children})
      $(call FAIL,Node $(1).${${_node}} is NOT a child of mod $(1).)
    )
  )
,
  $(call Test-Info,Verifying attributes are NOT defined.)
  $(if $(call mod-is-declared,$(1)),
    $(call FAIL,Mod $(1) is declared.)
  ,
    $(call PASS,Mod $(1) is NOT declared.)
  )
  $(foreach _att,${mod_attributes},
    $(if $(filter undefined,$(origin $(1).${_att})),
      $(call PASS,Attribute $(1).${_att} is not defined.)
    ,
      $(call FAIL,Attribute $(1).${_att}=${$(1).${_att}})
    )
  )
  $(call Test-Info,Verifying child nodes are NOT declared.)
  $(foreach _node,${mod_node_names},
    $(if $(call node-is-declared,$(1).${${_node}}),
      $(call FAIL,Node $(1).${${_node}} should NOT be declared.)
    ,
      $(call PASS,Node $(1).${${_node}} is NOT declared.)
    )
    $(if $(call is-a-child-of,$(1).${${_node}},$(1)),
      $(call FAIL,Node $(1).${${_node}} is a child of mod $(1).)
    ,
      $(call PASS,Node $(1).${${_node}} is NOT a child of mod $(1).)
    )
  )
)
$(call Exit-Macro)
endef

_macro := verify-mod-nodes
define _help
  Verify that the child nodes for a mod exist.
  Parameters:
    1 = The name of the mod.
    2 = When non-empty then the nodes should exist.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),mod=$(1) verify-nodes=$(2))

$(if $(2),
  $(call Test-Info,Verifying mod nodes exist.)

  $(foreach _node,${mod_node_names},
    $(if $(call node-exists,$(1).${${_node}}),
      $(call PASS,Node $(1).${${_node}} exists.)
    ,
      $(call FAIL,Node $(1).${${_node}} does not exist.)
    )
  )
,
  $(call Test-Info,Verifying mod nodes do NOT exist.)
  $(foreach _node,${mod_node_names},
    $(if $(call node-exists,$(1).${${_node}}),
      $(call FAIL,Node $(1).${${_node}} exists.)
    ,
      $(call PASS,Node $(1).${${_node}} does not exist.)
    )
  )
)
$(call Exit-Macro)
endef

$(call Add-Help-Section,test-list,Mod macro tests.)

$(call Declare-Suite,${Seg},Verify the mods macros.)

_macro := verify-mod-reference
define _help
${_macro}
  Returns a non-empty value if a mod reference is valid.
  Parameters:
    1 = The reference to check.
    2 = Non-empty indicates should be a valid reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),kit.mod=$(1) pass_fail=$(2))

$(eval _vr := $(call is-valid-mod-reference,$(1)))
$(call Test-Info,Macro is-valid-mod-reference returned: ${_vr})
$(if $(2),
  $(if ${_vr},
    $(call PASS,$(1) is a valid kit.mod reference.)
  ,
    $(call FAIL,$(1) SHOULD be a valid kit.mod reference)
  )
,
  $(if ${_vr},
    $(call FAIL,$(1) SHOULD NOT be a valid kit.mod reference.)
  ,
    $(call PASS,$(1) is not a valid kit.mod reference)
  )
)

$(call Exit-Macro)
endef

$(call Declare-Test,is-valid-mod-reference)
define _help
${.TestUN}
  Verify mod references.
endef
help-${.TestUN} := $(call ${_help})
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs :=
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(call verify-mod-reference,kit.mod,PASS)
  $(call verify-mod-reference,dotted.kit.mod)
  $(call verify-mod-reference,$(call To-Shell-Var,dotted.kit).mod,PASS)
  $(call verify-mod-reference,dotted.kit_mod,PASS)
  $(call verify-mod-reference,dotted.kit-mod,PASS)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,declare-mod)
define _help
${.TestUN}
  Verify declaring and undeclaring mods.
endef
help-${.TestUN} := $(call ${_help})
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  ${.SuiteN}.is-valid-mod-reference \
  kit-tests.declare-kit
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _kit := $(call To-Shell-Var,$(0).test-kit))
  $(eval _mod := test-mod)
  $(call Test-Info,Mod reference:${_mod_ref})

  $(call declare-kit-parents)

  $(if ${.Failed},
    $(call Signal-Error,Setup for ${.TestUN} failed.,exit)
  ,
    $(call Mark-Step,Verifying invalid mod reference.)
    $(eval _mod_ref := dotted.${_kit}.${_mod})
    $(call Expect-Error,\
              Mod ${_mod_ref} is NOT a valid mod reference.)
    $(call declare-mod,${_mod_ref})
    $(call Verify-Error)

    $(eval _mod_ref := ${_kit}.${_mod})

    $(call Mark-Step,Verifying mod required variables.)
    $(call Expect-No-Error,\
              Undefined variables:${_kit}.URL ${_kit}.BRANCH)
    $(call declare-mod,${_mod_ref})
    $(call Verify-No-Error)
    $(call undeclare-mod,${_mod_ref})

    $(call Mark-Step,Verifying mod is not declared.)
    $(call verify-mod-attributes,${_mod_ref})
    $(call verify-mod-nodes,${_mod_ref})

    $(call Mark-Step,Verifying kit is not declared.)
    $(call verify-kit-attributes,${_kit})
    $(call verify-kit-nodes,${_kit})

    $(call Mark-Step,Verifying mod node already declared.)
    $(call declare-child-node,${_mod_ref},${PROJECTS_NODE})

    $(call Expect-Error,\
      A node having the mod name ${_mod_ref} has already been declared.)
    $(call declare-mod,${_mod_ref})
    $(call Verify-Error)
    $(call verify-mod-attributes,${_mod_ref})
    $(call verify-mod-nodes,${_mod_ref})

    $(call undeclare-child-node,${_mod_ref})

    $(eval ${_kit}.URL := ${LOCAL_REPO})
    $(eval ${_kit}.BRANCH := main)

    $(call Mark-Step,Verifying mod can be declared.)
    $(call Expect-No-Error)
    $(call declare-mod,${_mod_ref})
    $(call Verify-No-Error)

    $(call verify-mod-attributes,${_mod_ref},defined)
    $(call verify-mod-nodes,${_mod_ref})

    $(call Expect-No-Error)
    $(call Expect-Message,Mod ${_mod_ref} has already been declared.)
    $(call declare-mod,${_mod_ref})
    $(call Verify-Message)
    $(call Verify-No-Error)

    $(call Mark-Step,Verifying undeclaring the test mod.)
    $(call Expect-No-Error)
    $(call undeclare-mod,${_mod_ref})
    $(call Verify-No-Error)
    $(call verify-mod-attributes,${_mod_ref})
    $(call verify-mod-nodes,${_mod_ref})

    $(call Expect-Error,The mod ${_mod_ref} has not been declared.)
    $(call undeclare-mod,${_mod_ref})
    $(call Verify-Error)

    $(call Mark-Step,Verifying can redeclare the same mod.)
    $(call Expect-No-Error)
    $(call declare-mod,${_mod_ref})
    $(call Verify-No-Error)

    $(call Mark-Step,Undeclaring mod nodes.)
    $(foreach _node,${${_mod_ref}.children},
      $(call undeclare-child-node,${_node})
    )
    $(call undeclare-child-node,${_mod_ref})

    $(call Mark-Step,Verifying can't undeclare a broken mod.)
    $(call Expect-Error,Mod ${_mod_ref} does not have a declared node.)
    $(call undeclare-mod,${_mod_ref})
    $(call Verify-Error)

    $(call declare-child-node,${_mod_ref},${_kit},${_mod})

    $(call Expect-No-Error)
    $(call undeclare-mod,${_mod_ref})
    $(call Verify-No-Error)
    $(call verify-mod-attributes,${_mod_ref})

    $(call Expect-Error,The mod ${_mod_ref} has not been declared.)
    $(call undeclare-mod,${_mod_ref})
    $(call Verify-Error)

    $(eval undefine ${_kit}.URL)
    $(eval undefine ${_kit}.BRANCH)
  )
  $(call undeclare-kit-parents)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,mk-mod)
define _help
${.TestUN}
  Verify making and removing mod repositories.
endef
help-${.TestUN} := $(call ${_help})
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := \
  ${.SuiteN}.declare-mod \
  kit-tests.mk-kit
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _kit := $(call To-Shell-Var,$(0).test-kit))
  $(eval _mod := test-mod)
  $(eval _mod_ref := ${_kit}.${_mod})
  $(call Test-Info,Mod node:${_mod})

  $(eval ${_kit}.URL := ${LOCAL_REPO})
  $(eval ${_kit}.BRANCH := main)

  $(call declare-kit-parents)
  $(call mk-node,${PROJECT}.${KITS_NODE})

  $(if ${Errors},
    $(call Signal-Error,Setup for ${.TestUN} failed.,exit)
  ,
    $(call Mark-Step,Verifying kit must exist before installing mod.)
    $(call Expect-Message,An error occurred when installing kit ${_kit})
    $(call mk-mod,${_mod_ref})
    $(call Verify-Message)

    $(call Clear-Errors)

    $(call Mark-Step,Verifying mod can be created.)
    $(call mk-kit,${_kit})
    $(call Expect-No-Error)
    $(call mk-mod,${_mod_ref})
    $(call Verify-No-Error)

    $(call display-mod,${_mod_ref})

    $(call verify-mod-attributes,${_mod_ref},defined)
    $(call verify-mod-nodes,${_mod_ref})

    $(eval _mfwf := $(call is-modfw-mod,${_mod_ref}))
    $(call Test-Info,is-modfw-mod returned: ${_mfwf})
    $(if ${_mfwf},
      $(call PASS,Mod ${_mod_ref} is expected format.)
    ,
      $(call FAIL,Mod ${_mod_ref} does not conform to ModFW mod format.)
    )

    $(call Mark-Step,Verifying mod can't be created more than once.)
    $(call Expect-Message,Mod ${_mod_ref} has already been declared.)
    $(call Expect-Error,A node ${_mod_ref} already exists.)
    $(call mk-mod,${_mod_ref})
    $(call Verify-Error)
    $(call Verify-Message)

    $(call Test-Info,Teardown.)
    $(eval undefine ${_kit}.URL)
    $(eval undefine ${_kit}.BRANCH)

    $(call undeclare-mod,${_mod_ref})
    $(call undeclare-kit,${_kit})
  )
  $(call rm-node,${PROJECTS_NODE},,y)
  $(call undeclare-kit-parents)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,mk-mod-from-template)
define _help
${.TestUN}
  Verify making a new mod using an existing mod as a template. Both mods
  are contained in the same kit.
endef
help-${.TestUN} := $(call ${_help})
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.mk-mod
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _kit := $(call To-Shell-Var,$(0).test-kit))
  $(eval _mod := test-mod)
  $(eval _mod_ref := ${_kit}.${_mod})
  $(eval _new_mod := new-mod)
  $(eval _new_mod_ref := ${_kit}.${_new_mod})
  $(call Test-Info,Mod node:${_mod})
  $(call Test-Info,New mod node:${_new_mod})

  $(eval ${_kit}.URL := ${LOCAL_REPO})
  $(eval ${_kit}.BRANCH := main)

  $(call declare-kit-parents)
  $(call mk-node,${PROJECT}.${KITS_NODE})
  $(call mk-kit,${_kit})

  $(if ${Errors},
    $(call Signal-Error,Setup for ${.TestUN} failed.,exit)
  ,
    $(call Expect-Error,Template mod ${_mod_ref} does not exist.)
    $(call mk-mod-from-template,${_new_mod_ref},${_mod_ref})
    $(call Verify-Error)

    $(call verify-mod-attributes,${_new_mod_ref})
    $(call verify-mod-nodes,${_new_mod_ref})

    $(call mk-mod,${_mod_ref})

    $(call Mark-Step,Verifying can create new mod from template.)
    $(call Expect-No-Error)
    $(call mk-mod-from-template,${_new_mod_ref},${_mod_ref})
    $(call Verify-No-Error)

    $(call Mark-Step,Verifying mods have been declared.)
    $(foreach _m,${_mod_ref} ${_new_mod_ref},
      $(if $(call mod-is-declared,${_m}),
        $(call PASS,Mod ${_m} has been declared.)
      ,
        $(call FAIL,Mod ${_m} has NOT been declared.)
      )
    )

    $(call Mark-Step,Verifying new mod attributes)
    $(call verify-mod-attributes,${_new_mod_ref},defined)
    $(call verify-mod-nodes,${_new_mod_ref})

    $(if $(call is-modfw-mod,${_new_mod_ref}),
      $(call PASS,Mod ${_new_mod_ref} is expected format.)
    ,
      $(call FAIL,Mod ${_new_mod_ref} does not conform to ModFW mod format.)
    )

    $(call Mark-Step,Verifying cannot declare same mod.)
    $(call Expect-Message,Mod ${_new_mod_ref} has already been declared.)
    $(call mk-mod-from-template,${_new_mod_ref},${_mod_ref})
    $(call Verify-Message)

    $(call Mark-Step,Verifying cannot create same mod.)
    $(call Expect-Message,Mod ${_new_mod_ref} already exists.)
    $(call mk-mod-from-template,${_new_mod_ref},${_mod_ref})
    $(call Verify-Message)

    $(call Test-Info,Teardown.)
    $(eval undefine ${_kit}.URL)
    $(eval undefine ${_kit}.BRANCH)

    $(call undeclare-mod,${_mod_ref})
    $(call undeclare-mod,${_new_mod_ref})
    $(call undeclare-kit,${_kit})
  )

  $(call rm-node,${PROJECTS_NODE},,y)
  $(call undeclare-kit-parents)

  $(call End-Test)
  $(call Exit-Macro)
endef

$(call Declare-Test,use-mod)
define _help
${.TestUN}
  Verify using a mod.
endef
help-${.TestUN} := $(call ${_help})
$(call Add-Help,${.TestUN})
${.TestUN}.Prereqs := ${.SuiteN}.mk-mod
define ${.TestUN}
  $(call Enter-Macro,$(0))
  $(call Begin-Test,$(0))

  $(eval _kit := $(call To-Shell-Var,$(0).test-kit))
  $(eval _mod := test-mod)
  $(eval _mod_ref := ${_kit}.${_mod})
  $(call Test-Info,Mod node:${_mod})

  $(eval ${_kit}.URL := ${LOCAL_REPO})
  $(eval ${_kit}.BRANCH := main)

  $(call declare-kit-parents)
  $(call mk-node,${PROJECT}.${KITS_NODE})
  $(call mk-kit,${_kit})
  $(call mk-mod,${_mod_ref})

  $(if ${Errors},
    $(call Signal-Error,Setup for ${.TestUN} failed.,exit)
  ,
    $(call Mark-Step,Verifying mod segment can be loaded and reports error.)
    $(call Expect-Error,\
      Mod segment ${_mod_ref} has not been completed.)
    $(call use-mod,${_mod_ref})
    $(call Verify-Error)

    $(if ${${_mod}.${_mod}.SegID},
      $(call PASS,Make segment for mod ${_mod_ref} was loaded.)
    ,
      $(call FAIL,Make segment for mod ${_mod_ref} was NOT loaded.)
    )
    $(call Mark-Step,Verifying mod nodes were created.)
    $(call verify-mod-nodes,${_mod_ref},exist)

    $(call Test-Info,Teardown.)
    $(eval undefine ${_kit}.URL)
    $(eval undefine ${_kit}.BRANCH)

    $(call undeclare-mod,${_mod_ref})
    $(call undeclare-kit,${_kit})
  )

  $(call rm-node,${PROJECTS_NODE},,y)
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
