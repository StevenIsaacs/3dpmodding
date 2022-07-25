#+
# Defines variables, targets, and functions for configuring an OS for GUI
# access.
#-

ifeq (${MAKECMDGOALS},help-${HUI_ACCESS_METHOD})
define Help${HUI_ACCESS_METHOD}Msg
Make segment: ${HUI_ACCESS_METHOD}.mk

This defines the variables, targets, and functions for configuring an OS for
GUI (graphical user interface) access.

GUI access can also use one of the other access methods.

endef

export Help${HUI_ACCESS_METHOD}Msg
help-${HUI_ACCESS_METHOD}:
> @echo "$$Help${HUI_ACCESS_METHOD}Msg"

endif # help-${HUI_ACCESS_METHOD}
