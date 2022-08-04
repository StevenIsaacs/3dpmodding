#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Helper scripts and make segments shared across projects.
#----------------------------------------------------------------------------

ifeq (${HELPERS_VARIANT},dev)
  HELPERS_REPO = git@github.com:StevenIsaacs/modfw-helpers.git
else
  HELPERS_REPO = https://github.com/StevenIsaacs/modfw-helpers.git
  HELPERS_VARIANT = main
endif

Macros = ${HELPERS_DIR}/macros.mk

# Macros must be loaded almost immediately. Because of this can't rely
# upon make to trigger cloning at the correct time. Therefore this takes
# a more direct approach.
_null := $(shell \
  if [ ! -f ${Macros} ]; then \
    git clone ${HELPERS_REPO} ${HELPERS_DIR}; \
    cd ${HELPERS_DIR}; git checkout ${HELPERS_VARIANT}; \
  fi \
)

# Helper macros.
include ${Macros}

# This is structured so that help-kits can be used to determine which kits
# are avialable without loading any kit or mod.
ifeq (${MAKECMDGOALS},help-helpers)
define HelpHelpersMsg
Make segment: helpers.mk

Clone the helpers. The clone is triggered by including the macros. This must
be included as early as possible.

Command line options:
  HELPERS_VARIANT = ${HELPERS_VARIANT}
    Which variant or branch to checkout. This defaults to 'main'. Using the
	devleopment variant (dev) requires valid github credentials. This needs
	to be used once to set variant. Once the helpers have been cloned this is
	no longer needed.

Defined in config.mk:
  HELPERS_DIR = ${HELPERS_DIR}
    Where the helpers are cloned to.

Command line targets:
  help-helpers     Display this help.

endef

export HelpHelpersMsg
help-helpers:
> @echo "$$HelpHelpersMsg" | less

endif # help-helpers
