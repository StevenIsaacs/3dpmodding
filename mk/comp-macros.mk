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
endef
help-${_macro} := $(call _help)
${_macro} = $(if $(filter $(1),${comps}),1)

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
  Define the attributes for a ModFW component. A ModFW component can be a
  project, kit or mod. The component name is used:
  - As a prefix for associated variable names (attributes).
  - As the name of the component makefile segment.
  - As the name or part of the name of the directory in which the component
    resides.
  - In the case of projects and kits as the name of the repo in which the
    component is maintained.
  A component must be declared before any other component related macros can be
  used.
  Parameters:
    1 = The path to the directory containing the component directory.
    2 = The name of the component (<comp>).
  Defines variables:
    <comp>_seg    The segment defining the component.
    <comp>_dir    The name of the directory containing the component.
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
  $(call Verbose,Declaring component $(2).)
  $(eval $(2)_seg := $(2))
  $(eval $(2)_dir := $(2))
  $(eval $(2)_path := $(1)/$(2))
  $(eval $(2)_mk := ${$(2)_path}/$(2).mk)
  $(eval $(2)_var := $(call To-Shell-Var,$(2)))
  $(eval comps += $(2))
)
$(call Exit-Macro)
endef

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

This segment defines macros for managing ModFW components. A component can be
a project, kit, or mod.

Defines the macros:

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
