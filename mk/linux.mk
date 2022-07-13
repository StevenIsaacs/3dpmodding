#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Modding a Linux OS image (LOI).
#----------------------------------------------------------------------------

$(call require,OS_VARIANT OS_BOARD)

LOI_DIR = ${MK_DIR}/loi

include ${LOI_DIR}/loi.mk

ifeq (${MAKECMDGOALS},help-linux)
define HelpLinuxMsg
Make segment: linux.mk

This segment serves as a wrapper for the Linux OS image modding segments. Its
purpose is to provide a means for overriding the paths to the modding segments.

Defined in mod.mk (required):
  OS_VARIANT = ${OS_VARIANT}
    Which variant or branch to use.
  OS_BOARD = ${OS_BOARD}
    Which board the OS will be installed on.

Defines:
  LOI_DIR = ${LOI_DIR}
    Where the Linux OS Image modding segments are maintained. This is provided
    in case a custom LOI is used.

Command line targets:
  help-linux  Display this help.

endef

export HelpLinuxMsg
help-linux:
> @echo "$$HelpLinuxMsg" | less
endif
