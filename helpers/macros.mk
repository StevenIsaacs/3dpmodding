#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Helper macros for makefiles.
#----------------------------------------------------------------------------
#+
# Helper macros can only use variables defined in config.mk.
#-

#+
# Get the included file base name (no path or extension).
#
# Returns:
#   The segment base name.
#-
this_segment = \
  $(basename $(notdir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

#+
# Make a variable sticky (see help-config).
# Parameters:
#  1 = Variable name
# Returns:
#  The variable value.
#-
define sticky
  $(info Sticky variable: ${1})
  $(eval $(1)=$(shell ${HELPER_DIR}/sticky.sh $(1)=${$(1)} ${STICKY_DIR}))
endef
