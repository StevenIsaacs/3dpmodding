#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Load a mod -- the mod has already been handled.
#----------------------------------------------------------------------------
# The prefix $(call This-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call This-Segment-Basename)SegId
$(call Enter-Segment)
# -----

# The active mod.
$(call Sticky,MOD)

$(call Require,MOD)

mods_path := ${${KIT}_repo_path}
mod_path := ${mods_path}/${MOD}

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

A mod contains all of the variables, goals and, recipes needed to build all
of the components needed for the mod.

A mod can be dependent upon other mods in the same kit or different kits.

Required sticky command line variables:
  KIT=${KIT}
    Which kit is the active kit (see "help-kits").
  MOD=${MOD}
    Which mod is the active mod from the active kit.

Optional sticky variables:
  These are required if the clone directory doesn't exist. If the clone
  directory does exist then they will be set using git to determine the
  repository URL and the active branch. This feature allows use of a local
  repository or one that was cloned manually.
  ${KIT}_REPO = ${${KIT}_REPO}
    Synonym = KIT_REPO
    The git repo to clone to download the mod.
  ${KIT}_BRANCH = ${${KIT}_BRANCH}
    Synonym = KIT_BRANCH
    Which version of the mod to use. This determines which branch to checkout
    once cloned.
  KIT_CONFIGS_PATH = ${KIT_CONFIGS_PATH}
    Where generated config files are maintained. This can be a path to a
    repository maintained by the developer.

Defined in config.mk:
  KITS_PATH = ${KITS_PATH}
    Where mod mods are installed (cloned from a git repo).
  STAGING_PATH = ${STAGING_PATH}
    The top level staging directory.

Defines:

Macros:
  use-mod
    Declare mod specific variables, macros and, goals (a namespace). This
    allows having one mod dependent upon the output of different mod. If
    the mod segment exists then it is loaded. Otherwise, the kit containing the
    mod is installed or if the "create-mod" goal is used a new mod is created.
    Command line goals:
      <mod>-create-mod
        This goal is fully defined only when the "create-mod" goal (below) is
        used. To reduce the possibility of accidental creation of new mods
        this goal does nothing if the "create-mod" goal is not in the list of
        command line goals.
    Parameters:
      1 = The mod file name. This is used to name:
          Defaults to the active mod: ${MOD}
            - The mod make segment file.
            - The mod directory.
            - Mod specific goals.
      2 = The kit containing the mod.
          Defaults to the active kit: ${KIT}
      3 = The branch in the kit repository to use.
          Default: Previous value or ${DEFAULT_KIT_BRANCH}
    Examples:
      $$(call use-mod)
        Use the active mod from the active kit.
      $$(call use-mod,<mod>)
        Use a mod from the active kit.
        The repo and branch default to the previously saved value or defaults.
        No basis project is used if creating a new mod.
      $$(call use-mod,<mod>,<kit>)
        Use a mod from a specific kit.
      $$(call use-mod,<mod>,,<branch>)
        The repo defaults to the previously saved value or default.
        The mod repo branch is switched to <branch>.

  new-mod
    Create a new mod and declare mod specific variables, macros and, goals (a namespace). The mod is created locally and will not have a corresponding
    remote repository.

    Parameters:
      1 = The new mod name. This is used to name:
            - The mod repository directory name.
            - The mod make segment file.
            - Kit specific goals.
      2 = The kit in which to create the new mod.
          Defaults to the active kit: ${KIT}
      3 = The branch in the kit repository to use.
          Default: Previous value or ${DEFAULT_KIT_BRANCH}
      4 = The optional basis mod to use if creating a new mod. The basis mod must
          have been previously cloned or created. The contents of the basis mod
          directory are cloned to the new mod using git. The basis mod makefile
          segment is used to generate the new mod makefile segment.
    Updates:
      new_mods = ${new_mods}
        A list of new mods being created.
      new_mod_deps = ${new_mod_deps}
        A list of new mods dependencies. This is used as the dependency list
        for the "create-mod" goal.
    Defines the mod specific sticky variables:
      <mod>_REPO = ${DEFAULT_KIT_REPO}
        For new mods this is always equal to DEFAULT_KIT_REPO.
      <mod>_BRANCH = ${DEFAULT_KIT_BRANCH}
        The main branch for the new mod. This is always equal to
        DEFAULT_KIT_BRANCH.
    Command line goals:
      <mod>-create-mod
        This goal is fully defined only when the "create-mod" goal (below) is
        used. To reduce the possibility of accidental creation of new mods
        this goal does nothing if the "create-mod" goal is not in the list of
        command line goals. This is added to the new_mod_deps list.
    Examples:
      $$(call new-mod,<mod>)
        No basis project is used when creating a new mod.
      $$(call new-mod,<mod>,<basis_mod>)
        The a basis mod is cloned when creating a new mod.

Command line goals:
  show-mods
    Display a list of loaded mods.
  help-<mod>
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
