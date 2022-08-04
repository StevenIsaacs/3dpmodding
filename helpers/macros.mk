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
#   The path to the current segment.
#-
this_segment_dir = \
  $(basename $(dir $(word $(words ${MAKEFILE_LIST}),${MAKEFILE_LIST})))

#+
# Use this macro to insert new lines into multiline messages.
#-
define newline
nlnl
endef

#+
# Use this macro to issue an error message as a warning and signal an
# error exit.
#  Paramaters:
#    1 = The error message.
#-
ifeq (${MAKECMDGOALS},help)
  define signal_error
    $(eval ErrorMessages += $(1)$(newline))
  endef
else
  define signal_error
    $(error ERROR: $1 -- Use: make help)
  endef
endif

#+
# Use this macro to verify variables are set.
#  Parameters:
#    1 = A list of required variables.
#-
define _require_this
  $(if ${$(1)},\
    ,\
    $(eval ErrorMessages += Variable $(1) must be defined in: $(2)$(newline))\
  )
endef

define require
  $(foreach v,$(2),$(call _require_this,$(v), $(1)))
endef

#+
# Verify a variable has a valid value. If doesn't then error.
# Parameters:
#  1 = Variable name
#  2 = List of valid values.
#-
define must_be_one_of
  $(if $(findstring ${$(1)},$(2)),\
    $(info $(1) = ${$(1)} and is a valid option),\
    $(warning $(1) must equal one of: $(2))\
  )
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
  $(eval $(1)=$(shell ${HELPERS_DIR}/sticky.sh $(1)=${$(1)} ${STICKY_DIR}))
endef

#+
# Get the basenames of all the files in a directory matching a glob pattern.
# Parameters:
#  1 = The glob pattern including path.
#+
define basenames_in
  $(foreach file,$(wildcard $(1)),$(basename $(notdir ${file})))
endef
