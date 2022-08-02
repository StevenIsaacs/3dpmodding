#+
# Defines variables, targets, and functions for configuring an OS for direct
# access.
#-

ifeq (${MAKECMDGOALS},help-access-method)
define HelpAccessMethodMsg
Make segment: ${GW_ACCESS_METHOD}.mk

In direct access there is no GW because in this case the workstation is also
the gateway to the controller.

endef

export HelpAccessMethodMsg
help-access-method:
> @echo "$$HelpAccessMethodMsg" | less

endif # help-access-method
