#+
# Defines variables, targets, and functions for configuring an OS for ssh
# access.
#-

ifeq (${MAKECMDGOALS},help-access-method)
define HelpAccessMethodMsg
Make segment: ${HUI_ACCESS_METHOD}.mk

This defines the variables, targets, and functions for configuring an OS for
ssh access.

The SSH port can be set in mod.mk to something other than the typical port 22.
All other ports are closed using a firewall. Port forwarding is possible.
Root login is disabled. No passwords are allowed meaning the client must have
a key listed in authorized_keys.

endef

export HelpAccessMethodMsg
help-access-method:
> @echo "$$HelpAccessMethodMsg"

endif # help-access-method
