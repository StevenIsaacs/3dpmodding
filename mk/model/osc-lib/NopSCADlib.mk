# NopSCADlib - An ever expanding library of parts useful for 3D printers
# and enclosures for electronics.
$(info NOPSCADLIB library)

NOPSCADLIB_VERSION = v18.3.1
NOPSCADLIB_GIT_URL = https://github.com/nophead/NOPSCADLIB.git

NOPSCADLIB_PATH = ${LIB_PATH}/NopSCADlib
NOPSCADLIB_DEP = ${NOPSCADLIB_PATH}/readme.md

${NOPSCADLIB_DEP}:
> git clone ${NOPSCADLIB_GIT_URL} ${NOPSCADLIB_PATH}
> cd $(NOPSCADLIB_PATH) && \
> git switch --detach ${NOPSCADLIB_VERSION}

nopscadlib: ${NOPSCADLIB_DEP}
