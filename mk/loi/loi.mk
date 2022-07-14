#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Linux OS Image (LOI_) modding.
#----------------------------------------------------------------------------

#+
# Download, unpack, mount, modify, and unmount OS image files.
# Provides callable functions to mount and unmount so the images can be
# modified.
# Currently a maximum of two partitions are assumed to be the boot and
# root (not to be confused with /root). Symbolic links are created to
# point to the corresponding directories.
#-

_loi_Dir := $(call this_segment_dir)

# Configuration
LOI_BOARDS_DIR = ${_loi_Dir}/loi_boards
LOI_VARIANTS_DIR = ${_loi_Dir}/loi_variants
LOI_INIT_DIR = ${_loi_Dir}/loi_init
LOI_IMAGE_DIR = ${DOWNLOADS_DIR}/os-images
LOI_STAGING_DIR = ${MOD_STAGING_DIR}/os-images
LOI_IMAGE_MNT_DIR = ${LOI_STAGING_DIR}/mnt

include ${LOI_BOARDS_DIR}/${OS_BOARD}.mk
include ${LOI_VARIANTS_DIR}/${OS_VARIANT}.mk

$(call require,\
${OS_VARIANT}_LOI_RELEASE \
${OS_VARIANT}_LOI_VERSION \
${OS_VARIANT}_LOI_IMAGE \
${OS_VARIANT}_LOI_IMAGE_FILE \
${OS_VARIANT}_LOI_DOWNLOAD \
${OS_VARIANT}_LOI_UNPACK \
${OS_VARIANT}_LOI_P1_NAME \
${OS_VARIANT}_LOI_BOOT_DIR \
${OS_VARIANT}_LOI_ROOT_DIR \
)

ifeq (${${OS_VARIANT}_LOI_DOWNLOAD},wget)
  $(call require, ${OS_VARIANT}_LOI_IMAGE_URL)
else ifeq (${${OS_VARIANT}_LOI_DOWNLOAD},google)
  $(call require, ${OS_VARIANT}_LOI_IMAGE_ID)
else
  $(error Unsupported download method: ${${OS_VARIANT}_LOI_DOWNLOAD})
endif

$(info Image download method: ${${OS_VARIANT}_LOI_DOWNLOAD})
$(info Image unpack method: ${${OS_VARIANT}_LOI_UNPACK})

# Image download methods.
define download_wget
  wget -O $@ ${${OS_VARIANT}_LOI_IMAGE_URL}
endef

# Thanks to: https://medium.com/@acpanjan/download-google-drive-files-using-wget-3c2c025a8b99
define download_google
  @echo Downloading from Google.
  wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=${${OS_VARIANT}_LOI_IMAGE_ID}' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=${${OS_VARIANT}_LOI_IMAGE_ID}" -O $@ && rm -rf /tmp/cookies.txt
endef

${DOWNLOADS_DIR}/${${OS_VARIANT}_LOI_IMAGE_FILE}:
> @echo Downloading $@
> mkdir -p $(@D)
  ifneq (${${OS_VARIANT}_LOI_DOWNLOAD},)
    ifdef download_${${OS_VARIANT}_LOI_DOWNLOAD}
>     $(call download_${${OS_VARIANT}_LOI_DOWNLOAD})
    else
      $(error Unsupported download method: ${${OS_VARIANT}_LOI_DOWNLOAD})
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
  tar -xzf $< -C ${LOI_IMAGE_DIR}
> touch $@
endef

${LOI_IMAGE_DIR}/${${OS_VARIANT}_LOI_IMAGE}: ${DOWNLOADS_DIR}/${${OS_VARIANT}_LOI_IMAGE_FILE}
> mkdir -p $(@D)
> @echo Extracting $<
> @echo Compressed file type: $(suffix $<)
> @echo Image unpack method: ${${OS_VARIANT}_LOI_UNPACK}
  ifneq (${${OS_VARIANT}_LOI_UNPACK},)
    ifdef _loi_unpack_${${OS_VARIANT}_LOI_UNPACK}
>     $(call _loi_unpack_${${OS_VARIANT}_LOI_UNPACK})
    else
      $(error Unsupported unpack method: ${${OS_VARIANT}_LOI_UNPACK})
    endif
  else
    $(info Image unpack method not specified)
  endif

${LOI_IMAGE_DIR}/${${OS_VARIANT}_LOI_IMAGE}-p.json: ${LOI_IMAGE_DIR}/${${OS_VARIANT}_LOI_IMAGE}
> sfdisk -l --json $< > $@

