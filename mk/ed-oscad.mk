# REMOVE - Superceded by openscad.mk
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Custom 3D printed parts.
#
# NOTE: ed-oscad supports multiple models. It may be more convenient to
# install ed-oscad in a different location than within this directory. If
# so then simply reference that other location using ED_OSCAD_DIR.
#
# The default assumes ed-oscad is installed with the intent of working with
# multiple models.
#----------------------------------------------------------------------------

# Config section.
ifndef CAD_TOOL_VARIANT
  CAD_TOOL_VARIANT = release/0.0.1
endif
ifeq (${CAD_TOOL_VARIANT},dev)
  ED_OSCAD_REPO = git@bitbucket.org:StevenIsaacs/ed-oscad.git
  ED_OSCAD_DIR = ${TOOLS_DIR}/ed-oscad-dev
  ED_OSCAD_BRANCH = dev
else
  # Default.
  ED_OSCAD_REPO = https://bitbucket.org/StevenIsaacs/ed-oscad.git
  ED_OSCAD_DIR = ${TOOLS_DIR}/ed-oscad
  ED_OSCAD_BRANCH = ${CAD_TOOL_VARIANT}
endif

ifndef MODEL_TARGET
  MODEL_TARGET = all
endif

EdOscadInstallFile = ${ED_OSCAD_DIR}/README.md

${EdOscadInstallFile}:
	git clone ${ED_OSCAD_REPO} ${ED_OSCAD_DIR}
	cd ${ED_OSCAD_DIR}; git checkout ${ED_OSCAD_BRANCH}

.PHONY: ed-oscad
ed-oscad: ${EdOscadInstallFile}

.PHONY: ed-oscad-usage
ed-oscad-usage: ${EdOscadInstallFile}
	cd ${ED_OSCAD_DIR}; ${MAKE} MODEL_DIR=${ModDir}/model help

.PHONY: help-model
help-model: ${EdOscadInstallFile}
	cd ${ED_OSCAD_DIR}; ${MAKE} MODEL_DIR=${ModDir}/model help-model

# 3D printable parts.
.PHONY: parts
parts: ${EdOscadInstallFile}
	${MAKE} -D ${ED_OSCAD_DIR} \
    MODEL_DIR=${ModDir}/model ${MODEL_OPTIONS} ${MODEL_TARGET}

ifeq (${MAKECMDGOALS},help-ed-oscad)
define HelpEdOscadMsg
Make segment: ed-oscad.mk

This segment is used to clone ed-oscad and then use it to generate
STL files for 3D printable parts. OpenSCAD and SolidPython are supported.
Ed-oscad is maintained in a git repository and a clone of that repository
is used.

Defined in mod.mk:
  CAD_TOOL_VARIANT = ${CAD_TOOL_VARIANT}
    Use a variant. If not defined then use the release branch.
      Variants:
        <tag>     Use a specific git tag.
        <branch>  Use a specific branch.
        dev       Use the development branch. This requires Bitbucket
                  Bitbucket credentials.

Defined in config.mk:

Defines:
  ED_OSCAD_REPO = ${ED_OSCAD_REPO}
    The repo to clone to install ed-oscad.
  ED_OSCAD_DIR = ${ED_OSCAD_DIR}
    Where to clone to.
  ED_OSCAD_BRANCH = ${ED_OSCAD_BRANCH}
    Which branch to use.
  MODEL_TARGET = ${MODEL_TARGET}
    The target to pass to the ed-oscad makefile. This defaults to "all" and
    can be overridden in mod.mk or on the command line
    (e.g. MODEL_TARGET=docs).

Command line targets:
  help-ed-oscad     Display this help.
  ed-oscad          Clone ed-oscad into the clone directory and checkout the
                    configured branch.
  ed-oscad-usage    Display the ed-oscad usage message.
  help-model        Display the model specific help.
  parts             Build the parts for the mod. This produces STL files which
                    can be loaded into a slicer to generate corresponding
                    gcode for a specific 3D printer.

Uses:

endef

export HelpEdOscadMsg
help-ed-oscad:
	@echo "$$HelpEdOscadMsg"
endif
