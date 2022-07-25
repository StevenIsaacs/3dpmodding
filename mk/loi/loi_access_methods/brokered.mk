#+
# Defines variables, targets, and functions for configuring an OS for brokered
# access.
#-

ifeq (${MAKECMDGOALS},help-${HUI_ACCESS_METHOD})
define Help${HUI_ACCESS_METHOD}Msg
Make segment: ${HUI_ACCESS_METHOD}.mk

This defines the variables, targets, and functions for configuring an OS for
brokered access.

All ports are closed using a firewall. SSH login is not possible except by
way of the broker. SSH tunneling by way of the broker is possible and the
only means of access.

Access requires a valid broker account with valid keys.

endef

export Help${HUI_ACCESS_METHOD}Msg
help-${HUI_ACCESS_METHOD}:
> @echo "$$Help${HUI_ACCESS_METHOD}Msg"

endif # help-${HUI_ACCESS_METHOD}
