#+
# OS Variant definitions for the Armbian OS.
#-
$(info Using OS variant: ${GW_OS_VARIANT})

ifeq (${MAKECMDGOALS},help-${GW_OS_VARIANT})
define Help${GW_OS_VARIANT}Msg
Make segment: ${GW_OS_VARIANT}.mk

OS variant specific initialization and first run of an ${GW_OS_VARIANT} based
OS image.

Defines:
Command line targets:

Uses:

endef
endif # help-${GW_OS_VARIANT}

include ${LOI_VARIANTS_PATH}/generic.mk
