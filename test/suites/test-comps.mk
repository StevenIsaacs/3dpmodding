#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW - comp-macros test suite.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----
$(call Use-Segment,comp-macros)

_macro := verify-remove-component
define _help
${_macro}
  Verify removal of a component.
  This verifies:
    remove-component
  Parameters:
    1 = The name of the class.
endef
help-${_macro} := ${_help}
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call Begin-Test,$(0))
  $(call remove-component,$(1))
  $(if $(call component-is-declared,$(1)),
    $(call FAIL,Class $(1) should not be declared.)
  ,
    $(call PASS,Class $(1) is no longer declared.)
  )
  $(call Exit-Macro)
endef

_macro := verify-declare-component
define _help
${_macro}
  Verify removal of a component.
  This verifies:
    declare-component
    remove-component
  Parameters:
    1 = The name of the class.
    2 = If declaring a component this is the path for the component.
endef
help-${_macro} := ${_help}
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call Begin-Test,$(0))
  $(call declare-component,$(1),$(2))
  $(if $(call component-is-declared,$(1)),
    $(call PASS,Class $(1) is declared.)
    $(call Expect-Vars,\
      $(1)s_name:$(1)\
      $(1)s_path:\
    )
    $(call Expect-Warning,Component component $(1) has already been declared.)
    $(call declare-component,$(1))
    $(call Verify-Warning)

    $(if $(2),
      $(if $(call component-is-component,$(1)),
        $(call PASS,Class $(1) is a component.)
      ,
        $(call FAIL,Class $(1) is not a component.)
      )
    ,
      $(if $(call component-is-component,$(1)),
        $(call FAIL,Class $(1) should not be a component.)
      ,
        $(call PASS,Class $(1) is not a component.)
    )
    )
    $(call verify-remove-component,$(1))
  ,
    $(call FAIL,Class $(1) is NOT declared.)
  )
  $(call Exit-Macro)
endef

_macro := verify-component-macros
define _help
${_macro}
  Verify component macros.
  This verifies:
    declare-component
    component-is-declared
    remove-component
endef
help-${_macro} := ${_help}
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call Begin-Test,$(0))

  $(call Test-Info,Testing component does not exist.)
  $(eval _class := does-not-exist)
  $(if $(call component-is-declared,${_class}),
    $(call FAIL,Class ${_class} should NOT be declared.)
    $(call show-component,${_class})
  ,
    $(call PASS,Class ${_class} is not declared.)
  )

  $(call Test-Info,Adding a non-component class.)
  $(eval _class := not-ctnr)
  $(call verify-declare-component,${_class})

  $(call Test-Info,Adding a component class.)
  $(eval _class := ctnr)
  $(call verify-declare-component,${_class},${TESTING_PATH})

  $(call Exit-Macro)
endef

_macro := verify-declare-comp
define _help
${_macro}
  Verify declaration of components. These can be a <comp>, <repo>, <kit>,
  or <mod>.
  Parameters:
    1 = The name of the component.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call Begin-Test,${0})

  $(eval _class := non-comp)
  $(call Expect-Error,Invalid component:${_class})
  $(call declare-comp,comp,${_class})
  $(call Verify-Error)

  $(call declare-component,ctnr,${TESTING_PATH})
  $(call declare-component,non-ctnr)

  $(eval _comp := comp)
  $(call Test-Info,A component component component:${_class})
  $(call declare-comp,ctnr,ctnr-1)
  $(call report-comp,$(1))
  $(call verify-comp-vars,$(1))
  $(call Test-Info,Expect an already declared warning.)
  $(call Expect-Warning,Component $(2) has already been declared.)
  $(call declare-comp,$(1),$(2))
  $(call Verify-Warning)
  $(call Exit-Macro)
endef

$(call Begin-Suite,${Seg})
$(call verify-component-macros)
$(call verify-declare-comp)

$(call Test-Info,Testing:declare-comp)
# Component component declaration.
_comp := comp-1
$(call Expect-Error,Invalid component:${_class})
$(call declare-comp,comp,${_class})

$(call declare-component,comp,${TESTING_PATH})
$(call show-component,${_comp})
$(call declare-comp,comp,${_comp})
$(call Expect-Warning,Component $(2) has already been declared.)
$(call declare-comp,comp,${_comp})


# A component component and a component inside a component.
_class := ctnr-c-1
$(call declare-component,${_class},${TESTING_PATH})
$(call declare-component,)

${Seg}: display-errors display-messages

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help-${Seg}
Make segment: ${Seg}.mk

This test suite verifies the macros and variables defined in comp-macros.mk.

Command line goals:
  help-${Seg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
