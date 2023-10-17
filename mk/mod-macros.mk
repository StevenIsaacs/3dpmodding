#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Macros to support ModFW MODs.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----

mods :=

define help-declare-mod
declare-mod
  Define the attributes of a component mod. A mod must be declared before
  any other mod related macros can be used. If the kit containing the mod
  has not been declared it is automatically used.
  Parameters:
    1 = The name of the component declared using declare-comp (<mod>).
    2 = The optional name of the kit containing the mod.
  Calls:
    declare-comp  Declares the mod component to define:
      <mod>_seg   The segment defining the component.
      <mod>_dir   The name of the directory containing the component.
      <mod>_path  The path to the directory containing the component files.
      <mod>_mk    The makefile segment defining the component.
      <mod>_var   The shell variable name corresponding to the component.
    use-repo      To use the kit containing the mod. If the kit does not
                  exist locally then it is automatically cloned (see
                  help-repo-macros). NOTE: This may require definition of
                  <kit>_REPO and <kit>_BRANCH on the command line or in the
                  <project> (${PROJECT}) make file.
  Defines variables:
    <mod>_mod_dir   The name of the mod directory. This is a combination of
                    the <seg> name and the <seg>_BRANCH.
    <mod>_mod_path  The full path to the mod.
    <mod>_mod_dep   A dependency for the mod. This uses the .git directory in
                    the mod directory as the dependency.
    comps           Adds the mod to the list of components.
    mods            Adds the mod to the list of mods.
