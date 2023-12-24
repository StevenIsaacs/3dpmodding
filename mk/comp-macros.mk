#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Macros to support ModFW components.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----

comps :=

_macro := comp-is-declared
define _help
${_macro}
  Returns a non-empty value if the component has been declared.
  Parameters:
    1 = The component.
endef
help-${_macro} := $(call _help)
${_macro} = $(if $(filter $(1),${comps}),1)

_macro := comp-is-container
define _help
${_macro}
  Returns a non-empty value if the component is a container.
  Parameters:
    1 = The component.
endef
help-${_macro} := $(call _help)
${_macro} = $(if ${$(1)_ctnr},,1)

_macro := is-comp-dir
define _help
${_macro}
  Returns a non-empty value if the directory is a component directory meaning
  it contains a makefile segment for the component.
  Parameters:
    1 = The name of a previously declared repo.
endef
help-${_macro} := $(call _help)
${_macro} = $(if $(wildcard ${$(1)_repo_mk}),1)

_macro := declare-comp
define _help
${_macro}
  Define the attributes for a ModFW component. A ModFW component can be:
  - An independent component.
  - A component which contains other components (i.e. a container).
  - A component contained within another component (i.e. content).
  The component name is used:
  - As a prefix for associated variable names (attributes).
  - As the name of the component makefile segment.
  - As the name or part of the name of the directory in which the component
    resides.
  A component must be declared before any other component related macros can be
  used.
  Parameters:
    1 = The component <ctnr>. This must be one of:
        ${containers}
    2 = The name of the component (<comp>).
    3 = Optional name of the container (<ctnr>) containing the component. If
        this is defined the containing component path is used as path to the
        the component directory. For example kits contain mods so the the path
        to the mod is <<comp>_ctnr>_path/<comp>_name.
  Uses:
    <ctnr>_path
  Defines variables:
    <comp>_class  The component <ctnr>.
    <comp>_ctnr   The container for this component.
    <comp>_seg    The segment defining the component.
    <comp>_name    The name of the directory containing the component.
    <comp>_path   The path to the directory containing the component files.
    <comp>_mk     The makefile segment defining the component.
    <comp>_var    The shell variable name corresponding to the component.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0))
$(if $(call comp-is-declared,$(2)),
  $(call Warn,Component $(2) has already been declared.)
,
  $(if $(call Must-Be-One-Of,$(1),${containers}),
    $(call Verbose,Declaring component $(2).)
    $(eval $(2)_class := $(1))
    $(eval $(2)_seg := $(2))
    $(eval $(2)_name := $(2))
    $(if $(3),
      $(if ${$(3)_path},
        $(eval $(2)_ctnr := $(3))
        $(eval $(2)_path := ${$(3)_path}/$(2))
      ,
        $(call Signal-Error,Container $(3) path is undefined.)
      )
    ,
      $(if ${$(1)_path},
        $(eval $(2)_path := ${$(1)_path}/$(2))
      ,
        $(call Signal-Error,No path for $(1) container and no container class.)
      )
    )
    $(eval $(2)_mk := ${$(2)_path}/$(2).mk)
    $(eval $(2)_var := $(call To-Shell-Var,$(2)))
    $(eval comps += $(2))
  ,
    $(call Signal-Error,Invalid container:$(1))
  )
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

${help-declare-container}

${help-declare-comp}

${help-comp-is-declared}

${help-is-comp-dir}

Command line goals:
  help-${Seg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
