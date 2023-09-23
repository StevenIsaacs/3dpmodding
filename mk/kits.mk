#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Manage multiple ModFW kits using git, branches, and tags.
#----------------------------------------------------------------------------
# The prefix $(call This-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call This-Segment-Basename)SegId
$(call Enter-Segment)
# -----

# A kit is a collection of mods. Each kit is a separate git repo.
# The directory containing the kit repos.
$(call Overridable,DEFAULT_KITS_DIR,$(Seg))
# Where the mod kits are cloned to.
# NOTE: This is ignored in .gitignore.
$(call Overridable,DEFAULT_KITS_PATH,${WorkingPath}/${DEFAULT_KITS_DIR})

$(call Sticky,KITS_DIR,${DEFAULT_KITS_DIR})
$(call Sticky,KITS_PATH,${DEFAULT_KITS_PATH})

# The active kit.
$(call Sticky,KIT)

$(call Require,KIT)

#+
# For the active kit.
#-
# These variables are in the active project directory.
$(call Sticky,KIT_REPO,${DEFAULT_REPO})
$(call Sticky,KIT_BRANCH,${DEFAULT_BRANCH})

$(call activate-repo,KIT,${Seg},mods)

# To build the active project.
activate-kit: ${${KIT}_repo_mk}

# To remove all projects.
ifneq ($(call Is-Goal,remove-${Seg}),)

  $(call Info,Removing all kits in: ${KITS_PATH})
  $(call Warn,This cannot be undone!)
  ifeq ($(call Confirm,Remove all ${Seg} -- can not be undone?,y),y)

remove-${Seg}:
> rm -rf ${KITS_PATH}

  else
    $(call Info,Not removing ${Seg}.)
  endif

endif

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

A kit is a collection of mods. Each kit is assumed to be maintained as a
separate git repository. The kit repository can either be local or a clone
of a remote repository. If a kit repository does not exist then one is either
cloned or created when the "create-kit" goal is used.

Only one kit is the active kit and is identified by the KIT sticky variable.
Mods can use additional kits using the "use-kit" macro (below).

Different versions of the same kit can be installed using the <kit>_BRANCH
sticky variable. Each version is installed in a unique directory making it
possible for a mod to use different versions of the same kit. Using separate
directories may seem bulky but eliminates the need to thrash the file system
to switch branches.

A set of kit specific variables (attributes) are defined for each kit being
used.

Required sticky command line variables for the active kit:
  KIT=${KIT}
    Selects which kit is the active kit.
  KIT_REPO=${KIT_REPO}
    Default: DEFAULT_KIT_REPO = ${DEFAULT_KIT_REPO}
    The repo to clone for the active kit.
  KIT_BRANCH=${KIT_BRANCH}
    Default: DEFAULT_KIT_BRANCH = ${DEFAULT_KIT_BRANCH}
    Branch in the active kit repo to install. This becomes part of the
    directory name for the kit.

Sticky variables for other kits:
  <kit>_REPO = (Defined by a project or a mod)
    Default: DEFAULT_KIT_REPO = ${DEFAULT_KIT_REPO}
    The repo to clone for the selected mod.
  <kit>_BRANCH = (Defined by a project or a mod)
    Default: DEFAULT_KIT_BRANCH = ${DEFAULT_KIT_BRANCH}
    The branch in the selected kit to install. This is used as part of the
    directory name for the selected version of the kit.

Other command line variables:
  NEW_KIT = ${NEW_KIT}
    The name of a new kit to create. If this is not empty then a new kit is
    declared and the "create-kit" goal will create the new kit.
    This creates new sticky variables for the new kit:
      <NEW_KIT>_REPO
      <NEW_KIT>_BRANCH
    These are not defined unless the variable NEW_KIT is defined on the command
    line.
  BASIS_KIT = ${BASIS_KIT}
    The name of the to use as a basis kit when creating a new kit.

Defined in config.mk:
  KITS_PATH = ${KITS_PATH}
    Where mod kits are installed (cloned from a git repo).
  STAGING_PATH = ${STAGING_PATH}
    The top level staging directory.

Defines:

