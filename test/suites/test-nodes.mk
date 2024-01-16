#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW - node-macros test suite.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment)
# -----
$(call Use-Segment,tree-macros)

_macro := show-node
define _help
${_macro}
  Display node attributes.
  Parameters:
    1 = The name of the node.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call node-is-declared,$(1))
    $(call Display-Vars,\
      $(foreach _a,${node-attributes},$(1).${_a})
    )
    $(if ${$(1).path},
      $(call Test-Info,Node $(1) can be a node.)
    ,
      $(call Test-Info,Node $(1) is NOT a valid node.)
    )
  ,
    $(call Signal-Error,Node $(1) is not a member of ${nodes})
  )
  $(if $(call node-exists,$(1)),
    $(call Test-Info,Node $(1) path exists.)
  ,
    $(call Test-Info,Node $(1) path does not exist.)
  )
  $(call Exit-Macro)
endef

_macro := verify-declare-node
define _help
${_macro}
  Verify declaration and removal of a node.
  This verifies:
    declare-node
    remove-node
  Parameters:
    1 = The path for the test nodes.
endef
help-${_macro} := ${_help}
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call Begin-Test,$(0))
  $(if $(1),
    $(eval _node := c1)
    $(call declare-node,${_node},$(1))
    $(if $(call node-is-declared,${_node}),
      $(call PASS,Node ${_node} is declared.)
      $(call Expect-Vars,\
        ${_node}_name:${_node}\
        ${_node}_path:$(2)/${_node}\
        nodes:${_node}\
      )
      $(call Expect-Warning,Node ${_node} has already been declared.)
      $(call declare-node,${_node})
      $(call Verify-Warning)

      $(if $(1),
        $(if $(call node-is-node,${_node}),
          $(call PASS,Class $(1) is a node.)
        ,
          $(call FAIL,Class $(1) is not a node.)
        )
      ,
        $(if $(call node-is-node,$(1)),
          $(call FAIL,Class $(1) should not be a node.)
        ,
          $(call PASS,Class $(1) is not a node.)
      )
      )
      $(call verify-remove-node,$(1))
    ,
      $(call FAIL,Class $(1) is NOT declared.)
    )
  ,
    $(call Signal-Error,Node path must be specified.)
  )
  $(call End-Test)
  $(call Exit-Macro)
endef

_macro := verify-remove-node
define _help
${_macro}
  Verify removal of a node.
  This verifies:
    remove-node
  Parameters:
    1 = The name of the class.
endef
help-${_macro} := ${_help}
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call Begin-Test,$(0))
  $(call remove-node,$(1))
  $(if $(call node-is-declared,$(1)),
    $(call FAIL,Node $(1) should not be declared.)
  ,
    $(call PASS,Node $(1) is no longer declared.)
  )
  $(call End-Test)
  $(call Exit-Macro)
endef

_macro := verify-node-macros
define _help
${_macro}
  Verify node macros.
  This verifies:
    declare-node
    node-is-declared
    remove-node
endef
help-${_macro} := ${_help}
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call Begin-Test,$(0))

  $(call Test-Info,Testing node does not exist.)
  $(eval _node := does-not-exist)
  $(if $(call node-is-declared,${_node}),
    $(call FAIL,Node ${_node} should NOT be declared.)
    $(call show-node,${_node})
  ,
    $(call PASS,Class ${_node} is not declared.)
  )
  $(if $(call node-exists,${_node}),
    $(call FAIL,Node directory ${_node} should NOT exist.)
    $(call show-node,${_node})
  ,
    $(call PASS,Class ${_node} is not declared.)
  )

  $(call Test-Info,Adding a non-node class.)
  $(eval _node := not-node)
  $(call verify-declare-node,${_node})

  $(call Test-Info,Adding a node class.)
  $(eval _node := node)
  $(call verify-declare-node,${_node},${TESTING_PATH})

  $(call End-Test)
  $(call Exit-Macro)
endef

_macro := setup-${Seg}
define _help
${_macro}
  Setup for the ${Seg} test suite.
endef
help-${_macro} := ${_help}
define ${_macro}
  $(call Test-Info,Setting up ${Seg}.)
endef

_macro := teardown-${Seg}
define _help
${_macro}
  Teardown the ${Seg} test suite.
endef
help-${_macro} := ${_help}
define ${_macro}
  $(call Test-Info,Tearing down ${Seg}.)
endef

$(call Begin-Suite,${Seg})
$(call setup-${Seg})
$(call verify-node-macros)
$(call teardown-${Seg})
$(call End-Suite)

${Seg}:

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help-${Seg}
Make segment: ${Seg}.mk

This test suite verifies the macros related to managing nodes.

Defines the macros:

${help-show-node}

${help-verify-declare-node}

${help-verify-remove-node}

${help-verify-node-macros}

${help-setup-${Seg}}

${help-teardown-${Seg}}

Uses:
  TESTING_PATH
    Where the test nodes are stored.

Command line goals:
  help-${Seg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
