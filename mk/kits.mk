#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Manage multiple ModFW kits using git, branches, and tags.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
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
$(call Sticky,KIT_REPO,${LOCAL_REPO})
$(call Sticky,KIT_BRANCH,${DEFAULT_BRANCH})

$(call activate-repo,KIT,${Seg},mods)
# If the kit exists then load the mods.
ifneq ($(wildcard ${${KIT}_repo_mk}),)
  $(call Use-Segment,mods)
else
  ifneq ($(call Is-Goal,activate-kit),)
    $(call Info,Kit ${KIT} is not installed -- activating.)
    # The active mod must be contained in the active kit so deactivate the
    # current mod.
    $(call Remove-Sticky,MOD)

# To build the active kit.
activate-kit: ${${KIT}_repo_mk}

  else
  $(call Warn,The active kit repo is not installed use activate-kit.)
  endif

endif


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
Mods can use additional kits using the "use-repo" macro (see help-repo-macros).

A set of kit specific variables (attributes) are defined for each kit being
used.

The kit specific sticky variables are stored in the active project.

Required sticky command line variables for the active kit:
  KIT=${KIT}
    Selects which kit is the active kit.
  KIT_REPO=${KIT_REPO}
    Default: DEFAULT_KIT_REPO = ${LOCAL_REPO}
    The repo to clone for the active kit.
  KIT_BRANCH=${KIT_BRANCH}
    Default: DEFAULT_KIT_BRANCH = ${DEFAULT_BRANCH}
    Branch in the active kit repo to install. This becomes part of the
    directory name for the kit.

Sticky variables for other kits:
  <kit>_REPO = (Defined by a project or a mod)
    Default: LOCAL_REPO = ${LOCAL_REPO}
    The repo to clone for the selected mod.
  <kit>_BRANCH = (Defined by a project or a mod)
    Default: DEFAULT_BRANCH = ${DEFAULT_BRANCH}
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

Command line goals:
  show-${Seg}
    Display a list of kits in the kits directory.
  activate-kit
    Activate the kit (${KIT}). This is available only when the kit hasn't been
    installed.
  remove-kits
    Remove all kit repositories. WARNING: Use with care. This is potentially
    destructive. As a precaution the dev is prompted to confirm before
    proceeding.
  help-<kit>
    Display the help message for a kit.
  help-${Seg}
    Display this help.
endef
endif # help goal message.

$(call Exit-Segment)
else # SegId exists
$(call Check-Segment-Conflicts)
endif # SegId
# -----
