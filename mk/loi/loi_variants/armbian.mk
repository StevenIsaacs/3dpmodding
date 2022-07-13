#+
# OS Variant definitions for the Armbian OS.
#-
$(info Using OS variant: ${OS_VARIANT})

ifeq (${MAKECMDGOALS},help-armbian)
define HelpArmbianMsg
Make segment: armbian.mk

Generalizes access to an Armbian based OS image.

Defines:

Command line targets:

Uses:

endef

export HelpArmbianMsg
help-options:
> @echo "$$HelpArmbianMsg"

endif
