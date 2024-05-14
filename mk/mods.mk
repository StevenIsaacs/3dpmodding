#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load a mod -- the mod has already been handled.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment,ModFW Mods.)
# -----

define _help
Make segment: ${Seg}.mk

A mod defines all of the tools and build procedures for a specific component.
Mods are always contained within a kit and are not available until the
containing kit has either been installed or created.

A mod is referenced using the kit name and the mod in a dotted notation making
it possible for more than one kit to contain mods of the same name.
e.g. samplekit.samplemod references the kit samplekit and the mod samplemod.

If a mod is referenced but its kit has not been installed then the kit is
installed.

All mods are child nodes of the containing kit node.

Like with projects and kits, mods are required to have a segment file.

Unlike projects and kits, a mod is NOT a repo.

Command line goals:
  help-<mod>
    Display the help message for a mod.
  help-${Seg}
    Display this help.
endef
help-${SegID} := $(call _help)
$(call Add-Help,${SegID})

$(call Add-Help-Section,mod-vars,Variables for managing mods.)

_var := mods
${_var} :=
define _help
${_var}
  The list of declared mods.
endef

_var := mod_node_names
${_var} := BUILD_NODE STAGING_NODE
define _help
${_var}
  A mod is always contained within a kit which contains a number of mods. A kit
  also defines context for the mods withing a kit.

  Mod node names:
  <kit>.<mod>.$${BUILD_NODE} (default = ${BUILD_NODE})
    The name of the build artifact directory within the kit build directory.
    This is a child of the <kit>.$${BUILD_NODE} node.
  <kit>.<mod>.$${STAGING_NODE} (default = ${STAGING_NODE})
    The name of the staging artifact directory within the kit staging directory.
    This is a child of the <kit>.$${STAGING_NODE} node.

endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

_var := mod_attributes ${node_attributes}
${_var} := seg_f
define _help
${_var}
  A mod is basically a tree node and has the same attributes as the node.

  Additional attributes:
  <kit>.<mod>.kit
    The name of the kit containing the mod. This is also equal to the name
    of the mod parent node.
  <kit>.<mod>.mod
    The name of the mod.
  <kit>.<mod>.seg_f
    The path and file name of the makefile segment for the mod.

${help-node-attributes}
endef
help-${_var} := $(call _help)
$(call Add-Help,${_var})

$(call Add-Help-Section,mod-ref-macros,Macros for referencing mods.)

_macro := kit-name
define _help
${_macro}
  Returns the kit portion of a mod reference.
  Parameters:
    1 = <kit>.<mod> reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(word 1,$(subst ., ,$(1)))

_macro := mod-name
define _help
${_macro}
  Returns the mod portion of a mod reference.
  Parameters:
    1 = <kit>.<mod> reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(word 2,$(subst ., ,$(1)))

_macro := kit-path
define _help
${_macro}
  Returns the path of the node containing the kit which contains the mod.
  Parameters:
    1 = <kit>.<mod> reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = ${${$(word 1,$(subst ., ,$(1)))}.path}

_macro := mod-path
define _help
${_macro}
  Returns the path of the node containing the mod.
  Parameters:
    1 = <kit>.<mod> reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = ${${$(word 2,$(subst ., ,$(1)))}.path}

$(call Add-Help-Section,mod-ifs,Macros for checking mod status.)

_macro := mod-is-declared
define _help
${_macro}
  Returns a non-empty value if the mod has been declared.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(if $(filter $(1),${mods}),1)

_macro := mod-exists
define _help
${_macro}
  This returns a non-empty value if a node contains a ModFW repo.
  Parameters:
    1 = The name of a previously declared mod. This should be a <kit>.<mod>
        reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
${_macro} = $(wildcard ${$(1).seg_f})

_macro := is-modfw-mod
define _help
${_macro}
  Returns a non-empty value if the mod conforms to the ModFW pattern. A
  ModFW mod will always have a makefile segment having the same name as the
  mod and the repo.
  The mod is contained in a node of the same name. The makefile segment file
  will contain the same name to indicate it is customized for the mod.
  Parameters:
    1 = A <kit>.<mod> reference to a previously declared mod.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(strip
  $(call Enter-Macro,$(0),$(1))
  $(if $(call is-modfw-repo,$(1)),
    $(call Run,grep $(1) ${$(1).seg_f})
    $(if ${Run_Rc},
      $(call Verbose,grep returned:${Run_Rc})
    ,
      $(if $(wildcard ${(1).path}/.gitignore),
        1
      )
    )
  )
  $(call Exit-Macro)
)
endef

$(call Add-Help-Section,mod-decl,Macros for declaring mods.)

_macro := declare-mod
define _help
${_macro}
  Define the attributes of a mod. A mod must be declared before any other mod
  related macros can be used. If the kit containing the mod has not been
  declared it is automatically declared.
  Parameters:
    1 = The <kit>.<mod> reference to the mod.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(if $(call mod-is-declared,$(1)),
  $(call Verbose,Mod $(1) has already been declared.)
,
  $(if node-is-declared,$(1),
    $(call Signal-Error,\
      A node having the mod name $(1) has already been declared.)
  ,
    $(eval _k := kit-name,$(1))
    $(eval _m := mod-name,$(1))
    $(call declare-kit,${_k})
    $(if $(call kit-is-declared,${_k}),
      $(call Verbose,Declaring mod $(1).)
      $(eval $(1).kit := ${_k})
      $(eval $(1).mod := ${_m})
      $(call declare-child-node,$(1),${_k},${_m})
      $(foreach _node,${mod_node_names},
        $(call declare-child-node,$(1).${${_node}},${_k}.${_node},${_m})
      )
      $(eval $(1).seg_f := ${${_k}.path}/${_m}.mk)
      $(eval mods += $(1))
    ,
      $(call Signal-Error,Declaration of kit ${_k} failed.)
    )
  )
)
$(call Exit-Macro)
endef

