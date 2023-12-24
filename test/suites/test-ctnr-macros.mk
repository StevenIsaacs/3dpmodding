#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ModFW - ctnr-macros test suite.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----
$(call Use-Segment,ctnr-macros)

_macro := verify-declare-container
define _help
${_macro}
  Verify declaration and removal of a container.
  This verifies:
    declare-container
    remove-container
  Parameters:
    1 = The path for the test containers.
endef
help-${_macro} := ${_help}
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call Begin-Test,$(0))
  $(if $(1),
    $(eval _ctnr := c1)
    $(call declare-container,${_ctnr},$(1))
    $(if $(call container-is-declared,${_ctnr}),
      $(call PASS,Container ${_ctnr} is declared.)
      $(call Expect-Vars,\
        ${_ctnr}_name:${_ctnr}\
        ${_ctnr}_path:$(2)/${_ctnr}\
        containers:${_ctnr}\
      )
      $(call Expect-Warning,Container ${_ctnr} has already been declared.)
      $(call declare-container,${_ctnr})
      $(call Verify-Warning)

      $(if $(1),
        $(if $(call container-is-container,${_ctnr}),
          $(call PASS,Class $(1) is a container.)
        ,
          $(call FAIL,Class $(1) is not a container.)
        )
      ,
        $(if $(call container-is-container,$(1)),
          $(call FAIL,Class $(1) should not be a container.)
        ,
          $(call PASS,Class $(1) is not a container.)
      )
      )
      $(call verify-remove-container,$(1))
    ,
      $(call FAIL,Class $(1) is NOT declared.)
    )
  ,
    $(call Signal-Error,Container path must be specified.)
  )
  $(call End-Test)
  $(call Exit-Macro)
endef

_macro := verify-remove-container
define _help
${_macro}
  Verify removal of a container.
  This verifies:
    remove-container
  Parameters:
    1 = The name of the class.
endef
help-${_macro} := ${_help}
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call Begin-Test,$(0))
  $(call remove-container,$(1))
  $(if $(call container-is-declared,$(1)),
    $(call FAIL,Container $(1) should not be declared.)
  ,
    $(call PASS,Container $(1) is no longer declared.)
  )
  $(call End-Test)
  $(call Exit-Macro)
endef

_macro := verify-container-macros
define _help
${_macro}
  Verify container macros.
  This verifies:
    declare-container
    container-is-declared
    remove-container
endef
help-${_macro} := ${_help}
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(call Begin-Test,$(0))

  $(call Test-Info,Testing container does not exist.)
  $(eval _ctnr := does-not-exist)
  $(if $(call container-is-declared,${_ctnr}),
    $(call FAIL,Container ${_ctnr} should NOT be declared.)
    $(call show-container,${_ctnr})
  ,
    $(call PASS,Class ${_ctnr} is not declared.)
  )
  $(if $(call container-exists,${_ctnr}),
    $(call FAIL,Container directory ${_ctnr} should NOT exist.)
    $(call show-container,${_ctnr})
  ,
    $(call PASS,Class ${_ctnr} is not declared.)
  )

  $(call Test-Info,Adding a non-container class.)
  $(eval _ctnr := not-ctnr)
  $(call verify-declare-container,${_ctnr})

  $(call Test-Info,Adding a container class.)
  $(eval _ctnr := ctnr)
  $(call verify-declare-container,${_ctnr},${TESTING_PATH})

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
$(call verify-container-macros)
$(call teardown-${Seg})
$(call End-Suite)

${Seg}:

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help-${Seg}
Make segment: ${Seg}.mk

This test suite verifies the macros related to managing containers.

Uses:
  TESTING_PATH
    Where the test containers are stored.

Command line goals:
  help-${Seg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
