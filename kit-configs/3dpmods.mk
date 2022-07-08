#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 3dpmods is a collection of mods intended for modding 3D printers.
#----------------------------------------------------------------------------

# ACTIVE_KIT indicates this is a valid kit.
ACTIVE_KIT = ${KIT}
ifeq (${${KIT}_VARIANT},dev)
  KIT_REPO = ${KIT_DEV_SERVER}/${KIT}.git
  KIT_VARIANT = dev
else
  KIT_REPO = ${KIT_REL_SERVER}/${KIT}.git
  ifeq (${${KIT}_VARIANT},rel)
    KIT_VARIANT = dev
   else
    KIT_VARIANT = ${${KIT}_VARIANT}
  endif
endif

ifeq (${MAKECMDGOALS},help-kit)
define HelpKitMsg
Make segment: ${KIT}.mk

This segment describes a kit of mods intended for developing or modding 3D
printers.

Parameters:
  KIT=${KIT}
    Selects which kit of mods to use.
    This is required when no kit has been selected. Once selected this
    becomes optional.

Defines:
  ACTIVE_KIT = ${ACTIVE_KIT}
    Which kit is currently being used.
  KIT_REPO = ${KIT_REPO}
    The repository from which to clone the kit containing the mod.
  KIT_VARIANT = ${KIT_VARIANT}
    The kit branch to checkout.

See also:
  help-config  Shared options.
  help-kits     Supported kits.
  help-mod      Mod specific help.

Command line targets:
  help-mods       Display this help.
endef

export HelpKitMsg
help-kit:
	@echo "$$HelpKitMsg" | less
endif
