#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Octoprint
#----------------------------------------------------------------------------

$(eval $(call require_this,OS))

include ${MK_DIR}/${OS}.mk

define OctoPrintInitScript
  python - venv OctoPrint
  OctoPrint/bin/pip install OctoPrint
  ./
endef

.PHONY: init-octoprint
init-octoprint:
	echo ${OctoPrintInitScript} > ${OS_IMAGE_MNT_DIR}/root/home/${OCTOPRINT_USER}

ifeq (${MAKECMDGOALS},help-octoprint)
define HelpOctoprintMsg
Make segment: octoprint.mk

This segement is used to install the OctoPrint initialization script in
an OS image for controlling a 3D printer.

Defined in mod.mk:
  SERVER_SOFTWARE = ${SERVER_SOFTWARE}
    Must equal octoprint for this segment to be used.
  OS = ${OS}
    Which OS is installed on the server board (OS_BOARD).
  OS_BOARD = ${OS_BOARD}
    Which SBC will be used to run OctoPrint.
  OS_VARIANT = ${OS_VARIANT}
    The OS to install the OctoPrint initialization script.

Defined in config.mk:

Defines:

Command line targets:
  help-octoprint        Display this help.
  init-octoprint        Install the initialization script for OctoPrint.

Uses:

endef

export HelpOctoprintMsg
help-octoprint:
	@echo "$$HelpOctoprintMsg" | less

else
  $(call requires,OS OS_BOARD OS_VARIANT)
endif
