#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# OctoPrint
#----------------------------------------------------------------------------

$(call require,This must be defined in mod.mk,OS)

SERVER_INIT_SCRIPT = init-octoprint.sh

# Limit to stage-os-image only.
ifeq (${MAKECMDGOALS},stage-os-image)

define OctoPrintInitScript
# This is designed to be sourced (included) by the first run script. The
# first run script has already sourced the options.sh script.
# This runs as root. OctoPrint is installed as the unprivileged user.
# Following the intstructions found at:
#  https://community.octoprint.org/t/setting-up-octoprint-on-a-raspberry-pi-running-raspberry-pi-os-debian/2337

apt update
apt install python3-pip python3-dev python3-setuptools python3-venv
su - ${SERVER_USER}
mkdir OctoPrint && cd OctoPrint
python3 -m venv venv
. venv/bin/activate
pip install pip --upgrade
pip install octoprint
deactivate
exit
# Back as root.
cp ${${OS_VARIANT}_TMP_DIR}/octoprint.service /etc/systemd/system
systemctl enable octoprint.service

endef

# This was downloaded from:
# https://github.com/OctoPrint/OctoPrint/raw/master/scripts/octoprint.service
define OctoPrintService
[Unit]
Description=The snappy web interface for your 3D printer
After=network-online.target
Wants=network-online.target

[Service]
Environment="LC_ALL=C.UTF-8"
Environment="LANG=C.UTF-8"
Type=exec
User=${SERVER_USER}
ExecStart=/home/${SERVER_USER}/OctoPrint/venv/bin/octoprint

[Install]
WantedBy=multi-user.target

endef

export OctoPrintInitScript
export OctoPrintService

# This is called by stage-os-image in loi.mk. It generates the runtime
# init script along with the systemd service file for OctoPrint.
define stage_${SERVER_SOFTWARE}
  printf "%s" "$$OctoPrintInitScript" > $(1)/${SERVER_INIT_SCRIPT}; \
  printf "%s" "$$OctoPrintService" > $(1)/octoprint.service
endef

endif

include ${MK_DIR}/${OS}.mk

ifeq (${MAKECMDGOALS},help-octoprint)
define HelpOctoPrintMsg
Make segment: octoprint.mk

This segment is used to install the OctoPrint initialization script in
an OS image for controlling a 3D printer.

Defined in mod.mk:
  SERVER_SOFTWARE = ${SERVER_SOFTWARE}
    Must equal octoprint for this segment to be used.
  OS = ${OS}
    Which OS is installed on the server board (OS_BOARD).

Defined in config.mk:

Defined in ${OS}.mk or a segment it loads:
  OsDeps = ${OsDeps}
    A list of dependencies needed in order to mount an OS image for
    modification.

Defines:
  SERVER_INIT_SCRIPT = ${SERVER_INIT_SCRIPT}
    Defines the name of the server initialization script which is run in
    a QEMU emulation environment.

Command line targets:
  help-octoprint        Display this help.

endef

export HelpOctoPrintMsg
help-octoprint:
> @echo "$$HelpOctoPrintMsg" | less
endif
