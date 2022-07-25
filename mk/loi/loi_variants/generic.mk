# Restrict to command line target only.
ifeq (${MAKECMDGOALS},stage-os-image)

define GenericFirstrunScript
#!/bin/bash
# NOTE: This is normally /etc/rc.local. Systemd checks for the existance of
# this script and that it is execuable and if so executes it at the end of the
# first multiuser run level.

# Load the OS variant initialization.
if [ -f ${${HUI_OS_VARIANT}_TMP_DIR}/${${HUI_OS_VARIANT}_SCRIPT} ]; then
  . ${${HUI_OS_VARIANT}_TMP_DIR}/${${HUI_OS_VARIANT}_SCRIPT}
fi

# Load the access level initialization.
if [ -f ${${HUI_OS_VARIANT}_TMP_DIR}/${${HUI_ACCESS}_SCRIPT} ]; then
  . ${${HUI_OS_VARIANT}_TMP_DIR}/${${HUI_ACCESS}_SCRIPT}
fi

# Load the user interface specific initialization.
if [ -f ${${HUI_OS_VARIANT}_TMP_DIR}/${HUI_INIT_SCRIPT} ]; then
  . ${${HUI_OS_VARIANT}_TMP_DIR}/${HUI_INIT_SCRIPT}
fi

# Disable self.
chmod -x /etc/rc.local

echo Firsttime setup is complete. Rebooting to activate.

reboot

endef

define GenericStagingScript
#!/bin/bash
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# This script is designed to run in an emulation environment using QEMU.
#
# This creates two users. One has sudo privileges and the other is
# intended to be the normal unprivileged user. Login as root is disabled.
#
# NOTE: Although not recommended, the normal user can also be the admin
#       user.
#
# The firstboot script is installed into the image and systemd is configured
# to run the firstboot script. The firstboot script automatically disables
# itself following successful completion.
#-----------------------------------------------------------------------------
ScriptPath="$$( cd "$$( dirname "$${BASH_SOURCE[0]}" )" && pwd )"
cleanup=error-exit

# Load the common functions.
. $$ScriptPath/modfw-functions.sh

# Load the configuration.
. $$ScriptPath/options.conf

echo HUI_OS_ADMIN = $$HUI_OS_ADMIN
echo HUI_OS_ADMIN_ID = $$HUI_OS_ADMIN_ID
echo HUI_OS_ADMIN_GID = $$HUI_OS_ADMIN_GID
echo HUI_OS_USER = $$HUI_OS_USER
echo HUI_OS_USER_ID = $$HUI_OS_USER_ID
echo HUI_OS_USER_GID = $$HUI_OS_USER_GID
echo HUI_INIT = $$HUI_INIT

error-exit () {
    echo Cleaning up after error.
}

# Create the users and set their default permissions.
useradd -u ${HUI_USER_ID} -U -m ${HUI_USER}
usermod -a -G dialout,input,tty ${HUI_USER}
if [ "${HUI_ADMIN}" != "${HUI_USER}" ]; then
  useradd -u ${HUI_ADMIN_ID} -U -m ${HUI_ADMIN}
  usermod -a -G dialout,input,tty ${HUI_ADMIN}
fi
# Make the ADMIN all powerful.
echo "${HUI_ADMIN} ALL=(ALL) NOPASSWD: ALL" \
  > /etc/sudoers.d/010_${HUI_ADMIN}

# Setup the firstrun script. This will run the first time the OS is booted
# on the target board.
cp $$ScriptPath/${HUI_OS_VARIANT}-firstrun /etc/rc.local
chmod +x /etc/rc.local

endef

export GenericFirstrunScript
export GenericStagingScript
# This is called by stage-os-image in loi.mk and cannot be used stand-alone.
# The OS image has been mounted. This installs scripts and other files which
# are intended to be run once on first boot.
# Parameters:
#  1 = Where to store the init scripts.
define stage_${HUI_OS_VARIANT}
  printf "%s" "$$GenericFirstrunScript" > $(1)/${HUI_OS_VARIANT}-firstrun; \
  printf "%s" "$$GenericStagingScript" > $(1)/stage-${HUI_OS_VARIANT}; \
  chmod +x $(1)/stage-${HUI_OS_VARIANT}
endef

endif # stage-os-image

#+
# Definitions common to MOST OS variants. These can be overridden by a variant.
#-
$(call require,\
${HUI_OS}.mk,\
LINUX_TMP_DIR \
LINUX_ETC_DIR \
LINUX_HOME_DIR \
LINUX_USER_HOME_DIR \
LINUX_USER_TMP_DIR \
LINUX_ADMIN_HOME_DIR \
LINUX_ADMIN_TMP_DIR \
)

${HUI_OS_VARIANT}_TMP_DIR = ${LINUX_TMP_DIR}
${HUI_OS_VARIANT}_ETC_DIR = ${LINUX_ETC_DIR}
${HUI_OS_VARIANT}_HOME_DIR = ${LINUX_HOME_DIR}
${HUI_OS_VARIANT}_USER_HOME_DIR = ${LINUX_USER_HOME_DIR}
${HUI_OS_VARIANT}_USER_TMP_DIR = ${LINUX_USER_TMP_DIR}
${HUI_OS_VARIANT}_ADMIN_HOME_DIR = ${LINUX_ADMIN_HOME_DIR}
${HUI_OS_VARIANT}_ADMIN_TMP_DIR = ${LINUX_ADMIN_TMP_DIR}

ifeq (${MAKECMDGOALS},help-${HUI_OS_VARIANT})
define HelpGenericMsg
Make segment: generic.mk

Generalizes initialization and first run of an ${HUI_OS_VARIANT} based OS image.

Defines:
  See help-linux for more information
  ${HUI_OS_VARIANT}_TMP_DIR = ${${HUI_OS_VARIANT}_TMP_DIR}
  ${HUI_OS_VARIANT}_ETC_DIR = ${${HUI_OS_VARIANT}_ETC_DIR}
  ${HUI_OS_VARIANT}_HOME_DIR = ${${HUI_OS_VARIANT}_HOME_DIR}
  ${HUI_OS_VARIANT}_USER_HOME_DIR = ${${HUI_OS_VARIANT}_USER_HOME_DIR}
  ${HUI_OS_VARIANT}_USER_TMP_DIR = ${${HUI_OS_VARIANT}_USER_TMP_DIR}
  ${HUI_OS_VARIANT}_ADMIN_HOME_DIR = ${${HUI_OS_VARIANT}_ADMIN_HOME_DIR}
  ${HUI_OS_VARIANT}_ADMIN_TMP_DIR = ${${HUI_OS_VARIANT}_ADMIN_TMP_DIR}

  stage_${HUI_OS_VARIANT}
    This is designed to be called only from the stage-os-image target in
	loi.mk. This creates users and installs the first-run scripts.

Command line targets:

Uses:

endef

export Help${HUI_OS_VARIANT}Msg
help-${HUI_OS_VARIANT}:
> @echo "$$HelpGenericMsg"
> @echo "$$Help${HUI_OS_VARIANT}Msg"

endif
