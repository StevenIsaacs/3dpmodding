#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Linux OS Image (LOI_) modding.
#----------------------------------------------------------------------------
# The prefix loi must be unique for all files.
# +++++
# Preamble
ifndef loiSegId
$(call Enter-Segment,loi)
# -----

#+
# Download, unpack, mount, modify, and unmount OS image files.
# Provides callable functions to mount and unmount so the images can be
# modified.
# Currently a maximum of two partitions are assumed to be the boot and
# root (not to be confused with /root). Symbolic links are created to
# point to the corresponding directories.
#-

_loi_Path := $(call This-Segment-Path)

# Configuration
LOI_BOARDS_PATH = ${_loi_Path}/loi_boards
LOI_VARIANTS_PATH = ${_loi_Path}/loi_variants
LOI_ACCESS_METHODS_PATH = ${_loi_Path}/gw_access_methods

LOI_INIT_PATH = ${_loi_Path}/loi_init
LOI_IMAGE_PATH = ${DOWNLOADS_PATH}/os-images
LOI_BUILD_PATH = ${MOD_BUILD_PATH}/os-images
LOI_STAGING_PATH = ${MOD_STAGING_PATH}/os-images
LOI_IMAGE_MNT_PATH = ${LOI_STAGING_PATH}/mnt

$(call Require,config.mk, HELPER_FUNCTIONS)

$(call Require,\
${MOD}.mk, \
GW_OS_VARIANT \
GW_OS_BOARD \
GW_ADMIN \
GW_ADMIN_ID \
GW_ADMIN_GID \
GW_USER \
GW_USER_ID \
GW_USER_GID \
MCU_ACCESS_METHOD \
)

