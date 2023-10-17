#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Modding a Linux OS image (LOI).
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----

# Common Linux paths.
# Relative to the mounted OS image and running in QEMU/proot or on the
# target board.
LINUX_TMP_PATH = /tmp
LINUX_ETC_PATH = /etc
LINUX_HOME_PATH = /home
LINUX_USER_HOME_PATH = ${LINUX_HOME_PATH}/${GW_USER}
LINUX_USER_TMP_PATH = ${LINUX_USER_HOME_PATH}/tmp
LINUX_ADMIN_HOME_PATH = ${LINUX_HOME_PATH}/${GW_ADMIN}
LINUX_ADMIN_TMP_PATH = ${LINUX_ADMIN_HOME_PATH}/tmp

$(call Use-Segment,loi/loi)

ifeq (${MAKECMDGOALS},help-linux)
define HelpLinuxMsg
Make segment: linux.mk

Command line goals:
  help-linux  Display this help.

endef

export HelpLinuxMsg
help-linux:
> @echo "$$HelpLinuxMsg" | less
endif
# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

This segment serves as a wrapper for the Linux OS image modding segments. Its
purpose is to provide a means for overriding the paths to the modding segments.

Defined in mod.mk (required):
  GW_OS_VARIANT = ${GW_OS_VARIANT}
    Which variant or branch to use.
  GW_OS_BOARD = ${GW_OS_BOARD}
    Which board the OS will be installed on.

Defines:
  LINUX_TMP_PATH = ${LINUX_TMP_PATH}
    Where temporary files are stored.
  LINUX_ETC_PATH = ${LINUX_ETC_PATH}
    System configuration files.
  LINUX_HOME_PATH = ${LINUX_HOME_PATH}
    Where user directories are commonly located.
  LINUX_USER_HOME_PATH = ${LINUX_USER_HOME_PATH}
    The home directory for the unpriviledged user.
  LINUX_USER_TMP_PATH = ${LINUX_USER_TMP_PATH}
    Where to store temporary files for the unpriviledged user.
  LINUX_ADMIN_HOME_PATH = ${LINUX_ADMIN_HOME_PATH}
    The home directory of the priviledged user (system admin).
  LINUX_ADMIN_TMP_PATH = ${LINUX_ADMIN_TMP_PATH}
    Where to store temporary files for the priviledged user (system admin).

Command line goals:
  help-${Seg}
    Display this help.
endef
endif
$(call Exit-Segment)
else
$(call Check-Segment-Conflicts)
endif # SegId
# -----
