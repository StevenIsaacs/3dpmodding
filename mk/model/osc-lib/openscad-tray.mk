# openscad-tray - Designed to quickly create trays with different
# configurations, for efficient storing of parts, such as hardware, small
# tools, board game inserts, etc.
$(info OPENSCAD_TRAY library)

OPENSCAD_TRAY_VERSION = master
OPENSCAD_TRAY_GIT_URL = https://github.com/sofian/openscad-tray.git

OPENSCAD_TRAY_PATH = ${LIB_PATH}/openscad-tray
OPENSCAD_TRAY_DEP = ${OPENSCAD_TRAY_PATH}/readme.md

${OPENSCAD_TRAY_DEP}:
> git clone ${OPENSCAD_TRAY_GIT_URL} ${OPENSCAD_TRAY_PATH}
> cd $(OPENSCAD_TRAY_PATH) && \
> git switch --detach ${OPENSCAD_TRAY_VERSION}

OPENSCAD_TRAY: ${OPENSCAD_TRAY_DEP}
