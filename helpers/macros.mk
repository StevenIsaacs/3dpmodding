#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Helper macros for makefiles.
#----------------------------------------------------------------------------
#+
# NOTE: Helper macros can only use variables defined in config.mk.
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
# Get the included file directory path.
#
# Returns:
#   The segment base name.
#-
this_segment_dir = \
  $(basename $(dir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

#+
# Use this macro to verify variables are set.
#  Parameters:
#    1 = A list of required variables.
#-
define _require_this
  $(if ${$(1)},\
    $(info Required variable: $(1) = ${$(1)}),\
    $(error Variable $(1) must be set)\
  )
endef

define require
  $(info $(1))
  $(foreach v,$(2),$(call _require_this,$(v)))
endef

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
