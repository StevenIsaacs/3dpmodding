#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Octoprint
#----------------------------------------------------------------------------
define OctoprintHelp
Make segment: octoprint.mk

This segement is used to install Octoprint in an OS image which can then
be copied to an SD card and booted on an SBC for controlling a 3D printer.

Defined in mod.mk:
  USE_OCTOPRINT = YES   Triggers include of this make segment.
  USE_OCTOPI = YES      Use a prebuilt OctoPi image. Requires USE_RPI3
                        or USE_RPI4.

Defined in options.mk:

  Define which SBC to use. These are mutually exclusive (use only one):
  USE_OPIZ = YES        OctoPrint on an Orange PI Zero.
  USE_RPI3 = YES        OctoPrint on a Raspberry PI 3.
  USE_RPI4 = YES        OctoPrint on a Raspberry PI 4.

Defines:
  MODEL_OPTIONS are appended in case the model defines cases for the boards.

Command line targets:
  help-octoprint        Display this help.

Uses:
  os_image.mk
  firsttime.mk
endef

export OctoprintHelp
help-octoprint:
	@echo "$$OctoprintHelp"

MODEL_OPTIONS += USE_OCTOPRINT=YES

# These are mutually exclusive options. Because USE_OCTOPRINT=YES at least
# one variant must be specified.
BuildOsVariant = $(filter YES,${USE_OPIZ} ${USE_RPI3} ${USE_RPI4})
ifeq (${BuildOsVariant},YES)
  $(info Building OS variant)
  # Only one option was specified.
  ifeq (${USE_OPIZ},YES)
    $(info OS platform: OPIZ)
    # Installation instructions are at:
    #  https://daumemo.com/installing-octoprint-on-orangepi-zero-part-1/
    MODEL_OPTIONS += USE_OPIZ=YES
    OS_VARIANT = OPIZ
  else
    # Select the case variation.
    ifeq (${USE_RPI3},YES)
      $(info OS platform: RPI3)
      MODEL_OPTIONS += USE_RPI3=YES
    else
      $(info OS platform: RPI4)
      MODEL_OPTIONS += USE_RPI4=YES
    endif
    ifeq (${USE_OCTOPI},YES)
      $(info OS variant: OCTOPI)
      # Pre-configured Raspberry PI OS (Raspian) image.
      OS_VARIANT = OCTOPI
	else
      $(info OS variant: RASPIOS)
      # Use an Raspberry PI OS image.
      OS_VARIANT = RASPIOS
	endif
  endif
  include ${mk_dir}/os_image.mk
  include ${mk_dir}/firsttime.mk
else
  ifeq (${BuildOsVariant},)
    $(error Select ONE and only ONE OS variant)
  else
    $(info OS Variants: ${BuildOsVariant})
    $(error Must select ONLY ONE OS variant)
  endif
endif
