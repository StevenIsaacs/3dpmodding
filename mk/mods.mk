#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load a mod -- the mod has already been handled.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment)
# -----

${Seg} :=

_macro := kit-name
define _help
${_macro}
  Returns the kit portion of a mod reference.
  Parameters:
    1 = <kit>.<mod> reference.
endef
help-${_macro} := $(call _help)
${_macro} = $(word 1,$(subst ., ,$(1)))

_macro := mod-name
define _help
${_macro}
  Returns the mod portion of a mod reference.
  Parameters:
    1 = <kit>.<mod> reference.
endef
help-${_macro} := $(call _help)
${_macro} = $(word 2,$(subst ., ,$(1)))

_macro := declare-mod
define _help
${_macro}
  Define the attributes of a mod. A mod must be declared before any other mod
  related macros can be used. If the kit containing the mod has not been
  declared it is automatically used.
  Parameters:
    1 = The <kit>.<mod> reference to the mod.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))
$(if ${$(1).SegID},
  $(call Warn,Mod $(1) is already in use.)
,
  $(if $(2),
    $(eval _k := $(2))
  ,
    $(eval _k := $(KIT))
  )
  $(if ${${_k}_repo_path},
    $(call Verbose,Kit ${_k} is in use.)
  ,
    $(call Verbose,Using kit ${_k})
    $(call use-repo,${KITS_PATH},${_k})
  )
  $(if $(wildcard ${${_k}_repo_path}),
    $(call Verbose,Declaring mod $(1).)
    $(call declare-comp,${${_k}_repo_path},$(1))
    $(eval comps += $(1))
    $(eval mods += $(1))
  ,
    $(call Signal-Error,Using kit ${_k} failed.)
  )
)
$(call Exit-Macro)
endef

_macro := setup-mod
define _help
${_macro}
  Generate a goal to create and initialize a mod in a local directory. A
  makefile segment for the mod having the same name as the mod is also
  generated.
  NOTE: The new component and mod must have already been declared. Also,
  the KIT containing the mod MUST exist and have also been declared.
  Parameters:
    1 = The name of the new mod (<mod>).
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1))
  $(call Attention,TBD)
$(call Exit-Macro)
endef

_macro := use-mod
define _help
${_macro}
  Use a project or kit mod. If the mod doesn't exist locally a goal is
  generated to clone the mod from a remote server.
  NOTE: This macro is also be designed to be called by mods which are dependent
  on the output of another component.
  Parameters:
    1 = The path to the mod.
    2 = The name of the component (<mod>) corresponding to the mod. This is
        used to name the mod directory and associated variables.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))
$(if $(1),
  $(if $(2),
    $(if ${(2).seg},
      $(call Info,Component $(2) is already in use.)
    ,
      $(call declare-comp,$(1),$(2))
      $(call declare-mod,$(2))
      $(if $(wildcard ${$(2).mod_mk}),
        $(call Info,Using mod: $(2))
        $(call Add-Segment-Path,${$(2).mod_path})
        $(call Use-Segment,$(2))
      ,
        $(if ${$(2).REPO},
          $(call Info,Generating goal to clone mod: $(2))
          $(call gen-mod-goal,copy,$(2))
        ,
          $(call Signal-Error,\
            use-mod:Repo $(2) is not defined. Use create-new.)
        )
      )
    )
  )
,
  $(call Signal-Error,The mod path has not been specified.)
)
$(call Exit-Macro)
endef

_macro := copy-basis-to-new-mod
define _help
${_macro}
  Copy an existing mod to serve as the basis for a new mod. The makefile
  segment for the basis mod is used to generate the new makefile segment with
  references to the basis mod changed to reference the new mod. The
  basis makefile segment is retained for reference but no longer used. This
  also generates a "create-mod" goal which must be used on the command line
  which helps avoid accidental creation of useless mods.
  Parameters:
    1 = The path to the directory where the mod will be stored.
    2 = The name of the component (<mod>) corresponding to the new mod. This
        is used to name the mod directory and associated variables.
    3 = The basis component (<basis>) to clone when creating the new mod.
    4 = The kit containing the basis mod. This defaults to the active kit.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2) $(3) $(4))
$(if $(2),
  $(if $(3),
    $(call Verbose,Using $(3) as basis for $(2).)
    $(if $(1),
      $(call use-mod,$(1),$(3))
      $(call gen-basis-to-new-mod-goal,$(2),$(3))
    ,
      $(call Signal-Error,\
        dup-mod:The new and basis mod path has not been specified.)
    )
  ,
    $(call Signal-Error,The basis mod has not been specified.)
  )
,
  $(call Signal-Error,The new mod has not been specified.)
)
$(call Exit-Macro)
endef

_macro := new-mod
define _help
${_macro}
  Create and initialize a new mod within a kit. A makefile segment is generated from a template. The dev must then complete the makefile segment before attempting a build.
  NOTE: This is designed to be callable from the make command line using the
  helpers call-<macro> goal.
  For example:
    make ${_macro}.PARMS=<mod>[:<basis>] call-${_macro}
  Parameters:
    1 = The name of the new mod.
    2 = Optional mod name to use as the basis of the new kit.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2))
$(call Verbose,Creating mod $(1).)
$(call Verbose,mod:${$(1).REPO})
$(call Verbose,Filtered:$(filter local,${$(1).REPO}))
$(if $(filter local,${$(1).REPO}),
  $(call Verbose,Creating $(1).)
  $(call gen-mod-goal,init,$(1))
,
  $(call Signal-Error:create-mod:Can only create a local mod.)
)
$(call Exit-Macro)
endef

_macro := use-mod
define _help
${_macro}
  Use a mod. The mod must already exist.
  Parameters:
    1 = A <kit>.<mod> reference.
endef
help-${_macro} := $(call _help)
define ${_macro}
$(call Enter-Macro,$(0),$(1) $(2) $(3))
$(if $(1),
  $(if ${(2).seg},
    $(call Verbose,Kit $(2) has already been declared.)
  ,
    $(call use-kit,$(2))
  )
  $(call Info,Creating new mod for: $(2))
  $(call declare-mod,$(1),$(2))
  $(if $(3),
    $(call Verbose,Duplicating $(3) to mod $(1).)
    $(call dup-mod,$(1),$(2),$(3),$(4))
  ,
    $(call Verbose,Creating mod $(1).)
    $(call create-mod,$(1))
  )
,
  $(call Signal-Error,The new mod name has not been specified.)
)
$(call Exit-Macro)
endef

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

A mod contains all of the variables, macros, goals, and recipes needed to build
all of the mod deliverables. A mod is always a subdirectory in a kit repo
making the kit the parent of the mod. This avoids name conflicts
between kits. The <kit> portion of the reference is also a reference to the
parent node for the mod.

A mod can be dependent upon other mods in the same kit or different kits.

Macros:

Command line goals:
  show-${Seg}
    Display a list of loaded mods.
  help-<kit>.<mod>
    For mod specific help.
  help-${Seg}
    Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # SegId exists
$(call Check-Segment-Conflicts)
endif # SegId
# -----
