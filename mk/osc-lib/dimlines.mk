# dimlines - Create dimensioned lines, title blocks and more which are used
# to document parts.
$(info dimlines library)

dimlines_VERSION = master
dimlines_GIT_URL = https://github.com/sidorof/dimlines.git

dimlines_PATH = ${LIB_PATH}/dimlines
dimlines_DEP = ${dimlines_PATH}/README.md

${dimlines_DEP}:
> git clone ${dimlines_GIT_URL} ${dimlines_PATH}
> cd $(dimlines_PATH) && \
> git switch ${dimlines_VERSION} && \
> git switch --detach

dimlines: ${dimlines_DEP}
