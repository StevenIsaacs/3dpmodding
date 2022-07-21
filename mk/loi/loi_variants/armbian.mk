#+
# OS Variant definitions for the Armbian OS.
#-
$(info Using OS variant: ${OS_VARIANT})

# Restrict to command line target only.
ifeq (${MAKECMDGOALS},stage-os-image)

define ArmbianFirstrunScript
#!/bin/bash
# NOTE: This is normally /etc/rc.local. Systemd checks for the existance of
# this script and that it is execuable and if so executes it a the end of the
# first multiuser run level.

# Load the server specific initialization.
if [ -f ${${OS_VARIANT}_TMP_DIR}/${SERVER_INIT_SCRIPT} ]; then
  . ${${OS_VARIANT}_TMP_DIR}/${SERVER_INIT_SCRIPT}
fi

# Disable self.
chmod -x /etc/rc.local

echo Firsttime setup is complete. Rebooting to activate.

reboot

endef

define StageArmbianScript
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

echo OS_ADMIN = $$OS_ADMIN
echo OS_ADMIN_ID = $$OS_ADMIN_ID
echo OS_ADMIN_GID = $$OS_ADMIN_GID
echo OS_USER = $$OS_USER
echo OS_USER_ID = $$OS_USER_ID
echo OS_USER_GID = $$OS_USER_GID
echo SERVER_INIT = $$SERVER_INIT

error-exit () {
    echo Cleaning up after error.
}

# Create the users and set their default permissions.
useradd -u ${SERVER_USER_ID} -U -m ${SERVER_USER}
usermod -a -G dialout,input,tty ${SERVER_USER}
if [ "${SERVER_ADMIN}" != "${SERVER_USER}" ]; then
  useradd -u ${SERVER_ADMIN_ID} -U -m ${SERVER_ADMIN}
  usermod -a -G dialout,input,tty ${SERVER_ADMIN}
fi
echo "${SERVER_ADMIN} ALL=(ALL) NOPASSWD: ALL" \
  > /etc/sudoers.d/010_${SERVER_ADMIN}

# Enable ssh.
# On Armbian ssh is enabled by default.


# Setup the firstrun script. This will run the first time the OS is booted
# on the target board.
cp $$ScriptPath/${OS_VARIANT}-firstrun /etc/rc.local
chmod +x /etc/rc.local

endef

export ArmbianFirstrunScript
export StageArmbianScript
# This is called by stage-os-image in loi.mk and cannot be used stand-alone.
# The OS image has been mounted. This installs scripts and other files which
# are intended to be run once on first boot.
# Parameters:
#  1 = Where to store the init scripts.
define stage_${OS_VARIANT}
  printf "%s" "$$ArmbianFirstrunScript" > $(1)/${OS_VARIANT}-firstrun; \
  printf "%s" "$$StageArmbianScript" > $(1)/stage-${OS_VARIANT}; \
  chmod +x $(1)/stage-${OS_VARIANT}
endef

endif # stage-os-image

include ${LOI_VARIANTS_DIR}/common.mk
