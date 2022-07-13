#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Octoprint
#----------------------------------------------------------------------------

$(call require,OS)

include ${MK_DIR}/${OS}.mk

define OctoPrintInitScript
  python - venv OctoPrint
  OctoPrint/bin/pip install OctoPrint
  ./
endef

.PHONY: init-octoprint
init-octoprint: ${OsDeps}
	echo ${OctoPrintInitScript} > ${OS_IMAGE_MNT_DIR}/root/home/${OCTOPRINT_USER}

ifeq (${MAKECMDGOALS},help-octoprint)
define HelpOctoprintMsg
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

Command line targets:
  help-octoprint        Display this help.
  init-octoprint        Install the initialization script for OctoPrint.
                        This target must be used explicitly before an OS
                        image will be modified.

endef

export HelpOctoprintMsg
help-octoprint:
	@echo "$$HelpOctoprintMsg" | less

else
  $(call requires,OS OS_BOARD OS_VARIANT)
endif
