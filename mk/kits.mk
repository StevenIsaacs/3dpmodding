#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# A list of available mod kits.
#----------------------------------------------------------------------------
# Select a kit using KIT=<kit> on the make command line. The selection is
# sticky so once defined defaults to the previously selected kit.
# Additional kits can be defined in overrides.mk. Use the format similar
# to that used here.
#+

$(call sticky,KIT)
$(call sticky,${KIT}_VARIANT)
KIT_VARIANT = ${${KIT}_VARIANT}
$(call sticky,MOD)

# Where the kit is cloned to.
CLONE_DIR = ${KIT}-${${KIT}_VARIANT}
KIT_PATH = ${KITS_PATH}/${CLONE_DIR}
MOD_PATH = ${KIT_PATH}/${MOD}
# These can be overridden by the mod.
MODEL_PATH = $(MOD_PATH)/${MODEL_CLASS}

FIRMWARE_PATH = $(MOD_PATH)/${FIRMWARE_CLASS}
PCB_PATH = $(MOD_PATH)/${PCB_CLASS}

GW_OS_PATH = $(MOD_PATH)/${GW_OS_CLASS}
GW_APP_PATH = $(MOD_PATH)/$(GW_APP_CLASS)

# Where the mod intermediate files are stored.
MOD_BUILD_PATH = ${BUILD_PATH}/${KIT}/${KIT_VARIANT}/${MOD}
# Where the mod output files are staged.
MOD_STAGING_PATH = ${STAGING_PATH}/${KIT}/${KIT_VARIANT}/${MOD}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Supported mod kit descriptions.
#----------------------------------------------------------------------------

-include ${KIT_CONFIGS_PATH}/${KIT}.mk

# This is structured so that help-kits can be used to determine which kits
# are available without loading any kit or mod.
ifeq (${MAKECMDGOALS},help-kits)
define HelpKitsMsg
Make segment: kits.mk

A mod kit is a collection of mods.

This segment defines variables based upon the selected mod kit. A number
of supported kits will be available. Additional custom kits can be defined in
overrides.mk or, preferably, another make segment included by overrides.mk.

Required sticky command line options:
  KIT=${KIT}
    Selects which kit of mods to use.
    This is required when no kit has been selected. Once selected this
    becomes optional.
  ${KIT}_VARIANT = ${${KIT}_VARIANT}
    Which variant of the kit to use. This determines which repo URL to use
    to clone the kit and which branch to checkout once cloned. KIT_VARIANT
    is equal to this.
    Valid options are:
      rel = Use the current release branch.
      dev = Use the development branch.
      Otherwise the variant is assumed to be a valid branch.
  MOD=${MOD}
    Which mod to load.

Defines:
  CLONE_DIR = ${CLONE_DIR}
    The name of the directory for the kit clone.
  KIT_PATH = ${KIT_PATH}
    Where the kit is cloned to.
  MOD_BUILD_PATH = ${MOD_BUILD_PATH}
    Where the mod intermediate files are stored.
  MOD_STAGING_PATH = ${MOD_STAGING_PATH}
    Where the mod output files are staged.

Defined in config.mk:
  KIT_CONFIGS_PATH = ${KIT_CONFIGS_PATH}
    Where kit configurations are maintained. Override this for custom kits.
  KITS_PATH = ${KITS_PATH}
    Where mod kits are installed (cloned from a git repo).
  STAGING_PATH = ${STAGING_PATH}
    The top level staging directory.

A kit config defines:
  ActiveKit = ${ActiveKit}
    When defined indicates the selected kit has been defined. If not defined
> as a result of specifying a non-existant kit an error is reported.
  KIT_REPO = ${KIT_REPO}
    The git URL used to clone the kit.
  KIT_VARIANT = ${KIT_VARIANT}
    Which variant or branch to checkout after cloning.

Command line targets:
  help-kits        Display this help.

See also:
  help-${KIT}      For kit specific help.

Supported kits:
  3dpmods   For developing or modding 3D printers.
endef

export HelpKitsMsg
help-kits:
> @echo "$$HelpKitsMsg" | less

else

ifeq (${KIT},)
  $(call signal-error,The kit has not been defined)
else
  ifndef ActiveKit
    $(call signal-error,No description for the kit: ${KIT})
  endif
endif

ifeq (${KIT_VARIANT},)
  $(call signal-error,The kit variant has not been defined)
endif
ifeq (${MOD},)
  $(call signal-error,MOD has not been defined)
endif

_KitSegment = ${KIT_PATH}/kit.mk

${_KitSegment}:
> mkdir -p ${KITS_PATH}
> cd ${KITS_PATH}; git clone ${KIT_REPO} ${CLONE_DIR}
> cd ${KITS_PATH}/${CLONE_DIR}; git checkout ${KIT_VARIANT}

# Clone and load the kit and mod.
ifndef ErrorMessages
  include ${_KitSegment}
endif

endif
