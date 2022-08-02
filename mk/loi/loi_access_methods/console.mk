#+
# Defines variables, targets, and functions for configuring an OS for console
# access.
#-

ifeq (${MAKECMDGOALS},help-access-method)
define HelpAccessMethodMsg
Make segment: ${GW_ACCESS_METHOD}.mk

This defines the variables, targets, and functions for configuring an OS for
console access. This is the lowest level of security and is completely open.
Root access is disabled but console and ssh access using passwords and sudo
is possible. This generates a script which is designed to be run as part
of the first run initialization.

endef

export HelpAccessMethodMsg
help-access-method:
> @echo "$$HelpAccessMethodMsg" | less

endif # help-access-method
