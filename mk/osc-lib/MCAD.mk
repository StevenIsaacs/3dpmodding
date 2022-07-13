# MCAD - components commonly used in designing and mocking up mechanical
# designs.
$(info MCAD library)

MCAD_VERSION = openscad-2019.05
MCAD_GIT_URL = https://github.com/openscad/MCAD.git

MCAD_DIR = ${LIB_DIR}/MCAD
MCAD_DEP = ${MCAD_DIR}/README.markdown

${MCAD_DEP}:
> git clone ${MCAD_GIT_URL} ${MCAD_DIR}
> cd $(MCAD_DIR) && \
> git switch --detach ${MCAD_VERSION}

mcad: ${MCAD_DEP}
