#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Modding a Linux OS image (LOI).
#----------------------------------------------------------------------------

$(call require,\
mod.mk, \
HUI_OS_VARIANT \
HUI_OS_BOARD \
HUI_ADMIN \
HUI_ADMIN_ID \
HUI_ADMIN_GID \
HUI_USER \
HUI_USER_ID \
HUI_USER_GID \
HUI_ACCESS \
)

# Ensure using one of the valid access modes.
$(call must_be_one_of,HUI_ACCESS,console ssh brokered)

LOI_DIR = ${MK_DIR}/loi

# Common Linux paths.
# Relative to the mounted OS image and running in QEMU/proot or on the
# target board.
LINUX_TMP_DIR = /tmp
LINUX_ETC_DIR = /etc
LINUX_HOME_DIR = /home
LINUX_USER_HOME_DIR = ${LINUX_HOME_DIR}/${HUI_USER}
LINUX_USER_TMP_DIR = ${LINUX_USER_HOME_DIR}/tmp
LINUX_ADMIN_HOME_DIR = ${LINUX_HOME_DIR}/${HUI_ADMIN}
LINUX_ADMIN_TMP_DIR = ${LINUX_ADMIN_HOME_DIR}/tmp

include ${LOI_DIR}/loi.mk

ifeq (${MAKECMDGOALS},help-linux)
define HelpLinuxMsg
Make segment: linux.mk

This segment serves as a wrapper for the Linux OS image modding segments. Its
purpose is to provide a means for overriding the paths to the modding segments.

Defined in mod.mk (required):
  HUI_OS_VARIANT = ${HUI_OS_VARIANT}
    Which variant or branch to use.
  HUI_OS_BOARD = ${HUI_OS_BOARD}
    Which board the OS will be installed on.

Defines:
  LOI_DIR = ${LOI_DIR}
    Where the Linux OS Image modding segments are maintained. This is provided
    in case a custom LOI is used.
  LINUX_TMP_DIR = ${LINUX_TMP_DIR}
    Where temporary files are stored.
  LINUX_ETC_DIR = ${LINUX_ETC_DIR}
    System configuration files.
  LINUX_HOME_DIR = ${LINUX_HOME_DIR}
    Where user directories are commonly located.
  LINUX_USER_HOME_DIR = ${LINUX_USER_HOME_DIR}
    The home directory for the unpriviledged user.
  LINUX_USER_TMP_DIR = ${LINUX_USER_TMP_DIR}
    Where to store temporary files for the unpriviledged user.
  LINUX_ADMIN_HOME_DIR = ${LINUX_ADMIN_HOME_DIR}
    The home directory of the priviledged user (system admin).
  LINUX_ADMIN_TMP_DIR = ${LINUX_ADMIN_TMP_DIR}
    Where to store temporary files for the priviledged user (system admin).

Command line targets:
  help-linux  Display this help.

endef

export HelpLinuxMsg
help-linux:
> @echo "$$HelpLinuxMsg" | less
endif