${LOI_IMAGE_DIR}/${${OS_VARIANT}_LOI_IMAGE}.mk: \
    ${LOI_IMAGE_DIR}/${${OS_VARIANT}_LOI_IMAGE}-p.json
> python3 ${HELPER_DIR}/os-image-partitions.py $< > $@

# Get the partition information.
ifneq (${MAKECMDGOALS},help-loi)
  include ${LOI_IMAGE_DIR}/${${OS_VARIANT}_LOI_IMAGE}.mk
endif

os-image-file: ${DOWNLOADS_DIR}/${${OS_VARIANT}_LOI_IMAGE_FILE}

os-image: ${LOI_IMAGE_DIR}/${${OS_VARIANT}_LOI_IMAGE}

define loi_mount_image =
  @if [ ! "${${OS_VARIANT}_LOI_P1_NAME}" = "" ]; then \
    echo "Mounting: ${${OS_VARIANT}_LOI_P1_NAME}"; \
    mkdir -p ${LOI_IMAGE_MNT_DIR}/${${OS_VARIANT}_LOI_P1_NAME}; \
    sudo mount -v -o offset=${OS_IMAGE_P1_OFFSET},sizelimit=${OS_IMAGE_P1_SIZE} ${LOI_STAGING_DIR}/${${OS_VARIANT}_LOI_IMAGE} \
      ${LOI_IMAGE_MNT_DIR}/${${OS_VARIANT}_LOI_P1_NAME}; \
  fi
  @if [ ! "${${OS_VARIANT}_LOI_P2_NAME}" = "" ]; then \
    echo "Mounting: ${${OS_VARIANT}_LOI_P2_NAME}"; \
    mkdir -p ${LOI_IMAGE_MNT_DIR}/${${OS_VARIANT}_LOI_P2_NAME}; \
    sudo mount -v -o offset=${OS_IMAGE_P2_OFFSET},sizelimit=${OS_IMAGE_P2_SIZE} ${LOI_STAGING_DIR}/${${OS_VARIANT}_LOI_IMAGE} \
      ${LOI_IMAGE_MNT_DIR}/${${OS_VARIANT}_LOI_P2_NAME}; \
  fi
endef

define loi_unmount_image =
  @if mountpoint -q ${LOI_IMAGE_MNT_DIR}/${${OS_VARIANT}_LOI_P1_NAME}; then \
    echo "Unmounting: ${${OS_VARIANT}_LOI_P1_NAME}"; \
    sudo umount ${LOI_IMAGE_MNT_DIR}/${${OS_VARIANT}_LOI_P1_NAME}; \
    rmdir ${LOI_IMAGE_MNT_DIR}/${${OS_VARIANT}_LOI_P1_NAME}; \
  fi
  @if mountpoint -q ${LOI_IMAGE_MNT_DIR}/${${OS_VARIANT}_LOI_P2_NAME}; then \
    echo "Unmounting: ${${OS_VARIANT}_LOI_P2_NAME}"; \
    sudo umount ${LOI_IMAGE_MNT_DIR}/${${OS_VARIANT}_LOI_P2_NAME}; \
    rmdir ${LOI_IMAGE_MNT_DIR}/${${OS_VARIANT}_LOI_P2_NAME}; \
  fi
endef

${LOI_STAGING_DIR}/${${OS_VARIANT}_LOI_IMAGE}: \
  ${LOI_IMAGE_DIR}/${${OS_VARIANT}_LOI_IMAGE}
> mkdir -p $(@D)
> cp $< $@

OsDeps = ${LOI_STAGING_DIR}/${${OS_VARIANT}_LOI_IMAGE}

.PHONY: mount-os-image
mount-os-image: ${LOI_STAGING_DIR}/${${OS_VARIANT}_LOI_IMAGE}
> $(call loi_mount_image)

.PHONY: unmount-os-image
unmount-os-image:
> -$(call loi_unmount_image)

.PHONY: os-image-partitions
os-image-partitions:
> fdisk -l --bytes ${LOI_IMAGE_DIR}/${${OS_VARIANT}_LOI_IMAGE}
> -mount | grep ${LOI_IMAGE_MNT_DIR}

.PHONY: os-image-tree
os-image-tree: \
    ${LOI_STAGING_DIR}/${${OS_VARIANT}_LOI_IMAGE} FORCE
> $(call loi_mount_image)
> cd ${LOI_IMAGE_MNT_DIR}; \
    tree -fi ${${OS_VARIANT}_LOI_BOOT_DIR} ${${OS_VARIANT}_LOI_ROOT_DIR} > \
    ${LOI_STAGING_DIR}/${${OS_VARIANT}_LOI_IMAGE}-tree.txt
