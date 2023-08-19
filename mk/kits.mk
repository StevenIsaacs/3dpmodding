#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Install kits and load the kit and the mod.
#----------------------------------------------------------------------------
# The prefix kits must be unique for all files.
# +++++
# Preamble
ifndef kitsSegId
$(call Enter-Segment,kits)
# -----

$(call Sticky,KITS_PATH,${DEFAULT_KITS_PATH})

# The active kit.
$(call Sticky,KIT)

ifneq (${KIT},)
  ifneq (KIT_REPO,)
    ${KIT}_REPO := ${KIT_REPO}
  endif
  $(call Sticky,${KIT}_REPO)
  ifneq (${KIT_BRANCH},)
    ${KIT}_BRANCH := ${KIT_BRANCH}
  endif
  $(call Sticky,${KIT}_BRANCH)
  $(call Sticky,MOD)
endif

define use-kit
# Where the kit is cloned to.
kit_dir = ${KIT}
kit_path = ${KITS_PATH}/${kit_dir}
kit_mk = ${kit_path}/${KIT}.mk
mod_path = ${kit_path}/${MOD}

# If the clone directory exists but the kit repo is not known get the URL
# from the clone.
ifneq (${KIT},)
  ifeq (${${KIT}_REPO},)
    ifneq ($(wildcard ${kit_path}),)
      $(call Verbose,Setting ${KIT}_REPO using clone directory.)
      ${KIT}_REPO := \
        $(shell cd ${kit_path} && git config --get remote.origin.url)
      $(call Redefine-Sticky,${KIT}_REPO)
      $(call Debug,${KIT}_REPO:${${KIT}_REPO})
    else
      $(call Verbose,Cannot set ${KIT}_REPO.)
    endif
  endif

  # Similarly, if the branch has not been defined then get it from the
  # existing clone.
  ifeq (${${KIT}_BRANCH},)
    ifneq ($(wildcard ${kit_path}),)
      $(call Verbose,Setting ${KIT}_BRANCH using clone directory.)
      ${KIT}_BRANCH := \
        $(shell cd ${kit_path} && git rev-parse --abbrev-ref HEAD)
      $(call Redefine-Sticky,${KIT}_BRANCH)
      $(call Debug,${KIT}_BRANCH:${${KIT}_BRANCH})
    endif
  endif
endif

kits = $(filter-out .git,$(call Directories-In,${KITS_PATH}))
mods = $(filter-out .git,$(call Directories-In,${kit_path}))

# Be sure a kit and mod are specified before allowing a build.
ifneq ($(and ${KIT},${${KIT}_REPO},${${KIT}_BRANCH},${MOD}),)

$(call Add-Segment-Path,${kit_path} ${mod_path})

# Where the mod intermediate files are stored.
mod_build_path = ${BUILD_PATH}/${KIT}/${${KIT}_BRANCH}/${MOD}
# Where the mod output files are staged.
mod_staging_path = ${STAGING_PATH}/${KIT}/${${KIT}_BRANCH}/${MOD}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Supported mod kit descriptions.
#----------------------------------------------------------------------------

ifneq ($(call Is-Goal,kit-branches),)
kit-branches:
> git ls-remote -h $(${KIT}_REPO)
else ifeq (${Errors},)
${kit_mk}:
> mkdir -p ${KITS_PATH}
> cd ${KITS_PATH} && git clone ${${KIT}_REPO} ${kit_dir}
> cd ${KITS_PATH}/${kit_dir} && git checkout ${${KIT}_BRANCH}

# Clone the kit and load the mod using the kit. The kit then defines kit
# specific variables and goals.
# NOTE: Using the .mk extension causes a direct include which in turn
# triggers the clone if the kit doesn't exist.
$(call Use-Segment,${kit_mk})
$(call Use-Segment,${MOD})

else
  $(call Signal-Error,A kit has not been properly defined.)
endif

# Switch to a different kit branch.
change-kit-branch:
> cd ${kit_path} && git branch -m ${${KIT}_BRANCH}

else
  $(call Signal-Error,Incomplete kit and mod specification.)
  ifeq (${KIT},)
    $(call Signal-Error,KIT has not been defined)
  endif # KIT defined.

  ifeq (${${KIT}_REPO},)
    $(call Signal-Error,KIT_REPO has not been defined)
  endif

  ifeq (${${KIT}_BRANCH},)
    $(call Signal-Error,KIT_BRANCH has not been defined)
  endif

  ifeq (${MOD},)
    $(call Signal-Error,MOD has not been defined)
  endif
