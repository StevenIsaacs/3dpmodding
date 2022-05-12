#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 3D Printed Parts
#----------------------------------------------------------------------------
define EdOscadHelp
Make segment: ed-oscad.mk

This segment is used to install ed-oscad from and then use it to generate
STL files for 3D printable parts. OpenSCAD and SolidPython are supported.
Ed-oscad is maintained in a git repository and a clone of that repository
is used.

Defined in mod.mk:
  USE_ED_OSCAD    Must equal YES in order to use this make segment.

Defined in options.mk:
  ED_OSCAD_DEV    Set equal to YES to use the development branch. Otherwise
                  will use the configured release branch.
  ED_OSCAD_REPO   The repo to clone to install ed-oscad.
  ED_OSCAD_DIR    Where to clone to.
  ED_OSCAD_BRANCH Which branch to use.

Defines:
  MODEL_TARGET    The target to pass to the ed-oscad makefile. This defaults
                  to "all" and can be overridden in mod.mk or on the
                  command line (e.g. MODEL_TARGET=docs).

Command line targets:
  help-ed-oscad   Display this help.
  ed-oscad        Clone ed-oscad into the clone directory and checkout the
                  configured branch.
  ed-oscad-help   Display the ed-oscad-help.
  parts           Build the parts for the mod. This produces STL files which
                  can be loaded into a slicer to generate corresponding
				  gcode for a specific 3D printer.

Uses:
  The ed-oscad makefile.
endef

export EdOscadHelp
help-ed-oscad:
	@echo "$$EdOscadHelp"

ifeq (${MODEL_TARGET},)
  MODEL_TARGET = all
endif

EdOscadInstallFile = ${ED_OSCAD_DIR}/README.md

${EdOscadInstallFile}:
	git clone ${ED_OSCAD_REPO} ${ED_OSCAD_DIR}
	cd ${ED_OSCAD_DIR}; git checkout ${ED_OSCAD_BRANCH}

.PHONY: ed-oscad
ed-oscad: ${EdOscadInstallFile}

.PHONY: ed-oscad-help
ed-oscad-help: ${EdOscadInstallFile}
	cd ${ED_OSCAD_DIR}; ${MAKE} MODEL_DIR=${MOD_DIR}/model help

# 3D printable parts.
.PHONY: parts
parts: ${EdOscadInstallFile}
	cd ${ED_OSCAD_DIR}; \
	${MAKE} MODEL_DIR=${MOD_DIR}/model ${MODEL_OPTIONS} ${MODEL_TARGET}
