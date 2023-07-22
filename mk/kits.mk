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
$(call Sticky,KIT)
ifdef KIT_REPO
${KIT}_REPO = ${KIT_REPO}
endif
$(call Sticky,${KIT}_REPO)
ifdef KIT_BRANCH
${KIT}_BRANCH = ${KIT_BRANCH}
endif
$(call Sticky,${KIT}_BRANCH)
$(call Sticky,MOD)

# Where the kit is cloned to.
kit_clone_dir = ${KIT}-${${KIT}_BRANCH}
kit_path = ${KITS_PATH}/${kit_clone_dir}
kit_mk = ${kit_path}/${KIT}.mk

kits = $(call Directories-In,${KITS_PATH})
mods = $(call Directories-In,${kit_path})

mod_path = ${kit_path}/${MOD}

$(call Add-Segment-Path,${kit_path} ${mod_path})

# Where the mod intermediate files are stored.
mod_build_path = ${BUILD_PATH}/${KIT}/${${KIT}_BRANCH}/${MOD}
# Where the mod output files are staged.
mod_staging_path = ${STAGING_PATH}/${KIT}/${${KIT}_BRANCH}/${MOD}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Supported mod kit descriptions.
#----------------------------------------------------------------------------

ifeq (${KIT},)
  $(call Signal-Error,The kit has not been defined)
endif

ifeq (${${KIT}_BRANCH},)
  $(call Signal-Error,The kit branch has not been defined)
endif

ifeq (${MOD},)
  $(call Signal-Error,MOD has not been defined)
endif

ifneq ($(call Is-Goal,kit-branches),)
kit-branches:
> git ls-remote -h $(KIT_REPO)
else ifeq (${Errors},)
${kit_mk}:
> mkdir -p ${KITS_PATH}
> cd ${KITS_PATH} && git clone ${KIT_REPO} ${kit_clone_dir}
> cd ${KITS_PATH}/${kit_clone_dir} && git checkout ${${KIT}_BRANCH}

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
> cd ${kit_path} && git checkout ${${KIT}_BRANCH}

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${kitsSeg}),)
$(info Help message variable: help_${kitsSegN}_msg)
define help_${kitsSegN}_msg
Make segment: ${kitsSeg}.mk

<make segment help messages>
A mod kit is a collection of mods.

This segment defines variables based upon the selected mod kit. A number
of supported kits will be available. Additional custom kits can be defined in
overrides.mk or, preferably, another make segment included by overrides.mk.

Required sticky command line variables:
  KIT=${KIT}
    Selects which kit of mods to use.
    This is required when no kit has been selected. Once selected this
    becomes optional.
  ${KIT}_REPO = ${${KIT}_REPO}
    Synonym = KIT_REPO
    The GIT repo to clone to download the kit.
  ${KIT}_BRANCH = ${${KIT}_BRANCH}
    Synonym = KIT_BRANCH
    Which version of the kit to use. This determines which branch to checkout
    once cloned.
  MOD=${MOD}
    Which mod to load.

Defined in config.mk:
  KITS_PATH = ${KITS_PATH}
    Where mod kits are installed (cloned from a git repo).
  STAGING_PATH = ${STAGING_PATH}
    The top level staging directory.

Defines:
  kit_clone_dir = ${kit_clone_dir}
    The name of the directory the ${KIT} is cloned to.
  kit_path = ${kit_path}
    Where the kit is cloned to.
  kit_mk = ${kit_mk}
    The makefile segment defining the kit.
  mods = ${mods}
    A list of mods contained within the kit.
  mod_path = ${mod_path}
    The path to the currently selected mod.
  mod_build_path = ${mod_build_path}
    Where the mod intermediate files are stored.
  mod_staging_path = ${mod_staging_path}
    Where the mod output files are staged.

Command line goals:
  help-${kitsSeg}
    Display this help.
  show-kits
    Display a list of kits installed in ${kit_clone_dir}.
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