> sleep 5 # Allow file system to catch up.
> $(call loi_unmount_image)

.PHONY: list-os-boards
list-os-boards:
> @echo "Available boards:"
> @ls ${LOI_BOARDS_DIR}

ifeq (${MAKECMDGOALS},help-loi)
define HelpLoiMsg
Using the mount feature other segments can modify the contents of os image
as if it were part of the file system. Typically these modules install a
first time script which runs the first time the OS is booted. See other
segments for more information.

Defined in config.mk:
  DOWNLOADS_DIR=${DOWNLOADS_DIR}
    Where to put downladed packaged (e.g. compressed) image files.

Defined in kits.mk:
  MOD_STAGING_DIR = ${MOD_STAGING_DIR}
    Where the mod build output is stored.

Defined in mod.mk:
  OS_BOARD=${OS_BOARD}
    Which board to use (show-os-boards for more info).
  OS_VARIANT=${OS_VARIANT}
    Which OS variant to use for the selected OS board
    (show-os-variants for more info).

Defined in ${OS_BOARD}.mk:
  ${OS_VARIANT}_LOI_IMAGE = ${${OS_VARIANT}_LOI_IMAGE}
    The OS image (typically .img).
  ${OS_VARIANT}_LOI_IMAGE_FILE = ${${OS_VARIANT}_LOI_IMAGE_FILE}
    The OS image package file.
  ${OS_VARIANT}_LOI_IMAGE_URL = ${${OS_VARIANT}_LOI_IMAGE_URL}
    Where to download the OS image package file from.
  ${OS_VARIANT}_LOI_DOWNLOAD = ${${OS_VARIANT}_LOI_DOWNLOAD}
    The tool to use to download the OS image file.
  ${OS_VARIANT}_LOI_UNPACK = ${${OS_VARIANT}_LOI_UNPACK}
    The tool to use to unpack the OS image package.
  ${OS_VARIANT}_LOI_P1_NAME = ${${OS_VARIANT}_LOI_P1_NAME}
    The name of the mount point for the first partition.
  ${OS_VARIANT}_LOI_P2_NAME = ${${OS_VARIANT}_LOI_P2_NAME}
    The mount point for the second partition if it exists.
    Leave undefined if there is no second partiton.
  ${OS_VARIANT}_LOI_BOOT_DIR = ${${OS_VARIANT}_LOI_BOOT_DIR}
    Path to the boot directory.
  ${OS_VARIANT}_LOI_ROOT_DIR = ${${OS_VARIANT}_LOI_ROOT_DIR}
    Path to the root directory.

Defines:
  LOI_BOARDS_DIR = ${LOI_BOARDS_DIR}
    Where the board definitions are maintained. Among other things these
    describe the different OS variations that are available for a board.
  LOI_VARIANTS_DIR = ${LOI_VARIANTS_DIR}
    Where the OS variant descriptions are maintained. These describe
    distro specifics for each OS variant.
  LOI_INIT_DIR = ${LOI_INIT_DIR}
    Where variant specific init scripts are maintained.
  LOI_IMAGE_DIR = ${LOI_IMAGE_DIR}
    Where OS images are stored. These are copied to the build directory for
    modification.
  LOI_STAGING_DIR = ${LOI_STAGING_DIR}
    Where the modified OS images are stored. Typically this is a subdirectory
    in the mod build directory.
  LOI_IMAGE_MNT_DIR = ${LOI_IMAGE_MNT_DIR}
    Where the OS image partitions are mounted for modification.
  LOI_INIT_DIR = ${LOI_INIT_DIR}
    Where the OS init scripts (firsttime) are maintained.
  OsDeps = ${OsDeps}
    A list of dependencies needed to mount an OS image.
  loi_mount_image       A callable macro to mount the OS image partitions.
                        Other make segments can call this macro to mount
                        partitions before installing or modifying files in
                        the partitions.
  loi_unmount_image     A callable macro to unmount the OS image partitions.
                        Other make segments can call this macro to unmount
                        partitions.

Command line targets:
  help-loi              Display this help.
  list-os-boards        Display a list of available boards on which an OS
                        can be installed.
  list-os-variants      Display a list of available OS variants. NOTE: The OS
                        board determines which variants can be used.
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

Uses:

endef

export HelpLoiMsg
help-loi:
> @echo "$$HelpLoiMsg" | less
endif
