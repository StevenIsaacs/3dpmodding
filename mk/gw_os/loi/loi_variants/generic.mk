#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Generalizes initialization and first run of a Linux based OS image.
#----------------------------------------------------------------------------
# The prefix $(call Last-Segment-Basename) must be unique for all files.
# +++++
# Preamble
ifndef $(call Last-Segment-Basename)SegId
$(call Enter-Segment)
# -----
# Restrict to command line target only.
ifneq ($(call Is-Goal,stage-os-image),)

define ${lgenSegN}_firstrun_script
#!/bin/bash
# NOTE: This is normally /etc/rc.local. Systemd checks for the existence of
# this script and that it is executable and if so executes it at the end of the
# first multiuser run level.

# Load the OS variant initialization.
if [ -f ${${GW_OS_VARIANT}_TMP_PATH}/${${GW_OS_VARIANT}_SCRIPT} ]; then
  . ${${GW_OS_VARIANT}_TMP_PATH}/${${GW_OS_VARIANT}_SCRIPT}
fi

# Load the access level initialization.
if [ -f ${${GW_OS_VARIANT}_TMP_PATH}/${${MCU_ACCESS_METHOD}_SCRIPT} ]; then
  . ${${GW_OS_VARIANT}_TMP_PATH}/${${MCU_ACCESS_METHOD}_SCRIPT}
fi

# Load the user interface specific initialization.
if [ -f ${${GW_OS_VARIANT}_TMP_PATH}/${GW_INIT_SCRIPT} ]; then
  . ${${GW_OS_VARIANT}_TMP_PATH}/${GW_INIT_SCRIPT}
fi

# Disable self.
chmod -x /etc/rc.local

echo Firsttime setup is complete. Rebooting to activate.

reboot

endef

define ${lgenSegN}_staging_script
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

echo GW_OS_ADMIN = $$GW_OS_ADMIN
echo GW_OS_ADMIN_ID = $$GW_OS_ADMIN_ID
echo GW_OS_ADMIN_GID = $$GW_OS_ADMIN_GID
echo GW_OS_USER = $$GW_OS_USER
echo GW_OS_USER_ID = $$GW_OS_USER_ID
echo GW_OS_USER_GID = $$GW_OS_USER_GID
echo GW_INIT = $$GW_INIT

error-exit () {
    echo Cleaning up after error.
}

# Create the users and set their default permissions.
useradd -u ${GW_USER_ID} -U -m ${GW_USER}
usermod -a -G dialout,input,tty ${GW_USER}
if [ "${GW_ADMIN}" != "${GW_USER}" ]; then
  useradd -u ${GW_ADMIN_ID} -U -m ${GW_ADMIN}
  usermod -a -G dialout,input,tty ${GW_ADMIN}
fi
# Make the ADMIN all powerful.
echo "${GW_ADMIN} ALL=(ALL) NOPASSWD: ALL" \
  > /etc/sudoers.d/010_${GW_ADMIN}

# Setup the firstrun script. This will run the first time the OS is booted
# on the target board.
cp $$ScriptPath/${GW_OS_VARIANT}-firstrun /etc/rc.local
chmod +x /etc/rc.local

endef

export ${lgenSegN}_firstrun_script
export ${lgenSegN}_staging_script
# This is called by stage-os-image in loi.mk and cannot be used stand-alone.
# The OS image has been mounted. This installs scripts and other files which
# are intended to be run once on first boot.
# Parameters:
#  1 = Where to store the init scripts.
define stage-${GW_OS_VARIANT}
  printf "%s" "$$${lgenSegN}_firstrun_script" > $(1)/${GW_OS_VARIANT}-firstrun; \
  printf "%s" "$$${lgenSegN}_staging_script" > $(1)/stage-${GW_OS_VARIANT}; \
  chmod +x $(1)/stage-${GW_OS_VARIANT}
endef

endif # stage-os-image

#+
# Definitions common to MOST OS variants. These can be overridden by a variant.
#-
$(call Require,\
LINUX_TMP_PATH \
LINUX_ETC_PATH \
LINUX_HOME_PATH \
LINUX_USER_HOME_PATH \
LINUX_USER_TMP_PATH \
LINUX_ADMIN_HOME_PATH \
LINUX_ADMIN_TMP_PATH \
)

${GW_OS_VARIANT}_TMP_PATH = ${LINUX_TMP_PATH}
${GW_OS_VARIANT}_ETC_PATH = ${LINUX_ETC_PATH}
${GW_OS_VARIANT}_HOME_PATH = ${LINUX_HOME_PATH}
${GW_OS_VARIANT}_USER_HOME_PATH = ${LINUX_USER_HOME_PATH}
${GW_OS_VARIANT}_USER_TMP_PATH = ${LINUX_USER_TMP_PATH}
${GW_OS_VARIANT}_ADMIN_HOME_PATH = ${LINUX_ADMIN_HOME_PATH}
${GW_OS_VARIANT}_ADMIN_TMP_PATH = ${LINUX_ADMIN_TMP_PATH}

# +++++
# Postamble
# Define help only if needed.
ifneq ($(call Is-Goal,help-${Seg}),)
define help_${SegV}_msg
Make segment: ${Seg}.mk

Generalizes initialization and first run of an ${GW_OS_VARIANT} based OS image.

Defines:
  See help-linux for more information
  ${GW_OS_VARIANT}_TMP_PATH = ${${GW_OS_VARIANT}_TMP_PATH}
  ${GW_OS_VARIANT}_ETC_PATH = ${${GW_OS_VARIANT}_ETC_PATH}
  ${GW_OS_VARIANT}_HOME_PATH = ${${GW_OS_VARIANT}_HOME_PATH}
  ${GW_OS_VARIANT}_USER_HOME_PATH = ${${GW_OS_VARIANT}_USER_HOME_PATH}
  ${GW_OS_VARIANT}_USER_TMP_PATH = ${${GW_OS_VARIANT}_USER_TMP_PATH}
  ${GW_OS_VARIANT}_ADMIN_HOME_PATH = ${${GW_OS_VARIANT}_ADMIN_HOME_PATH}
  ${GW_OS_VARIANT}_ADMIN_TMP_PATH = ${${GW_OS_VARIANT}_ADMIN_TMP_PATH}

  stage-${GW_OS_VARIANT}
    This is designed to be called only from the stage-os-image goal in
	loi.mk. This creates users and installs the first-run scripts.

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