# Ensure using one of the supported access modes.
_AccessMethods = $(call Basenames-In,${LOI_ACCESS_METHODS_PATH}/*.mk)
$(call Must-Be-One-Of,MCU_ACCESS_METHOD,${_AccessMethods})

$(call Require,${GW_APP}.mk,GW_INIT_SCRIPT)

# These are a collection of scripts designed to run on the GW during
# first time initialization. Each make segment can add to this list
# to define dependencies for staging.
LoiInitScripts = ${HELPER_FUNCTIONS}

$(call Use-Segment,loi_boards/${GW_OS_BOARD})
$(call Use-Segment,loi_variants/${GW_OS_VARIANT})
$(call Use-Segment,gw_access_methods/${MCU_ACCESS_METHOD})

$(call Require,\
${GW_OS_VARIANT}.mk, \
${GW_OS_VARIANT}_TMP_PATH \
)

# To shorten references a bit.
_OsTmpPath = ${${GW_OS_VARIANT}_TMP_PATH}
_OsImageTmpPath = ${LOI_IMAGE_MNT_PATH}/${${GW_OS_VARIANT}_LOI_ROOT_PATH}/${_OsTmpPath}

$(call Require,\
${GW_OS_BOARD}.mk,\
GW_OS_ARCH \
${GW_OS_VARIANT}_LOI_RELEASE \
${GW_OS_VARIANT}_LOI_VARIANT \
${GW_OS_VARIANT}_LOI_IMAGE \
${GW_OS_VARIANT}_LOI_IMAGE_FILE \
${GW_OS_VARIANT}_LOI_DOWNLOAD \
${GW_OS_VARIANT}_LOI_UNPACK \
${GW_OS_VARIANT}_LOI_P1_NAME \
${GW_OS_VARIANT}_LOI_BOOT_PATH \
${GW_OS_VARIANT}_LOI_ROOT_PATH \
)

$(call Require,\
${GW_OS_VARIANT}.mk,\
${GW_OS_VARIANT}_TMP_PATH \
${GW_OS_VARIANT}_ETC_PATH \
${GW_OS_VARIANT}_HOME_PATH \
${GW_OS_VARIANT}_USER_HOME_PATH \
${GW_OS_VARIANT}_USER_TMP_PATH \
${GW_OS_VARIANT}_ADMIN_HOME_PATH \
${GW_OS_VARIANT}_ADMIN_TMP_PATH \
)

ifeq (${${GW_OS_VARIANT}_LOI_DOWNLOAD},wget)
  $(call Require, ${GW_OS_BOARD}.mk,${GW_OS_VARIANT}_LOI_IMAGE_URL)
else ifeq (${${GW_OS_VARIANT}_LOI_DOWNLOAD},google)
  $(call Require, ${GW_OS_BOARD}.mk,${GW_OS_VARIANT}_LOI_IMAGE_ID)
else
  $(call Signal-Error,Unsupported download method: ${${GW_OS_VARIANT}_LOI_DOWNLOAD})
endif

$(info Image download method: ${${GW_OS_VARIANT}_LOI_DOWNLOAD})
$(info Image unpack method: ${${GW_OS_VARIANT}_LOI_UNPACK})

# Image download methods.
define download_wget
  wget -O $@ ${${GW_OS_VARIANT}_LOI_IMAGE_URL}
endef

# Thanks to: https://medium.com/@acpanjan/download-google-drive-files-using-wget-3c2c025a8b99
define download_google
  @echo Downloading from Google.
  wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=${${GW_OS_VARIANT}_LOI_IMAGE_ID}' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=${${GW_OS_VARIANT}_LOI_IMAGE_ID}" -O $@ && rm -rf /tmp/cookies.txt
endef

${DOWNLOADS_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE_FILE}:
> @echo Downloading $@
> mkdir -p $(@D)
  ifneq (${${GW_OS_VARIANT}_LOI_DOWNLOAD},)
    ifdef download_${${GW_OS_VARIANT}_LOI_DOWNLOAD}
>     $(call download_${${GW_OS_VARIANT}_LOI_DOWNLOAD})
    else
      $(call Signal-Error,Unsupported download method: ${${GW_OS_VARIANT}_LOI_DOWNLOAD})
    endif
  else
    $(info Image download method not specified)
  endif

# Image unpack methods.
define _loi_unpack_zip
  unzip $< -d $(@D)
> touch $@
endef

define _loi_unpack_xz
  unxz -c $< > $@
> touch $@
endef

define _loi_unpack_tarz
  tar -xzf $< -C ${LOI_IMAGE_PATH}
> touch $@
endef

${LOI_IMAGE_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}: \
  ${DOWNLOADS_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE_FILE}
> mkdir -p $(@D)
> @echo Extracting $<
> @echo Compressed file type: $(suffix $<)
> @echo Image unpack method: ${${GW_OS_VARIANT}_LOI_UNPACK}
  ifneq (${${GW_OS_VARIANT}_LOI_UNPACK},)
    ifdef _loi_unpack_${${GW_OS_VARIANT}_LOI_UNPACK}
>     $(call _loi_unpack_${${GW_OS_VARIANT}_LOI_UNPACK})
    else
      $(call Signal-Error,\
        Unsupported unpack method: ${${GW_OS_VARIANT}_LOI_UNPACK})
    endif
  else
    $(info Image unpack method not specified)
  endif

${LOI_IMAGE_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}-p.json: ${LOI_IMAGE_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}
> sfdisk -l --json $< > $@

${LOI_IMAGE_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}.mk: \
    ${LOI_IMAGE_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}-p.json
> python3 ${HELPERS_PATH}/os-image-partitions.py $< > $@

# Get the partition information.
ifneq (${MAKECMDGOALS},help-loi)
  include ${LOI_IMAGE_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}.mk
endif

os-image-file: ${DOWNLOADS_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE_FILE}

os-image: ${LOI_IMAGE_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}

define loi_mount_image =
  @if [ ! "${${GW_OS_VARIANT}_LOI_P1_NAME}" = "" ]; then \
    echo "Mounting: ${${GW_OS_VARIANT}_LOI_P1_NAME}"; \
    mkdir -p ${LOI_IMAGE_MNT_PATH}/${${GW_OS_VARIANT}_LOI_P1_NAME}; \
    sudo mount -v -o offset=${GW_OS_IMAGE_P1_OFFSET},sizelimit=${GW_OS_IMAGE_P1_SIZE} ${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE} \
      ${LOI_IMAGE_MNT_PATH}/${${GW_OS_VARIANT}_LOI_P1_NAME}; \
  fi
  @if [ ! "${${GW_OS_VARIANT}_LOI_P2_NAME}" = "" ]; then \
    echo "Mounting: ${${GW_OS_VARIANT}_LOI_P2_NAME}"; \
    mkdir -p ${LOI_IMAGE_MNT_PATH}/${${GW_OS_VARIANT}_LOI_P2_NAME}; \
    sudo mount -v -o offset=${GW_OS_IMAGE_P2_OFFSET},sizelimit=${GW_OS_IMAGE_P2_SIZE} ${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE} \
      ${LOI_IMAGE_MNT_PATH}/${${GW_OS_VARIANT}_LOI_P2_NAME}; \
  fi
endef

define loi_unmount_image =
  @if mountpoint -q ${LOI_IMAGE_MNT_PATH}/${${GW_OS_VARIANT}_LOI_P1_NAME}; then \
    echo "Unmounting: ${${GW_OS_VARIANT}_LOI_P1_NAME}"; \
    sudo umount ${LOI_IMAGE_MNT_PATH}/${${GW_OS_VARIANT}_LOI_P1_NAME}; \
    rmdir ${LOI_IMAGE_MNT_PATH}/${${GW_OS_VARIANT}_LOI_P1_NAME}; \
  fi
  @if mountpoint -q ${LOI_IMAGE_MNT_PATH}/${${GW_OS_VARIANT}_LOI_P2_NAME}; then \
    echo "Unmounting: ${${GW_OS_VARIANT}_LOI_P2_NAME}"; \
    sudo umount ${LOI_IMAGE_MNT_PATH}/${${GW_OS_VARIANT}_LOI_P2_NAME}; \
    rmdir ${LOI_IMAGE_MNT_PATH}/${${GW_OS_VARIANT}_LOI_P2_NAME}; \
  fi
endef

${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}: \
  ${LOI_IMAGE_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}
> mkdir -p $(@D)
> cp $< $@

OsDeps = ${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}

.PHONY: mount-os-image
mount-os-image: ${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}
> $(call loi_mount_image)

.PHONY: unmount-os-image
unmount-os-image:
> -$(call loi_unmount_image)

.PHONY: os-image-partitions
os-image-partitions:
> fdisk -l --bytes ${LOI_IMAGE_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}
> -mount | grep ${LOI_IMAGE_MNT_PATH}

.PHONY: os-image-tree
os-image-tree: \
    ${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE} FORCE
> $(call loi_mount_image)
> cd ${LOI_IMAGE_MNT_PATH}; \
    tree -fi ${${GW_OS_VARIANT}_LOI_BOOT_PATH} ${${GW_OS_VARIANT}_LOI_ROOT_PATH} > \
    ${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}-tree.txt
> sleep 5 # Allow file system to catch up.
> $(call loi_unmount_image)

.PHONY: list-os-boards
list-os-boards:
> @echo "Available boards:"
> @ls ${LOI_BOARDS_PATH}

# The emulator QEMU is used to run an init script in an OS image environment
# without having to bood the OS on the target board.
/usr/bin/qemu-${GW_OS_ARCH}:
> sudo apt update
> sudo apt install qemu-user

/usr/bin/proot: | /usr/bin/qemu-${GW_OS_ARCH}
> sudo apt install proot

ifeq (${MAKECMDGOALS},stage-os-image)
# Start the emulation to aid running the staging scripts.
PROOT = sudo proot -q qemu-${GW_OS_ARCH} -0 -w /root \
  -r ${LOI_IMAGE_MNT_PATH}/${${GW_OS_VARIANT}_LOI_ROOT_PATH}

define LoiInitConfig
GW_OS_ADMIN=${GW_ADMIN}
GW_OS_ADMIN_ID=${GW_ADMIN_ID}
GW_OS_ADMIN_GID=${GW_ADMIN_GID}
GW_OS_USER=${GW_USER}
GW_OS_USER_ID=${GW_USER_ID}
GW_OS_USER_GID=${GW_USER_GID}
GW_INIT=${GW_INIT_SCRIPT}
endef

export LoiInitConfig
# It is possible the OS image is already mounted.
.PHONY: stage-os-image
stage-os-image: /usr/bin/proot \
    ${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE} \
    ${LoiInitScripts}
> $(call loi_mount_image)
> printf "%s" "$$LoiInitConfig" > ${_OsImageTmpPath}/options.conf
> cp ${LoiInitScripts} ${_OsImageTmpPath}
> $(call stage_${GW_OS_VARIANT},${_OsImageTmpPath})
> $(call stage_${GW_APP},${_OsImageTmpPath})
> -${PROOT} ${_OsTmpPath}/stage-${GW_OS_VARIANT}
> date >${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}.staged
> cp ${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}.staged ${_OsImageTmpPath}
> $(call loi_unmount_image)

# Use BOOT_DEV to specify the device on the make command line.
ifdef BOOT_DEV
  _Device = --device ${BOOT_DEV}
endif

endif # stage-os-image

${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}.staged:
> @echo "Cannot install the OS image. Use stage-os-image first."; exit 1

ifneq (${Platform},Microsoft)
.PHONY: install-os-image
install-os-image: \
  ${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}.staged
> cd ${LOI_STAGING_PATH} && \
  ${HELPERS_PATH}/makebootable \
    --os-image ${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE} \
    ${_Device}
else
install-os-image:
> $(call Signal-Error,USB storage device support is not available in WSL2)
endif

.PHONY: help-makebootable
help-makebootable:
> cd ${LOI_STAGING_PATH} && \
  ${HELPERS_PATH}/makebootable --help

.PHONY: os-image-shell
os-image-shell: \
    /usr/bin/proot \
    ${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}
> $(call loi_mount_image)
> -${PROOT} /bin/bash
> $(call loi_unmount_image)

.PHONY: clean-os-image
clean-os-image:
> rm ${LOI_STAGING_PATH}/${${GW_OS_VARIANT}_LOI_IMAGE}

# +++++
# Postamble
ifneq ($(call Is-Goal,help-${loiSeg}),)
define help_${loiSegN}_msg
Make segment: ${loiSeg}.mk

Using the mount feature other segments can modify the contents of os image
as if it were part of the file system. Typically these modules install a
first time script which runs the first time the OS is booted. The actual
method and contents of these scripts is OS dependent. See the OS segments
for more information (e.g. help-${GW_OS_VARIANT}).

WARNING: Because of the use of sudo and proot this creates a security risk.
Every effort has been made to avoid corruption of the host OS but use with
caution. Because of this the targets in this make segment must be invoked
explicitly on the make command line and are not invoked from any other make
segment.

Defined in config.mk:
  DOWNLOADS_PATH=${DOWNLOADS_PATH}
    Where to put downladed packaged (e.g. compressed) image files.

Defined in kits.mk:
  MOD_STAGING_PATH = ${MOD_STAGING_PATH}
    Where the mod build output is stored.

Defined in ${MOD}.mk:
  GW_OS_BOARD=${GW_OS_BOARD}
    Which board to use (show-os-boards for more info).
  GW_OS_VARIANT=${GW_OS_VARIANT}
    Which OS variant to use for the selected OS board
    (show-os-variants for more info).

Defined in ${GW_OS_BOARD}.mk:
  ${GW_OS_VARIANT}_LOI_IMAGE = ${${GW_OS_VARIANT}_LOI_IMAGE}
    The OS image (typically .img).
  ${GW_OS_VARIANT}_LOI_IMAGE_FILE = ${${GW_OS_VARIANT}_LOI_IMAGE_FILE}
    The OS image package file.
  ${GW_OS_VARIANT}_LOI_IMAGE_URL = ${${GW_OS_VARIANT}_LOI_IMAGE_URL}
    Where to download the OS image package file from.
  ${GW_OS_VARIANT}_LOI_DOWNLOAD = ${${GW_OS_VARIANT}_LOI_DOWNLOAD}
    The tool to use to download the OS image file.
  ${GW_OS_VARIANT}_LOI_UNPACK = ${${GW_OS_VARIANT}_LOI_UNPACK}
    The tool to use to unpack the OS image package.
  ${GW_OS_VARIANT}_LOI_P1_NAME = ${${GW_OS_VARIANT}_LOI_P1_NAME}
    The name of the mount point for the first partition.
  ${GW_OS_VARIANT}_LOI_P2_NAME = ${${GW_OS_VARIANT}_LOI_P2_NAME}
    The mount point for the second partition if it exists.
    Leave undefined if there is no second partiton.
  ${GW_OS_VARIANT}_LOI_BOOT_PATH = ${${GW_OS_VARIANT}_LOI_BOOT_PATH}
    Path to the boot directory.
  ${GW_OS_VARIANT}_LOI_ROOT_PATH = ${${GW_OS_VARIANT}_LOI_ROOT_PATH}
    Path to the root directory.

Defines:
  LOI_BOARDS_PATH = ${LOI_BOARDS_PATH}
    Where the board definitions are maintained. Among other things these
    describe the different OS variations that are available for a board.
  LOI_VARIANTS_PATH = ${LOI_VARIANTS_PATH}
    Where the OS variant descriptions are maintained. These describe
    distro specifics for each OS variant.
  LOI_INIT_PATH = ${LOI_INIT_PATH}
    Where variant specific init scripts are maintained. These are designed to
    be run in a QEMU emulation environment. There are two flavors. The first
    is for OS specific initialization and the second for user interface specific
    initialization.
  LOI_IMAGE_PATH = ${LOI_IMAGE_PATH}
    Where OS images are stored. These are copied to the build directory for
    modification.
  LOI_BUILD_PATH = ${LOI_BUILD_PATH}
    Where generated OS related files are stored. These are then copied to the
    OS image when staged.
  LOI_STAGING_PATH = ${LOI_STAGING_PATH}
    Where the modified OS images are stored. Typically this is a subdirectory
    in the mod build directory.
  LOI_IMAGE_MNT_PATH = ${LOI_IMAGE_MNT_PATH}
    Where the OS image partitions are mounted for modification.
  OsDeps = ${OsDeps}
    A list of dependencies needed to mount an OS image.
  loi_mount_image       A callable macro to mount the OS image partitions.
                        Other make segments can call this macro to mount
                        partitions before installing or modifying files in
                        the partitions.
  loi_unmount_image     A callable macro to unmount the OS image partitions.
                        Other make segments can call this macro to unmount
                        partitions.

Command line goals:
  help-loi              Display this help.
  list-os-boards        Display a list of available boards on which an OS
                        can be installed.
  os-image-file         Download the OS image package file.
  os-image              Unpack the OS image package file.
  mount-os-image        Mount the OS image partitions (uses sudo).
  unmount-os-image      Unmount the OS image partitions (uses sudo).
  os-image-partitions   Display the partitions in an OS image and where they
                        are moounted. This can be used to determine offsets
                        and sizes. NOTE: The displayed size is in bytes but
                        the offsets are the number of 512 byte sectors.
  os-image-tree         Generates a text file containing a full list of Files
                        in the OS image. This can be used for locating files
                        in the image without having to mount it.
  stage-os-image        Use QEMU and proot to prepare an OS image for firstrun
                        initialization. Staging scripts are run using
                        the target OS in an emulation environment.
  install-os-image      Install the OS image file onto a USB flash card to
                        make the card bootable on the target device. This
                        uses the helper script makebootable. The makebootable
                        options are saved in ~/.modfw/makebootable. The
                        boot device defaults to a device scan or the previous
                        device. Use BOOT_DEV on the command line to specify
                        which device to install the OS image to.
  help-makebootable     Display the help and current options for the
                        makebootable helper script.
  os-image-shell        Use QEMU and proot to start a shell session using the
                        OS image in an emulation environment.
  clean-os-image        Remove the OS image file from the staging directory.

Command line variables:
  BOOT_DEV=<device>     (optional) This is used by install-os-image to select
                        which device to install the OS onto. This must be a
                        removable USB storage device and defaults to the
                        first removable USB storage found in a downward scan
                        from sdj to sdc.

Uses:
  stage_${GW_OS_VARIANT} defined in ${GW_OS_VARIANT}.mk

Command line goals:
  help-${loiSeg}   Display this help.
endef
endif # help goal message.

$(call Exit-Segment,loi)
else # loiSegId exists
$(call Check-Segment-Conflicts,loi)
endif # loiSegId
# -----