Macros:
  use-kit
    Declare kit specific variables, macros and, goals (a namespace). This
    allows having one kit or mod depend upon the output of different kit. If
    the kit segment exists then it is loaded.
    This should be called only as a result of using a mod. See help-mods for
    more information.
    Command line goals:
      <kit>-create-kit
        This goal is fully defined only when the "create-kit" goal (below) is
        used. To reduce the possibility of accidental creation of new kits
        this goal does nothing if the "create-kit" goal is not in the list of
        command line goals.
    Parameters:
      1 = The kit name. This is used to name:
            - The kit repository directory name.
            - The kit make segment file.
            - Kit specific goals.
      2 = The kit repository to clone or create. If this is equal to "local"
          then a local repository is initialized. Otherwise the kit is cloned
          from a remote server.
          Default: Previous value or ${DEFAULT_KIT_REPO}
      3 = The branch in the kit repository to use.
          Default: Previous value or ${DEFAULT_KIT_BRANCH}
    Kit specific sticky variables:
      These are required if the kit repository doesn't exist. If the repository
      does exist then they will be set using git to determine the repository
      URL and the active branch. This feature allows use of a local repository
      or one that was cloned manually.
      <kit>_REPO = See show-<kit>_REPO
        The git repo to clone or create a kit. If this is equal to "local" then
        the kit will be created when the "create-kit" goal is present on the
        make command line.
      <kit>_BRANCH = See show-<kit>_BRANCH
        Which branch of the kit to use. This determines which branch to checkout
        once cloned or the master branch if the kit is created.

    Examples:
      $$(call use-kit,<kit>)
        The repo and branch default to the previously saved value or defaults.
        No basis project is used if creating a new kit.
      $$(call use-kit,<kit>,,,<basis_kit>)
        The repo and branch default to the previously saved value or defaults.
        The a basis kit is copied if the "create-kit" goal is specified.
      $$(call use-kit,<kit>,,<branch>)
        The repo defaults to the previously saved value or default.
        The kit repo branch is switched to <branch>.

  new-kit
    Create a new kit and declare kit specific variables, macros and, goals (a namespace). The kit is created locally and will not have a corresponding
    remote repository. The developer can then use git to create a corresponding
    remote repository if needed.

    Parameters:
      1 = The new kit name. This is used to name:
            - The kit repository directory name.
            - The kit make segment file.
            - Kit specific goals.
      2 = The optional basis kit to use if creating a new kit. The basis kit must
          have been previously cloned or created. The contents of the basis kit
          directory are cloned to the new kit using git. The basis kit makefile
          segment is used to generate the new kit makefile segment.
    Updates:
      new_kits = ${new_kits}
        A list of new kits being created.
      new_kit_deps = ${new_kit_deps}
        A list of new kits dependencies. This is used as the dependency list
        for the "create-kit" goal.
    Defines the kit specific sticky variables:
      <kit>_REPO = ${DEFAULT_KIT_REPO}
        For new kits this is always equal to DEFAULT_KIT_REPO.
      <kit>_BRANCH = ${DEFAULT_KIT_BRANCH}
        The main branch for the new kit. This is always equal to
        DEFAULT_KIT_BRANCH.
    Command line goals:
      <kit>-create-kit
        This goal is fully defined only when the "create-kit" goal (below) is
        used. To reduce the possibility of accidental creation of new kits
        this goal does nothing if the "create-kit" goal is not in the list of
        command line goals. This is added to the new_kit_deps list.
    Examples:
      $$(call new-kit,<kit>)
        No basis project is used when creating a new kit.
      $$(call new-kit,<kit>,<basis_kit>)
        The a basis kit is cloned when creating a new kit.

Command line goals:
  show-${Seg}
    Display a list of kits installed in ${KITS_PATH}.
  show-used_kits
    Display a list of kits currently in use.
  show-<kit>_mods
    Display a list of mods contained within a kit.
  kit-branches
    List the available branches in a kit. This displays the branches in the
    remote repository without installing the kit.
  change-kit-branch
    Switch to a different branch (${KIT}_BRANCH) for the kit.
  create-kit
    Create a new kit if it doesn't already exist. This goal is provided to
    help avoid accidental creation of unwanted kits.
    Command line variables:
      NEW_KIT = ${NEW_KIT}
        The name of the kit to create.
      BASIS_KIT = ${BASIS_KIT}
        The name of the existing kit to use as the basis for the new kit.
  help-<kit>
    For kit specific help.
  help-${Seg}
    Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # SegId exists
$(call Check-Segment-Conflicts)
endif # SegId
# -----
