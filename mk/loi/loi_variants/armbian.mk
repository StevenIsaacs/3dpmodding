#+
# OS Variant definitions for the Armbian OS.
#-
$(info Using OS variant: ${HUI_OS_VARIANT})

ifeq (${MAKECMDGOALS},help-${HUI_OS_VARIANT})
define Help${HUI_OS_VARIANT}Msg
Make segment: ${HUI_OS_VARIANT}.mk

OS variant specific initialization and first run of an ${HUI_OS_VARIANT} based
OS image.

Defines:
Command line targets:

Uses:

endef
endif # help-${HUI_OS_VARIANT}

include ${LOI_VARIANTS_DIR}/generic.mk
