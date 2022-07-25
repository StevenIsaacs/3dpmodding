#+
# Defines variables, targets, and functions for configuring an OS for console
# access.
#-

ifeq (${MAKECMDGOALS},help-${HUI_ACCESS_METHOD})
define Help${HUI_ACCESS_METHOD}Msg
Make segment: ${HUI_ACCESS_METHOD}.mk

This defines the variables, targets, and functions for configuring an OS for
console access. This is the lowest level of security and is completely open.
Root access is disabled but console and ssh access using passwords is possible.

endef

export Help${HUI_ACCESS_METHOD}Msg
help-${HUI_ACCESS_METHOD}:
> @echo "$$Help${HUI_ACCESS_METHOD}Msg"

endif # help-${HUI_ACCESS_METHOD}
