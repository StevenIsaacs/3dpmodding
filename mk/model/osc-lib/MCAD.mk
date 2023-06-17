# MCAD - components commonly used in designing and mocking up mechanical
# designs.
$(info MCAD library)

MCAD_VERSION = openscad-2019.05
MCAD_GIT_URL = https://github.com/openscad/MCAD.git

MCAD_PATH = ${LIB_PATH}/MCAD
MCAD_DEP = ${MCAD_PATH}/README.markdown

${MCAD_DEP}:
> git clone ${MCAD_GIT_URL} ${MCAD_PATH}
> cd $(MCAD_PATH) && \
> git switch --detach ${MCAD_VERSION}

mcad: ${MCAD_DEP}
