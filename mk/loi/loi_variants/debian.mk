#+
# OS Variant definitions for the Debian OS.
#-
$(info Using OS variant: ${SBC_OS_VARIANT})

ifeq (${MAKECMDGOALS},help-debian)
define HelpDebianMsg
Make segment: debian.mk

Generalizes access to an Debian based OS image.

Defines:

Command line targets:

Uses:

endef

export HelpDebianMsg
help-options:
> @echo "$$HelpDebianMsg"

endif
