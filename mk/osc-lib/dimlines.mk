# dimlines - Create dimensioned lines, title blocks and more which are used
# to document parts.
$(info dimlines library)

dimlines_VERSION = master
dimlines_GIT_URL = https://github.com/sidorof/dimlines.git

dimlines_DIR = ${LIB_DIR}/dimlines
dimlines_DEP = ${dimlines_DIR}/README.md

${dimlines_DEP}:
	git clone ${dimlines_GIT_URL} ${dimlines_DIR}
	cd $(dimlines_DIR) && \
	git switch ${dimlines_VERSION} && \
	git switch --detach

dimlines: ${dimlines_DEP}