$(call Add-Help-Section,mod-install,Macros for installing or creating mods.)

_macro := install-mod
define _help
${_macro}
  Declare and install a mod if necessary.

  Parameters:
    1 = The <kit>.<mod> name of the mod to install.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(call declare-mod,$(1))
$(if ${Errors},
  $(call Signal-Error,An error occurred when declaring mod $(1))
,
  $(call install-kit,${$(1).kit})
  $(if ${Errors},
  ,
    $(if $(call is-modfw-mod,$(1)),
    ,
      $(call Signal-Error,Mod $(1) is not a ModFW style mod.)
    )
  )
)
$(call Exit-Macro)
endef

_macro := mk-mod-from-template
define _help
${_macro}
  Copy an existing mod to serve as the template for a new mod. The makefile
  segment for the template mod is used to generate the new makefile segment with
  references to the template mod changed to reference the new mod. The
  template makefile segment is retained for reference but no longer used.

  NOTE: The kits containing the the new mod or the template mod are installed
  if necessary.

  NOTE: This is designed to be callable from the make command line using the
  helpers call-<macro> goal.
  For example:
    make ${_macro}.PARMS=<kit>.<mod>:<tkit>.<tmod> call-${_macro}
  Parameters:
    1 = The <kit>.<mod> name of the new mod.
    2 = The <kit>.<mod> name of the existing mod to use as a template.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))
$(call install-mod,$(2))
$(if ${Errors},
,
  $(call declare-mod,$(1))
  $(if ${Errors},
  ,
    $(call install-kit,${$(1).kit})
    $(if ${Errors},
    ,
      $(if $(call mod-exists,$(1)),
        $(call Info,Mod $(1) already exists.)
      ,
        $(call Run,cp -r ${$(2).path},${$(1).path})
        $(if ${Run_Rc},
          $(call Signal-Error,\
            Copying template kit ${_kt} to the new kit ${_k} failed.)
        ,
          $(call Derive-Segment-File,\
            ${$(2).mod},${$(2).seg_f},${$(1).mod},${$(1).seg_f})
        )
      )
    )
  )
)
$(call Exit-Macro)
endef

_macro := mk-mod
define _help
${_macro}
  Declare and initialize a new mod within a kit. A makefile segment is generated from a template. The dev must then complete the makefile segment before attempting a build. The kit is installed if necessary.

  NOTE: This is designed to be callable from the make command line using the
  helpers call-<macro> goal.
  For example:
    make ${_macro}.PARMS=<kit>.<mod> call-${_macro}
  Parameters:
    1 = The <kit>.<mod> name of the new mod.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(call declare-mod,$(1))
$(if ${Errors},
,
  $(call install-kit,${$(1).kit})
  $(if ${Errors},
    $(call Signal-Error,An error occurred when installing kit ${$(1).kit})
  ,
    $(if $(call is-modfw-kit,${$(1).kit}),
      $(if $(call node-exists,$(1)),
        $(call Signal-Error,A node $(1) already exists.)
      ,
        $(call mk-node,$(1))
        $(call Gen-Segment-File,${$(1).mod},$(1).seg_f,\
          <Mod:$(1) edit this description>)
      )
    ,
      $(call Signal-Error,Kit ${_k} is not a ModFW style repo.)
    )
  )
)
$(call Exit-Macro)
endef

_macro := use-mod
define _help
${_macro}
  Use a mod. The kit containing the mod is installed if necessary.
  Parameters:
    1 = A <kit>.<mod> reference.
endef
help-${_macro} := $(call _help)
$(call Add-Help,${_macro})
define ${_macro}
$(call Enter-Macro,$(0),$(1))
$(call declare-mod,$(1))
$(if ${Errors},
,
  $(call use-kit,${$(1).kit})
  $(if ${Errors},
  ,
    $(if $(call is-modfw-kit,${$(1).kit}),
      $(call Info,Using mod ${$(1).mod} from kit ${$(1).kit}.)
      $(if $(call is-modfw-mod,$(1)),
        $(call Use-Segment,${$(1).seg_f})
      ,
        $(call Signal-Error,Mod $(1) is not a ModFW style mod.)
      )
    ,
      $(call Signal-Error,Kit ${_k} is not a ModFW style kit.)
    )
  )
)
$(call Exit-Macro)
endef

# +++++
# Postamble
# Define help only if needed.
__h := $(or \
  $(call Is-Goal,help-${SegUN}),\
  $(call Is-Goal,help-${SegID}),\
  $(call Is-Goal,help-${Seg}))
ifneq (${__h},)
define __help
$(call Display-Help-List,${SegID})
endef
${__h} := ${__help}
endif # help goal message.

$(call Exit-Segment)
else # SegId exists
$(call Check-Segment-Conflicts)
endif # SegId
# -----
