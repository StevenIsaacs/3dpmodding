#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Install kits and load the kit and the mod.
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
# If this is not equal to "local" then a remote repo is cloned to create
# the kit specific configurations. Otherwise, a new git repository is
# created and initialized.
$(call Overridable,DEFAULT_KIT_REPO,local)
# The branch used by the active project.
$(call Overridable,DEFAULT_KIT_BRANCH,main)

$(call Sticky,KITS_PATH,${DEFAULT_KITS_PATH})

# The active kit.
$(call Sticky,KIT)
$(call Sticky,KIT_REPO,DEFAULT_KIT_REPO)
$(call Sticky,KIT_BRANCH,DEFAULT_KIT_BRANCH)

kit_deps :=
used_kits :=

define use-kit
$.ifeq ($(1),)
$$(call Signal-Error,use-kit:The kit has not been specified.)
$.else $.ifneq ($(1)_seg,)
$$(call Info,use-kit:Kit $(1) is already in use.)
$.else
$$(call Verbose,Using kit: $(1))

$(call declare-comp,$(1),${KITS_PATH})

# Pseudo code:
# IF the kit exists
  $.ifneq $($$(wildcard $${$(1)_mk}),)
    kit_deps += $$($(1)_mk)
# 2 IF the kit attribute $(1)_REPO is not defined
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
# 2 IF the kit attribute $(1)_BRANCH is not defined
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
#   Add a segment path for the kit
    $$(call Add-Segment-Path,$${$(1)_path})
#   Use the kit segment
    $$(Use-Segment,$(1))
    used_kits += $(1)
# ELSE the kit does not exist locally
  $.else
# Use git to clone the kit from the server $(1)_REPO.
$${$(1)_mk}:
> mkdir -p ${KITS_PATH}
> git clone $${$(1)_REPO} $${$(1)_path}
> cd $${$(1)_path} && git checkout $${$(1)_BRANCH}

    $$(call Use-Segment,$${$(1)_mk})
    used_kits += $(1)
# ENDIF Kit exists
  $.endif
  $(1)_mods := $(filter-out .git,$(call Directories-In,${$(1)_path}))
$.endif
endef # use-kit

new_kits :=
new_kit_deps :=

define new-kit
$.ifneq ($(1)_seg,)
$$(call Signal-Error,new-kit:Kit $(1) is already in use.)
$.else
$$(call Verbose,Creating new kit: $(1))

$(call declare-comp,$(1),${KITS_PATH})

# Confirm create kit
# IF Yes
  $.ifneq ($$(call Confirm,Create new kit $(1)?,y),)
    $$(call Sticky,$(1)_REPO=$(2),DEFAULT_KIT_REPO)
    $$(call Sticky,$(1)_BRANCH=$(3),DEFAULT_KIT_BRANCH)
# 2 IF a basis kit has NOT been specified
    $.ifeq ($(4),)
#     Not using a BASIS_KIT
#     Use git to initialize a new kit repo
      $$(call Info,Creating kit: $(1))
      k_$${$(1)_var}_seg := \
        $$(call Gen-Segment,\
        Kit specific definitions for kit: $(1),$(1):)
      $.export k_$${$(1)_var}_seg

$${$(1)_path}/.git:
> git init -b $${$(1)_BRANCH} $${@D}

$${$(1)_mk}: $${$(1)_path}/.git
> mkdir -p $$(@D) && printf "%s" "$${Dlr}k_$${$(1)_var}_seg" > $$@

# New kits must be initialized using this goal to avoid typos creating
# useless kits.
$(1)-create-kit: $${$(1)_mk}
> @echo Kit $(1) has been created.

# 2 ELSE use a basis kit to create the new kit
    $.else # Use existing basis kit.
      $$(call Info,Creating kit: $(1) using $(2))
      $(call declare-comp-kit,k_basis_$(1))
#   3 IF the basis kit exists
      $.ifneq ($$(wildcard $${k_basis_$(1)_path},))

#       Use git to clone the existing kit (git clone basis new)
#       Use git to remove the origin of the new kit (git remote rm origin)

# The basis kit segment is retained in the new kit for reference.
$(1)-create-kit: $${k_basis_$(1)_mk}
> git clone k_basis_$(2)_path $(1)_path
> git remote rm origin $(1)_path
> echo "# Derived from basis project - $(2)" > $${$(1)_mk}
> sed \
    -e 's/$${k_basis_$(1)_var}/$${$(1)_var}/g' \
    -e 's/$(2)/$(1)/g' \
    $${k_basis_$(1)_mk} >> $${$(1)_mk}

#   3 ELSE The basis kit does not exist.
      $.else
        $$(call Signal-Error,Seed kit $(2) does not exist.)
#   3 ENDIF Seed kit exists.
      $.endif
# 2 ENDIF Use basis kit.
    $.endif
  new_kits += $(1)
  new_kit_deps := $(1)-create-kit
  $$(call Sticky,$(1)_REPO=${DEFAULT_KIT_REPO})
  $$(call Sticky,$(1)_BRANCH=${DEFAULT_KIT_BRANCH})
# ELSE NO, don't create a new kit.
  $.else
    $$(call Signal-Error,Kit $(1) does not exist and not creating.)

$(1)-create-kit:

# ENDIF
  $.endif
$.endif
endef # new-kit

${Seg} = $(filter-out .git,$(call Directories-In,${KITS_PATH}))

ifneq (${NEW_KIT},)
  $(eval $(call new-kit,${NEW_KIT},${BASIS_KIT}))
endif

create-kit: ${new_kit_deps}

# Load the active kit.
#$(eval $(call use-kit,${KIT},${KIT_REPO},${KIT_BRANCH}))

#$(call Use-Segment,mods)

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
