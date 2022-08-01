#+
# OS Variant definitions for the Armbian OS.
#-
$(info Using OS variant: ${SBC_OS_VARIANT})

ifeq (${MAKECMDGOALS},help-${SBC_OS_VARIANT})
define Help${SBC_OS_VARIANT}Msg
Make segment: ${SBC_OS_VARIANT}.mk

OS variant specific initialization and first run of an ${SBC_OS_VARIANT} based
OS image.

Defines:
Command line targets:

Uses:

endef
endif # help-${SBC_OS_VARIANT}

include ${LOI_VARIANTS_DIR}/generic.mk
