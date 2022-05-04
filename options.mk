#+
# Override these on the make command line as needed. Using overrides it should
# not be necessary to modify the makefile.
#-

# Where various tools are downloaded and installed.
# NOTE: This directory is in .gitignore.
$(shell mkdir -p tools)
TOOLS_DIR = $(realpath tools)

# For downloaded files.
DOWNLOADS_DIR = ${TOOLS_DIR}/downloads
OS_IMAGE_DIR = ${TOOLS_DIR}/os_images

#+
# Installing the 3D printer mods.
#-
MODS_DEV = YES
ifeq (${MODS_DEV},YES)
  MODS_REPO = git@github.com:StevenIsaacs/3dpmods.git
  MODS_BRANCH = dev
  MODS_DIR = 3dpmods-dev
else
  MODS_REPO = https://github.com:StevenIsaacs/3dpmods.git
  MODS_BRANCH = release/0.0.1
  MODS_DIR = 3dpmods
endif

#+
# For custom Marlin mods.
#
# The Marlin configurations are installed to serve as starting points
# for new mods or for comparison with existing mods.
#-
# MARLIN_DEV = YES
ifeq (${MARLIN_DEV},YES)
  MARLIN_REPO = git@github.com:StevenIsaacs/Marlin.git
  MARLIN_BRANCH = dev
  MARLIN_DIR = ${TOOLS_DIR}/marlin-dev
  MARLIN_CONFIG_REPO = git@github.com:StevenIsaacs/Configurations.git
  MARLIN_CONFIG_DIR = ${TOOLS_DIR}/marlin-configs-dev
else
  MARLIN_REPO = https://github.com/MarlinFirmware/Marlin.git
  MARLIN_BRANCH = bugfix-2.0.x
  MARLIN_DIR = ${TOOLS_DIR}/marlin
  MARLIN_CONFIG_REPO = https://github.com/MarlinFirmware/Configurations.git
  MARLIN_CONFIG_DIR = ${TOOLS_DIR}/marlin-configs
endif

#+
# Custom 3D printed parts.
#
# NOTE: ed-oscad supports multiple models. It may be more convenient to
# install ed-oscad in a different location than within this directory. If
# so then simply reference that other location using ED_OSCAD_DIR.
#
# The default assumes ed-oscad is installed with the intent of working with
# multiple models.
#-
ED_OSCAD_DEV=YES
ifeq (${ED_OSCAD_DEV},YES)
  ED_OSCAD_REPO = git@bitbucket.org:StevenIsaacs/ed-oscad.git
  ED_OSCAD_DIR = ${TOOLS_DIR}/ed-oscad-dev
  ED_OSCAD_BRANCH = dev
else
  ED_OSCAD_REPO = https://bitbucket.org/StevenIsaacs/ed-oscad.git
  ED_OSCAD_DIR = ${TOOLS_DIR}/ed-oscad
  ED_OSCAD_BRANCH = release/0.0.1
endif
