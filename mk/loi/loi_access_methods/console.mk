#+
# Defines variables, targets, and functions for configuring an OS for console
# access.
#-

ifeq (${MAKECMDGOALS},help-access-method)
define HelpAccessMethodMsg
Make segment: ${HUI_ACCESS_METHOD}.mk

This defines the variables, targets, and functions for configuring an OS for
console access. This is the lowest level of security and is completely open.
Root access is disabled but console and ssh access using passwords is possible.

endef

export HelpAccessMethodMsg
help-access-method:
> @echo "$$HelpAccessMethodMsg"

endif # help-access-method
