#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Macros to support ModFW containers.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----

containers :=

_macro := container-is-declared
define _help
${_macro}
  Returns a non-empty value if the container has been declared.
  Parameters:
    1 = The container.
endef
help-${_macro} := $(call _help)
${_macro} = $(if $(filter $(1),${containers}),1)

_macro := container-exists
define _help
${_macro}
  Returns a non-empty value if the container path exists.
  Parameters:
    1 = The container name.
endef
help-${_macro} := $(call _help)
${_macro} = $(if $(wildcard ${$(1)_path}),1,)

_macro := declare-container
define _help
${_macro}
  Add a container. A container MUST be declared before a component within the
  container can be declared. A container can contain containers.
  Parameters:
    1 = The name of the container (<ctnr>).
    2 = This is the path (<path>) to the directory where the container contents
        are stored.
  Defines:
    containers
      The container name is added to this list.
    <ctnr>_name
      The name of the directory where the contained components are stored.
      This is equal to <ctnr> and used mostly as a sanity check.
      i.e. <ctnr>_name should equal <ctnr>.
    <ctnr>_path
      The full path to the container directory. This is: <path>/<ctnr>
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1) $(2))
  $(if $(call container-is-declared($(1))),
    $(call Warn,Container $(1) has already been declared.)
  ,
    $(if $(2),
      $(call Debug,Adding container:$(1).)
      $(eval containers += $(1))
      $(eval $(1)_name := $(1))
      $(eval $(1)_path := $(2)/$(1))
    ,
      $(call Signal-Error,Container path must be defined.)
    )
  )
  $(call Exit-Macro)
endef

_macro := remove-container
define _help
${_macro}
  Remove a container declaration. This un-defines all the container variables.
  Parameters:
    1 = The container (<ctnr>) to remove.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call container-is-declared,$(1)),
    $(eval undefine $(1)_name)
    $(eval undefine $(1)_path)
    $(eval containers := $(filter-out $(1),${containers}))
  ,
    $(call Warning,Container $(1) is NOT declared -- NOT removing.)
  )
  $(call Exit-Macro)
endef

_macro := create-container
define _help
${_macro}
  Create the container path. The container must first be declared.
  Parameters:
    1 = The container name.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call container-is-declared),
    $(if $(call container-exists,$(1)),
      $(call Verbose,Container $(1) exists -- not creating.)
    ,
      $(call Run,mkdir -p ${$(1)_path})
    )
  ,
    $(call Signal-Error,Container $(1) has not been declared.)
  )
  $(call Exit-Macro)
endef

_macro := destroy-container
define _help
${_macro}
  Delete all files and subdirectories for the container.
  WARNING: This is potentially destructive and cannot be undone. Use with
  caution. To help mitigate this problem this first verifies the container has been declared and the path exists.
  WARNING: All components with the container are also deleted.
  Parameters:
    1 = The container name.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call container-is-declared),
    $(if $(call container-exists,$(1)),
      $(call Run,rm -r ${$(1)_path})
    ,
      $(call Verbose,Container $(1) does not exist -- not removing.)
    )
  ,
    $(call Signal-Error,Container $(1) has not been declared.)
  )
  $(call Exit-Macro)
endef

_macro := show-container
define _help
${_macro}
  Display container attributes.
  Parameters:
    1 = The name of the container.
endef
help-${_macro} := $(call _help)
define ${_macro}
  $(call Enter-Macro,$(0),$(1))
  $(if $(call container-is-declared,$(1))
    $(call Display-Vars,\
      $(1)_name \
      $(1)_path \
      containers \
    )
    $(if ${$(1)_path},
      $(call Test-Info,Container $(1) can be a container.)
    ,
      $(call Test-Info,Container $(1) is NOT a container.)
    )
  ,
    $(call Signal-Error,Container $(1) is not a member of ${containers})
  )
  $(if $(call container-exists,$(1)),
    $(call Test-Info,Container $(1) path exists.)
  ,
    $(call Test-Info,Container $(1) path does not exist.)
  )
  $(call Exit-Macro)
endef

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help-${Seg}
Make segment: ${Seg}.mk

This segment defines macros for managing ModFW components. A component can be
a project, kit, or mod.

Defines the macros:

${help-container-is-declared}

${help-container-exists}

${help-declare-container}

${help-remove-container}

${help-create-container}

${help-destroy-container}

${help-show-container}

Command line goals:
  help-${Seg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
