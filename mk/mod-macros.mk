#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Macros to support ModFW MODs.
#----------------------------------------------------------------------------
# +++++
$(call Last-Segment-UN)
ifndef ${LastSegUN}.SegID
$(call Enter-Segment)
# -----

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help-${Seg}
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
    <mod>.REPO     The URL for the new mod.

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
    <kit>.repo_path The path to the directory where the <kit> mods are stored.
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
