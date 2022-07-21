#+
# Definitions common to MOST OS variants. These can be overridden by a variant.
#-
$(call require,\
These must be defined in ${OS}.mk,\
LINUX_TMP_DIR \
LINUX_ETC_DIR \
LINUX_HOME_DIR \
LINUX_USER_HOME_DIR \
LINUX_USER_TMP_DIR \
LINUX_ADMIN_HOME_DIR \
LINUX_ADMIN_TMP_DIR \
)

${OS_VARIANT}_TMP_DIR = ${LINUX_TMP_DIR}
${OS_VARIANT}_ETC_DIR = ${LINUX_ETC_DIR}
${OS_VARIANT}_HOME_DIR = ${LINUX_HOME_DIR}
${OS_VARIANT}_USER_HOME_DIR = ${LINUX_USER_HOME_DIR}
${OS_VARIANT}_USER_TMP_DIR = ${LINUX_USER_TMP_DIR}
${OS_VARIANT}_ADMIN_HOME_DIR = ${LINUX_ADMIN_HOME_DIR}
${OS_VARIANT}_ADMIN_TMP_DIR = ${LINUX_ADMIN_TMP_DIR}

ifeq (${MAKECMDGOALS},help-${OS_VARIANT})
define Help${OS_VARIANT}Msg
Make segment: ${OS_VARIANT}.mk

Generalizes access to an ${OS_VARIANT} based OS image.

Defines:
  See help-linux for more information
  ${OS_VARIANT}_TMP_DIR = ${${OS_VARIANT}_TMP_DIR}
  ${OS_VARIANT}_ETC_DIR = ${${OS_VARIANT}_ETC_DIR}
  ${OS_VARIANT}_HOME_DIR = ${${OS_VARIANT}_HOME_DIR}
  ${OS_VARIANT}_USER_HOME_DIR = ${${OS_VARIANT}_USER_HOME_DIR}
  ${OS_VARIANT}_USER_TMP_DIR = ${${OS_VARIANT}_USER_TMP_DIR}
  ${OS_VARIANT}_ADMIN_HOME_DIR = ${${OS_VARIANT}_ADMIN_HOME_DIR}
  ${OS_VARIANT}_ADMIN_TMP_DIR = ${${OS_VARIANT}_ADMIN_TMP_DIR}

  stage_${OS_VARIANT}
    This is designed to be called only from the stage-os-image target in
	loi.mk. This creates users and installs the first-run scripts.

Command line targets:

Uses:

endef

export Help${OS_VARIANT}Msg
help-${OS_VARIANT}:
> @echo "$$Help${OS_VARIANT}Msg"

endif
