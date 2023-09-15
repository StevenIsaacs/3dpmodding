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

mod_deps :=
used_mods :=

define use-mod
$.ifeq ($(1),)
$$(call Signal-Error,use-mod:The mod has not been specified.)
$.else $.ifneq ($(1)_seg,)
$$(call Signal-Error,use-mod:Kit $(1) is already in use.)
$.else
$$(call Verbose,Using mod: $(1))

$(call declare-comp,$(1),${$(2)_path}/$(1))

# Pseudo code:
# IF the mod exists
  $.ifneq $($$(wildcard $${$(1)_mk}),)
    mod_deps += $$($(1)_mk)
# 2 IF the mod attribute $(1)_REPO is not defined
    $.ifeq ($(2),)
      $$(call Verbose,Setting $(1)_REPO using clone directory.)
#     Define $(1)_REPO using the existing repo
      $(1)_REPO := \
        $$(shell cd $${$(1)_path} && git config --get remote.origin.url)
#     Save the discovered value as a sticky variable
      $$(call Redefine-Sticky,$(1)_REPO)
      $$(call Debug,$(1)_REPO:$${$(1)_REPO})
# 2 ENDIF
    $.endif
# 2 IF the mod attribute $(1)_BRANCH is not defined
    $.ifeq ($(3),)
      $$(call Verbose,Setting $(1)_BRANCH using clone directory.)
#     Define $(1)_BRANCH using the existing repo
      $(1)_BRANCH := \
        $$(shell cd $${$(1)_path} && git rev-parse --abbrev-ref HEAD)
#     Save the discovered value as a sticky variable
      $$(call Redefine-Sticky,$(1)_BRANCH)
      $$(call Debug,$(1)_BRANCH:$${$(1)_BRANCH})
# 2 ENDIF
    $.endif
#   Add a segment path for the mod
    $$(call Add-Segment-Path,$${$(1)_path})
#   Use the mod segment
    $$(Use-Segment,$(1))
    used_mods += $(1)
# ELSE the mod does not exist locally
  $.else
# Use git to clone the mod from the server $(1)_REPO.
$${$(1)_mk}:
> mkdir -p ${KITS_PATH}
> git clone $${$(1)_REPO} $${$(1)_path}
> cd $${$(1)_path} && git checkout $${$(1)_BRANCH}

    $$(call Use-Segment,$${$(1)_mk})
    used_mods += $(1)
# ENDIF Mod exists
  $.endif
  $(1)_mods := $(filter-out .git,$(call Directories-In,${$(1)_path}))
$.endif
endef # use-mod

new_mods :=
new_mod_deps :=

define new-mod
$.ifneq ($(1)_seg,)
$$(call Signal-Error,new-mod:Kit $(1) is already in use.)
$.else
$$(call Verbose,Creating new mod: $(1))

$(call declare-comp,$(1),${$(2)_path}/$(1))

# Confirm create mod
# IF Yes
  $.ifneq ($$(call Confirm,Create new mod $(1)?,y),)
    $$(call Sticky,$(1)_REPO=$(2),DEFAULT_KIT_REPO)
    $$(call Sticky,$(1)_BRANCH=$(3),DEFAULT_KIT_BRANCH)
# 2 IF a basis mod has NOT been specified
    $.ifeq ($(4),)
#     Not using a BASIS_KIT
#     Use git to initialize a new mod repo
      $$(call Info,Creating mod: $(1))
      k_$${$(1)_var}_seg := \
        $$(call Gen-Segment,\
        Kit specific definitions for mod: $(1),$(1):)
      $.export k_$${$(1)_var}_seg

$${$(1)_path}/.git:
> git init -b $${$(1)_BRANCH} $${@D}

$${$(1)_mk}: $${$(1)_path}/.git
> mkdir -p $$(@D) && printf "%s" "$${Dlr}k_$${$(1)_var}_seg" > $$@

# New mods must be initialized using this goal to avoid typos creating
# useless mods.
$(1)-create-mod: $${$(1)_mk}
> @echo Kit $(1) has been created.

# 2 ELSE use a basis mod to create the new mod
    $.else # Use existing basis mod.
      $$(call Info,Creating mod: $(1) using $(2))
      $(call declare-comp-mod,k_basis_$(1))
#   3 IF the basis mod exists
      $.ifneq ($$(wildcard $${k_basis_$(1)_path},))

#       Use git to clone the existing mod (git clone basis new)
#       Use git to remove the origin of the new mod (git remote rm origin)

# The basis mod segment is retained in the new mod for reference.
$(1)-create-mod: $${k_basis_$(1)_mk}
> git clone k_basis_$(2)_path $(1)_path
> git remote rm origin $(1)_path
> echo "# Derived from basis project - $(2)" > $${$(1)_mk}
> sed \
    -e 's/$${k_basis_$(1)_var}/$${$(1)_var}/g' \
    -e 's/$(2)/$(1)/g' \
    $${k_basis_$(1)_mk} >> $${$(1)_mk}

#   3 ELSE The basis mod does not exist.
      $.else
        $$(call Signal-Error,Seed mod $(2) does not exist.)
#   3 ENDIF Seed mod exists.
      $.endif
# 2 ENDIF Use basis mod.
    $.endif
  new_mods += $(1)
  new_mod_deps := $(1)-create-mod
  $$(call Sticky,$(1)_REPO=${DEFAULT_KIT_REPO})
  $$(call Sticky,$(1)_BRANCH=${DEFAULT_KIT_BRANCH})
# ELSE NO, don't create a new mod.
  $.else
    $$(call Signal-Error,Kit $(1) does not exist and not creating.)

$(1)-create-mod:

# ENDIF
  $.endif
$.endif
endef # new-mod

${Seg} = $(filter-out .git,$(call Directories-In,${KITS_PATH}))

ifneq (${NEW_KIT},)
  $(eval $(call new-mod,${NEW_KIT},${BASIS_KIT}))
endif

create-mod: ${new_mod_deps}

else
# Load the active mod.
$(eval $(call use-mod,${KIT},${KIT_REPO},${KIT_BRANCH}))

$(call Use-Segment,mods)

endif

#+++++ Move to mods.mk
mod_path := ${k_$(4)_path}/${MOD}
# Be sure a mod and mod are specified before allowing a build.
ifneq ($(and $(1),${$(1)_REPO},${$(1)_BRANCH},${MOD}),)


$(call Add-Segment-Path,${mod_path})

# Where the mod intermediate files are stored.
mod_build_path = ${BUILD_PATH}/$(1)/${$(1)_BRANCH}/${MOD}
# Where the mod output files are staged.
mod_staging_path = ${STAGING_PATH}/$(1)/${$(1)_BRANCH}/${MOD}
  ifeq (${MOD},)
    $(call Signal-Error,MOD has not been defined)
  endif
$(call Use-Segment,${MOD})
endif
#----- Move to mods.mk

#$(eval $(call use-mod,${KIT},$(call To-Shell-Var,${KIT},${BASIS_KIT})))

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
