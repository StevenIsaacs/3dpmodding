#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# 3D Printed Parts
#----------------------------------------------------------------------------
# Defined in options.mk:
#   ED_OSCAD_DEV
#   ED_OSCAD_DIR
#   ED_OSCAD_BRANCH
#   MODEL_OPTIONS
#
# Expected to be defined in mod.mk:
#   USE_ED_OSCAD
# Other possible overrides:
#   MOD_DIR
#   MODEL_TARGET
#

EdOscadInstallFile = ${ED_OSCAD_DIR}/README.md

${EdOscadInstallFile}:
	git clone ${ED_OSCAD_REPO} ${ED_OSCAD_DIR}
	cd ${ED_OSCAD_DIR}; git checkout ${ED_OSCAD_BRANCH}

.PHONY: ed-oscad
ed-oscad: ${EdOscadInstallFile}

.PHONY: ed-oscad-help
ed-oscad-help: ${EdOscadInstallFile}
	cd ${ED_OSCAD_DIR}; make help

# 3D printable parts.
.PHONY: parts
parts: ${EdOscadInstallFile}
	cd ${ED_OSCAD_DIR}; \
	${MAKE} MODEL_DIR=${MOD_DIR}/model ${MODEL_OPTIONS} ${MODEL_TARGET}
