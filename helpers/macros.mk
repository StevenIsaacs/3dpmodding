#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Helper macros for makefiles.
#----------------------------------------------------------------------------
#+
# Helper macros can only use variables defined in config.mk.
#-

#+
# Make a variable sticky (see help-config).
# Parameters:
#  1 = Variable name
#-
define sticky
  $(info Sticky variable: ${1})
  $(eval $(1)=$(shell ${HELPER_DIR}/sticky.sh $(1)=${$(1)} ${STICKY_DIR}))
endef