endif # Kit defined

endef # use-kit

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${kitsSeg}),)
$(info Help message variable: help_${kitsSegN}_msg)
define help_${kitsSegN}_msg
Make segment: ${kitsSeg}.mk

A kit is a collection of mods. Each kit is assumed to be maintained in a
separate git repository.

This segment defines variables based upon the selected mod kit. A number
of supported kits will be available.

ModFW does expects config files to be maintained as part of a repository.
If a repository does not exist in the KIT_CONFIGS_PATH then one is initialized.
All generated config files are automatically added to this repository.

NOTE: ModFW automatically creates and selects branches in this repository
using PROJECT as the branch name.

The developer can optionally create a kit specific repository and use the
KIT_CONFIGS_PATH sticky variable to use it. The repository is automatically
initialized if it doesn't exist.

Required sticky command line variables:
  KIT=${KIT}
    Selects which kit of mods to use.
    This is required when no kit has been selected. Once selected this
    becomes optional.
  MOD=${MOD}
    Which mod to build.

Optional sticky variables:
  These are required if the clone directory doesn't exist. If the clone
  directory does exist then they will be set using git to determine the
  repository URL and the active branch. This feature allows use of a local
  repository or one that was cloned manually.
  ${KIT}_REPO = ${${KIT}_REPO}
    Synonym = KIT_REPO
    The git repo to clone to download the kit.
  ${KIT}_BRANCH = ${${KIT}_BRANCH}
    Synonym = KIT_BRANCH
    Which version of the kit to use. This determines which branch to checkout
    once cloned.
  KIT_CONFIGS_PATH = ${KIT_CONFIGS_PATH}
    Where generated config files are maintained. This can be a path to a
    repository maintained by the developer.

Defined in config.mk:
  KITS_PATH = ${KITS_PATH}
    Where mod kits are installed (cloned from a git repo).
  STAGING_PATH = ${STAGING_PATH}
    The top level staging directory.

Defines:
  kit_dir = ${kit_dir}
    The name of the directory the ${KIT} is cloned to.
  kit_path = ${kit_path}
    Where the kit is cloned to.
  kit_mk = ${kit_mk}
    The makefile segment defining the kit.
  kit_config_mk = ${kit_config_mk}
    The kit and mod specific configs file. This file is generated if it
    does not exist.
  mod_path = ${mod_path}
    The path to the currently selected mod.
  mod_build_path = ${mod_build_path}
    Where the mod intermediate files are stored.
  mod_staging_path = ${mod_staging_path}
    Where the mod output files are staged.

Macros:
  use-kit
    Declare kit specific variables, macros and, goals (a namespace). This
    allows having one kit or mod depend upon the output of different kit. If
    the kit segment exists then it is loaded.
    Command line goals:
      <kit>-create-kit
        This goal is fully defined only when the create-kit goal (below) is
        used. To reduce the possibility of accidental creation of new kits
        this goal does nothing if the create-kit goal is not in the list of
        command line goals.
    Parameters:
      1 = The kit file name. This is used to name:
            The kit make segment file.
            The kit directory.
            Project specific goals.
      2 = The kit variable name. This is used as part of variable
          declarations to create variables specific to the kit. Typically
          this should be equal to $$(call To-Name,<kit file base name>).
      3 = The optional seed kit to use if creating a new kit. The
          contents of the seed kit directory are copied to the new
          kit. The seed kit makefile segment is used to generate the
          new kit makefile segment.

Command line goals:
  help-${kitsSeg}
    Display this help.
  show-kits
    Display a list of kits installed in ${kit_dir}.
  show-mods
    Display a list of mods contained within the kit.
  kit-branches
    List the available branches in a kit. This displays the branches in the
    remote repository without installing the kit.
  change-kit-branch
    Switch to a different branch (${KIT}_BRANCH) for the kit.

See also:
  help-${KIT}
    For kit specific help.
  help-${MOD}
    For mod specific help.
endef
endif # help goal message.

$(call Exit-Segment,kits)
else # kitsSegId exists
$(call Check-Segment-Conflicts,kits)
endif # kitsSegId
# -----
