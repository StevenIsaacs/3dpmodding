#+
# Overrides for testing.
#-
LOG_FILE := testing.log
$(call Enable-Log-File)
# DEBUG := 1
VERBOSE := 1
PREPEND := test-suites/test-modfw.mk
# STOP_ON_ERROR = 1
MAKEFLAGS += --warn-undefined-variables
