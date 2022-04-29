#+
# Modify this file to suite your needs. Using this file it should not be
# necessary to modify the makefile.
#-

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
#-
# MARLIN_DEV = YES
ifeq (${MARLIN_DEV},YES)
  MARLIN_REPO = git@github.com:StevenIsaacs/Marlin.git
  MARLIN_BRANCH = tronxy-x5sa-pro-mod
  MARLIN_DIR = marlin-dev
  MARLIN_CONFIG_REPO = git@github.com:StevenIsaacs/Configurations.git
  MARLIN_CONFIG_DIR = marlin-configs-dev
else
  MARLIN_REPO = https://github.com/MarlinFirmware/Marlin.git
  MARLIN_BRANCH = bugfix-2.0.x
  MARLIN_DIR = marlin
  MARLIN_CONFIG_REPO = https://github.com/MarlinFirmware/Configurations.git
  MARLIN_CONFIG_DIR = marlin-configs
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
  ED_OSCAD_DIR = ed-oscad-dev
  ED_OSCAD_BRANCH = dev
else
  ED_OSCAD_REPO = https://bitbucket.org/StevenIsaacs/ed-oscad.git
  ED_OSCAD_DIR = ed-oscad
  ED_OSCAD_BRANCH = release/0.0.1
endif
