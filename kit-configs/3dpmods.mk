#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 3dpmods is a collection of mods intended for modding 3D printers.
#----------------------------------------------------------------------------
ifndef 3dpmodsSegId
3dpmodsSegId := $(call This-Segment-Id)
3dpmodsSeg := $(call This-Segment-Basename)
3dpmodsSegN := $(call This-Segment-Name)
3dpmods_prvSegId := ${SegId}
$(eval $(call Set-Segment-Context,${3dpmodsSegId}))

$(call Verbose,Make segment: $(call Get-Segment-Basename,${3dpmodsSegId}))


# active_kit indicates this is a valid kit.
active_kit = ${KIT}
ifeq (${${KIT}_BRANCH},dev)
  KIT_REPO = ${KIT_DEV_SERVER}/${KIT}.git
  KIT_VERSION = dev
else
  KIT_REPO = ${KIT_REL_SERVER}/${KIT}.git
  ifeq (${${KIT}_BRANCH},rel)
    KIT_VERSION = dev
   else
    KIT_VERSION = ${${KIT}_BRANCH}
  endif
endif

ifneq ($(call Is-Goal,help-${${Seg}}),)
$(info Help message variable: help_${Pfx}_${SegN}_msg)
define help_${Pfx}_${SegN}_msg
Make segment: ${KIT}.mk

This segment describes a kit of mods intended for developing or modding 3D
printers.

Parameters:
  KIT=${KIT}
    Selects which kit of mods to use.
    This is required when no kit has been selected. Once selected this
    becomes optional.

Defines:
  active_kit = ${active_kit}
    Which kit is currently being used.
  KIT_REPO = ${KIT_REPO}
    The repository from which to clone the kit containing the mod.
  KIT_VERSION = ${KIT_VERSION}
    The kit branch to checkout.

See also:
  help-config  Shared options.
  help-kits     Supported kits.
  help-mod      Mod specific help.

Command line goals:
  help-mods       Display this help.
endef

export help_${Pfx}_${SegN}_msg
help-${${Seg}}:
> @echo "$$help_${Pfx}_${SegN}_msg" | less
endif
$(eval $(call Set-Segment-Context,${3dpmods_prvSegId}))

else
$(call Add-Message,${3dpmodsSeg} has already been included)
endif
