#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# The Armbian based so this is installed to:
#   /root/mod_init
# Run this script after the first time login is complete.
#
# This creates two users. One has sudo privileges and the other is
# intended to be the normal unprivileged user. Login as root is disabled.
#
# If present a secondary script is run to perform initialization of components
# needed by the application.
#-----------------------------------------------------------------------------

# Load the configuration.
. /root/options.conf
# Load the mod specific initialization.
if [ -e /root/init_mod.sh ]; then
  . /root/init_mod.sh
fi

error-exit () {
    echo Cleaning up after error.
}

# Enable ssh.
# On Armbian ssh is enabled by default.
