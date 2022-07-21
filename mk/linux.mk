#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Modding a Linux OS image (LOI).
#----------------------------------------------------------------------------

$(call require,\
These must be defined by mod.mk, \
OS_VARIANT \
OS_BOARD \
SERVER_ADMIN \
SERVER_ADMIN_ID \
SERVER_ADMIN_GID \
SERVER_USER \
SERVER_USER_ID \
SERVER_USER_GID \
SERVER_ACCESS \
)

LOI_DIR = ${MK_DIR}/loi

# Common Linux paths.
# Relative to the mounted OS image and running in QEMU/proot or on the
# target board.
LINUX_TMP_DIR = /tmp
LINUX_ETC_DIR = /etc
LINUX_HOME_DIR = /home
LINUX_USER_HOME_DIR = ${LINUX_HOME_DIR}/${SERVER_USER}
LINUX_USER_TMP_DIR = ${LINUX_USER_HOME_DIR}/tmp
LINUX_ADMIN_HOME_DIR = ${LINUX_HOME_DIR}/${SERVER_ADMIN}
LINUX_ADMIN_TMP_DIR = ${LINUX_ADMIN_HOME_DIR}/tmp

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
