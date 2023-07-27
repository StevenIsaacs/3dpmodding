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
ifneq (${KIT},)
  ifneq (KIT_REPO,)
    ${KIT}_REPO := ${KIT_REPO}
  endif
  $(call Sticky,${KIT}_REPO)
  ifneq (KIT_BRANCH,)
    ${KIT}_BRANCH := KIT_BRANCH
  endif
  $(call Sticky,${KIT}_BRANCH)
  $(call Sticky,MOD)
endif

$(call Sticky,OVERRIDES_PATH,${DEFAULT_OVERRIDES_PATH})

kit_override_mk = ${OVERRIDES_PATH}/${KIT}-o.mk

# Where the kit is cloned to.
kit_clone_dir = ${KIT}
kit_path = ${KITS_PATH}/${kit_clone_dir}
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

kits = $(call Directories-In,${KITS_PATH})
mods = $(call Directories-In,${kit_path})

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

# To generate the override file for a kit.
define ${KIT}_override_seg
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Kit specific overrides for kit: ${KIT}
#----------------------------------------------------------------------------
# The prefix ${KIT}_o_ must be unique for all files.
# The format of all the ${KIT}_o_ based names is required.
# +++++
# Preamble
$.ifndef ${KIT}_o_SegId
$$(call Enter-Segment,${KIT}_o_)
# -----

# Uncomment these to override the REPO and BRANCH for the kit.
# ${KTI}_REPO := ${${KIT}_REPO}
# ${KTI}_BRANCH := ${${KIT}_BRANCH}

# Add overrides here.

# +++++
# Postamble
# Define help only if needed.
$.ifneq ($$(call Is-Goal,help-${${KIT}_o_Seg}),)
$.define help_$${${KIT}_o_SegN}_msg
Make segment: $${${KIT}_o_Seg}.mk

Kit overrides for the kit: ${KIT}

# Add help messages here.

Defines:
  # Describe each override.

Command line goals:
  # Describe additional goals provided by the override.
  help-$${${KIT}_o_Seg}
    Display this help.
$.endef
$.endif # help goal message.

$$(call Exit-Segment,${KIT}_o_)
$.else # ${KIT}_o_SegId exists
$$(call Check-Segment-Conflicts,${KIT}_o_)
$.endif # ${KIT}_o_SegId
# -----
endef

export ${KIT}_override_seg
${kit_override_mk}:
> mkdir -p $(@D)
> printf "%s" "$$${KIT}_override_seg" > $(1)/${GW_INIT_SCRIPT}

ifneq ($(call Is-Goal,kit-branches),)
kit-branches:
> git ls-remote -h $(${KIT}_REPO)
else ifeq (${Errors},)
${kit_mk}:
> mkdir -p ${KITS_PATH}
> cd ${KITS_PATH} && git clone ${${KIT}_REPO} ${kit_clone_dir}
> cd ${KITS_PATH}/${kit_clone_dir} && git checkout ${${KIT}_BRANCH}

# Apply overrides before loading the kit and mod segments. NOTE: This will
# trigger generation of the override file if it doesn't already exist.
$(call Use-Segment.${kit_override_mk})

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

A kit specific override file (${kit_override_mk}) is generated if one
does not exist. This override file can then be used to override kit or mod
specific variables instead of using sticky variables. NOTE: In order for
overrides to work as expected they should be declared in the kit or mod using
Overridable macro.
ModFW does NOT expect override files to be maintained as part of a repository.
However, the developer can create a project specific repository and use the
OVERRIDES_PATH sticky variable to use it.

Required sticky command line variables:
  KIT=${KIT}
    Selects which kit of mods to use.
    This is required when no kit has been selected. Once selected this
    becomes optional.
  MOD=${MOD}
    Which mod to load.

Optional sticky variables:
  These are required if the clone directory doesn't exist. If the clone
  directory does exist then they will be set using git to determine the
  repository URL and the active branch. This feature allows use of a local
  repository or one that was cloned manually.
  ${KIT}_REPO = ${${KIT}_REPO}
    Synonym = KIT_REPO
    The GIT repo to clone to download the kit.
  ${KIT}_BRANCH = ${${KIT}_BRANCH}
    Synonym = KIT_BRANCH
    Which version of the kit to use. This determines which branch to checkout
    once cloned.
  OVERRIDES_PATH = ${OVERRIDES_PATH}
    Where generated override files are maintained. This can be a path to a
    repository maintained by the developer.

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
  kit_override_mk = ${kit_override_mk}
    The kit and mod specific overrides file. This file is generated if it
    does not exist.
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