endef
define declare-mod
$(call Enter-Macro,$(0),$(1) $(2))
$(if ${$(1)_seg},
  $(call Warn,Mod $(1) has already been declared.)
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

mod_goals :=

define help-setup-mod
setup-mod
  Generate a goal to create and initialize a mod in a local directory. A
  makefile segment for the mod having the same name as the mod is also
  generated.
  NOTE: The new component and mod must have already been declared. Also,
  the KIT containing the mod MUST exist and have also been declared.
  Parameters:
    1 = The name of the new mod (<mod>).
endef
define setup-mod
$(call Enter-Macro,$(0),$(1))
  $(call Attention,TBD)
$(call Exit-Macro)
endef

define help-use-mod
use-mod
  Use a project or kit mod. If the mod doesn't exist locally a goal is
  generated to clone the mod from a remote server.
  NOTE: This macro is also be designed to be called by mods which are dependent
  on the output of another component.
  Parameters:
    1 = The path to the mod.
    2 = The name of the component (<mod>) corresponding to the mod. This is
        used to name the mod directory and associated variables.
endef
define use-mod
$(call Enter-Macro,$(0),$(1) $(2))
$(if $(1),
  $(if $(2),
    $(if ${(2)_seg},
      $(call Info,Component $(2) is already in use.)
    ,
      $(call declare-comp,$(1),$(2))
      $(call declare-mod,$(2))
      $(if $(wildcard ${$(2)_mod_mk}),
        $(call Info,Using mod: $(2))
        $(call Add-Segment-Path,${$(2)_mod_path})
        $(call Use-Segment,$(2))
      ,
        $(if ${$(2)_REPO},
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

define help-copy-basis-to-new-mod
copy-basis-to-new-mod
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
  Uses:
    <mod>_REPO      The URL for the new mod.
    <mod>_BRANCH    The default branch for the new mod.
    <mod>_path      Where to clone the new mod to.
    <mod>_mk        The full path to the makefile segment for the new mod.
    <basis>_REPO    The URL for the basis mod.
    <basis>_BRANCH  The default branch for the basis mod.
    <basis>_path    Where the basis mod resides or is cloned to.
    <basis>_mk      The full path to the makefile segment for the basis mod.
endef
define copy-basis-to-new-mod
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

define create-mod
$(call Enter-Macro,create-mod)
$(call Verbose,Creating mod $(1).)
$(call Verbose,mod:${$(1)_REPO})
$(call Verbose,Filtered:$(filter local,${$(1)_REPO}))
$(if $(filter local,${$(1)_REPO}),
  $(call Verbose,Creating $(1).)
  $(call gen-mod-goal,init,$(1))
,
  $(call Signal-Error:create-mod:Can only create a local mod.)
)
$(call Exit-Macro)
endef

define new-mod
$(call Enter-Macro,new-mod)
$(if $(1),
  $(if ${(2)_seg},
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

define activate-mod
$(call Enter-Macro,activate-mod)
$(call Sticky,$(1)_KIT,${KIT})
$(eval mods := $(call Directories-In,${${$(1)_KIT}_repo_path}))
$(if ${NEW_MOD},
  $(call Verbose,Creating a new mod in kit ${$(1)_KIT}.)
  $(if $(call Confirm,Create new mod ${NEW_MOD}?,y),
    $(call Sticky,${NEW_MOD}_KIT,${$(1)_KIT})
    $(if $(filter,${NEW_MOD},${mods}),
      $(call Signal-Error,New mod ${NEW_MOD} already exists.)
    ,
      $(call new-mod,$(1),${$(1)_KIT},${NEW_MOD},${BASIS_MOD},${BASIS_KIT})
    )
  ,
    $(call Signal-Error,Not creating mod ${NEW_MOD}.)
  )
,
  $(call Verbose,Activate an existing mod.)

  $(call use-mod,${$(1)_KIT},${$(1)})
  $(call Use-Segment,$(1))
)
$(call Exit-Macro)
endef

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

This segment defines macros for managing ModFW mods.

Defines the macros:

${help-declare-mod}

${help-init-mod-goal}

${help-use-mod}

${help-copy-basis-to-new-mod}

create-mod
  Create a new mod. The makefile segment for the new mod is generated using
  the helpers defined template.
  Parameters:
    1 = The name of the component (<mod>) corresponding to the new mod. This
        is used to name the mod directory and the associated variables.
  Uses:
    <mod>_REPO     The URL for the new mod.

new-mod
  Create a new mod in a kit. This generates the "create-mod" goal which must be
  used on the command line to create the new mod. This helps avoid accidental
  creation of useless mods.
  Parameters:
    1 = The name of the mod (<mod>). This is used to name the mod directory in
        the containing kit and associated variables.
    2 = The kit in which to create the new mod. This defaults to the active
        kit (${KIT}).
    3 = Optional basis mod to copy when creating the new mod. If used this
        triggers a call to dup-mod.
    4 = Optional kit containing the basis mod. This defaults to the active kit.

activate-mod
  Activate a mod. This creates, copies, or uses mods. This is the primary mod
  macro. The active mod becomes the default and can be thought of the as being the mod under development. The active mod must be part of the active kit
  (${KIT}).
  NOTE: Only one mod can be the active mod even though multiple mods can be
  used (use-mod) at the same time.
  Parameters:
    1 = The name of the <mod> in the <kit>.
  Uses:
    KIT             The active kit.
    <kit>_repo_path The path to the directory where the <kit> mods are stored.
  Modes:
    This macro supports two mutually exclusive modes; create and use.

    create  This mode is used to create a new mod when NEW_MOD is not
            empty. It adds dependencies to the "create-new" goal (see help).
            Creating a new mod requires an initial run of make to create the
            new mod before the mods can be used in a later run of make. This
            is because the new mod component makefile segment will simply be a
            template which must be completed by the developer before it will
            have any effect.
      Calls:
        new-mod
      Uses:
        NEW_MOD   If not empty creates a new mod in the selected kit. This is
                  the name of the component for which the mod is created.
        BASIS_MOD If not empty duplicates an existing mod to a new mod.
        BASIS_KIT If not empty then specifies which kit contains the basis mod.

    use     This mode uses an existing mod from the selected kit.
      Calls:
        use-mod
      Uses:
        MOD             The name of the mod in the active kit to activate.

Command line goals:
  help-${Seg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # <u>SegId exists
$(call Check-Segment-Conflicts)
endif # <u>SegId
# -----
