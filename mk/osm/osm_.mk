#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# OS Modding - OSM_
#----------------------------------------------------------------------------

#+
# NOTE: This is NOT a stand alone make file. Instead it is designed to be
# included by a higher level make file.
#
# Download, unpack, mount, modify, and unmount OS image files.
# Provides callable functions to mount and unmount so the images can be
# modified.
# Currently a maximum of two partitions are assumed to be the boot and
# root (not to be confused with /root). Symbolic links are created to
# point to the corresponding directories.
#-

# Configuration
OS_BOARDS_DIR = ${OS_MODDING_DIR}/os_boards
OS_VARIANTS_DIR = ${OS_MODDING_DIR}/os_variants
OS_INIT_DIR = ${OS_MODDING_DIR}/os_init

# The output image file.
OSM_IMAGE = ${${OS_VARIANT}_OSM_IMAGE}

# Derived
_Osm_Image = ${${OS_VARIANT}_OSM_IMAGE}
_Osm_File = ${${OS_VARIANT}_OSM_IMAGE_FILE}
_Osm_Url = ${${OS_VARIANT}_OSM_IMAGE_URL}
_Osm_Id = ${${OS_VARIANT}_OSM_IMAGE_ID}
_Osm_Download = ${${OS_VARIANT}_OSM_DOWNLOAD}
_Osm_Unpack = ${${OS_VARIANT}_OSM_UNPACK}
_Osm_P1Name = ${${OS_VARIANT}_OSM_P1_NAME}
_Osm_P1Offset = ${${OS_VARIANT}_OSM_P1_OFFSET}
_Osm_P1Size = ${${OS_VARIANT}_OSM_P1_SIZE}
_Osm_P2Name = ${${OS_VARIANT}_OSM_P2_NAME}
_Osm_P2Offset = ${${OS_VARIANT}_OSM_P2_OFFSET}
_Osm_P2Size = ${${OS_VARIANT}_OSM_P2_SIZE}
_Osm_BootDir = ${${OS_VARIANT}_OSM_BOOT_DIR}
_Osm_RootDir = ${${OS_VARIANT}_OSM_ROOT_DIR}

$(info Image download method: ${_Osm_Download})
$(info Image unpack method: ${_Osm_Unpack})

# Image download methods.
define download_wget
	wget -O $@ ${_Osm_Url}
endef

# Thanks to: https://medium.com/@acpanjan/download-google-drive-files-using-wget-3c2c025a8b99
define download_google
	@echo Downloading from Google.
	wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=${_Osm_Id}' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=${_Osm_Id}" -O $@ && rm -rf /tmp/cookies.txt
endef

${DOWNLOADS_DIR}/${_Osm_File}:
	@echo Downloading $@
	mkdir -p $(@D)
  ifneq (${_Osm_Download},)
    ifdef download_${_Osm_Download}
			$(call download_${_Osm_Download})
    else
      $(error Unsupported download method: ${_Osm_Download})
    endif
  else
    $(info Image download method not specified)
  endif

# Image unpack methods.
define _osm_unpack_zip
	unzip $< -d $(@D)
	touch $@
endef

define _osm_unpack_xz
	unxz -c $< > $@
endef

define _osm_unpack_tarz
	tar -xzf $< -C ${OSM_IMAGE_DIR}
endef

${OSM_IMAGE_DIR}/${_Osm_Image}: ${DOWNLOADS_DIR}/${_Osm_File}
	mkdir -p $(@D)
	@echo Extracting $<
	@echo Compressed file type: $(suffix $<)
	@echo Image unpack method: ${_Osm_Unpack}
  ifneq (${_Osm_Unpack},)
    ifdef _osm_unpack_${_Osm_Unpack}
			$(call _osm_unpack_${_Osm_Unpack})
    else
      $(error Unsupported unpack method: ${_Osm_Unpack})
    endif
  else
    $(info Image unpack method not specified)
  endif

os-modding-file: ${DOWNLOADS_DIR}/${_Osm_File}

os-modding: ${OSM_IMAGE_DIR}/${OSM_IMAGE}

# Need to handle images with more than one partition and to calc
# the correct offset for each offset (use partx).
define MountOsmImage =
	@mkdir -p ${OSM_IMAGE_MNT_DIR}/p1
	@echo "Mounting: p1"; \
	sudo mount -v -o offset=${_Osm_P1Offset},sizelimit=${_Osm_P1Size} ${OSM_IMAGE_DIR}/${OSM_IMAGE}} ${OSM_IMAGE_MNT_DIR}/p1
	@if [ "${_Osm_P2Name}" = "p2" ]; then \
	  mkdir -p ${OSM_IMAGE_MNT_DIR}/p2; \
	fi
	@if [ "${_Osm_P2Name}" = "p2" ]; then \
	  echo "Mounting: p2"; \
	  sudo mount -v -o offset=${_Osm_P2Offset},sizelimit=${_Osm_P2Size} ${OSM_IMAGE_DIR}/${OSM_IMAGE} ${OSM_IMAGE_MNT_DIR}/p2; \
	fi
	@ln -s ${OSM_IMAGE_MNT_DIR}/${_Osm_BootDir} ${OSM_IMAGE_MNT_DIR}/boot
	@ln -s ${OSM_IMAGE_MNT_DIR}/${_Osm_RootDir} ${OSM_IMAGE_MNT_DIR}/root
endef

define UnmountOsmImage =
  if mountpoint -q ${OSM_IMAGE_MNT_DIR}/p1; then \
    echo "Unmounting: p1"; \
    sudo umount ${OSM_IMAGE_MNT_DIR}/p1; \
    rmdir ${OSM_IMAGE_MNT_DIR}/p1; \
  fi; \
  if mountpoint -q ${OSM_IMAGE_MNT_DIR}/p2; then \
	  echo "Unmounting: p2"; \
	  sudo umount ${OSM_IMAGE_MNT_DIR}/p2; \
	  rmdir ${OSM_IMAGE_MNT_DIR}/p2; \
	fi; \
	rm ${OSM_IMAGE_MNT_DIR}/boot; \
	rm ${OSM_IMAGE_MNT_DIR}/root
endef

.PHONY: mount-os-modding
mount-os-modding: ${OSM_IMAGE_DIR}/${OSM_IMAGE}
	$(call MountOsmImage)

.PHONY: unmount-os-modding
unmount-os-modding:
	-$(call UnmountOsmImage)

.PHONY: os-modding-partitions
os-modding-partitions:
	fdisk -l --bytes ${OSM_IMAGE_DIR}/${OSM_IMAGE}
	mount | grep ${OSM_IMAGE_MNT_DIR}

${OSM_IMAGE_DIR}/${OSM_IMAGE}-tree.txt: ${OSM_IMAGE_DIR}/${OSM_IMAGE}
	$(call MountOsmImage)
	cd ${OSM_IMAGE_DIR}/mnt; tree -fi boot root > $@
	$(call UnmountOsmImage)

.PHONY: os-modding-tree
os-modding-tree: ${OSM_IMAGE_DIR}/${OSM_IMAGE}-tree.txt

.PHONY: list-os-boards
list-os-boards:
	@echo "Available boards:"
	@ls ${SBC_BOARDS_DIR}

ifeq (${MAKECMDGOALS},help-os-modding)
define HelpOsm_Msg
Usage: make [<option>=<value>] <target>

This make file and the included make segments define a framework
for developing and modifying OS images for small embedded systems.

Using the mount feature other segments can modify the contents of os image
as if it were part of the file system. Typically these modules install a
first time script which runs the first time the OS is booted. See other
segments for more information.

Command line options:
  SBC_BOARD=${SBC_BOARD}
    Which board to use (show-os-boards for more info).
  OS_VARIANT=${OS_VARIANT}
    Which OS variant to use for the selected OS board
    (show-os-variants for more info).
  DOWNLOADS_DIR=${DOWNLOADS_DIR}
    Where to put downladed packaged (e.g. compressed) image files.
  OSM_IMAGE_DIR=${OSM_IMAGE_DIR}
    Where to put unpackaged OS image files.

Defines:
  OSM_IMAGE = ${OSM_IMAGE}
    The modified OS image file.

Defined in ${SBC_BOARD}.mk:
  OS_BOARDS_DIR = ${OS_BOARDS_DIR}
    Where the OS board specific options are maintained. These define which
    OS variants are supported for a particular board.
  OS_VARIANTS_DIR = ${OS_VARIANTS_DIR}
    Where the OS variant specific definitions are maintained.
  OS_INIT_DIR = ${OS_INIT_DIR}
    Where the OS variant specific initialization scripts are maintained.
  ${OS_VARIANT}_OSM_IMAGE = ${${OS_VARIANT}_OSM_IMAGE}
    The OS image (typically .img).
  ${OS_VARIANT}_OSM_IMAGE_FILE = ${${OS_VARIANT}_OSM_IMAGE_FILE}
    The OS image package file.
  ${OS_VARIANT}_OSM_IMAGE_URL = ${${OS_VARIANT}_OSM_IMAGE_URL}
    Where to download the OS image package file from.
  ${OS_VARIANT}_OSM_DOWNLOAD = ${${OS_VARIANT}_OSM_DOWNLOAD}
    The tool to use to download the OS image file.
  ${OS_VARIANT}_OSM_UNPACK = ${${OS_VARIANT}_OSM_UNPACK}
    The tool to use to unpack the OS image package.
  ${OS_VARIANT}_OSM_P1_NAME = ${${OS_VARIANT}_OSM_P1_NAME}
    The name of the mount point for the first partition.
  ${OS_VARIANT}_OSM_P1_OFFSET = ${${OS_VARIANT}_OSM_P1_OFFSET}
    The offset in bytes to the start of the first partition.
  ${OS_VARIANT}_OSM_P1_SIZE = ${${OS_VARIANT}_OSM_P1_SIZE}
    The size in bytes of the first partition.
  ${OS_VARIANT}_OSM_P2_NAME = ${${OS_VARIANT}_OSM_P2_NAME}
    The mount point for the second partition if it exists.
    Leave undefined if there is no second partiton.
  ${OS_VARIANT}_OSM_P2_OFFSET = ${${OS_VARIANT}_OSM_P2_OFFSET}
    The offset in bytes to the start of the second partition.
  ${OS_VARIANT}_OSM_P2_SIZE = ${${OS_VARIANT}_OSM_P2_SIZE}
    The size in bytes of the second partition.
  ${OS_VARIANT}_OSM_BOOT_DIR = ${${OS_VARIANT}_OSM_BOOT_DIR}
    Path to the boot directory.
  ${OS_VARIANT}_OSM_ROOT_DIR = ${${OS_VARIANT}_OSM_ROOT_DIR}
    Path to the root directory.

Defines:
  MountOsmImage         A callable macro to mount the OS image partitions.
                        Other make segments can call this macro to mount
                        partitions before installing or modifying files in
                        the partitions.
  UnmountOsmImage       A callable macro to unmount the OS image partitions.
                        Other make segments can call this macro to unmount
                        partitions.

Command line targets:
  help-os-modding       Display this help.
  list-os-boards        Display a list of available boards on which an OS
                        can be installed.
  list-os-variants      Display a list of available OS variants. NOTE: The OS
                        board determines which variants can be used.
  os-modding-file       Download the OS image package file.
  os-modding            Unpack the OS image package file.
  mount-os-modding      Mount the OS image partitions (uses sudo).
  unmount-os-modding    Unmount the OS image partitions (uses sudo).
  os-modding-partitions Display the partitions in an OS image and where they
                        are moounted. This can be used to determine offsets
                        and sizes. NOTE: The displayed size is in bytes but
                        the offsets are the number of 512 byte sectors.
  os-modding-tree       Generates a text file containing a full list of Files
                        in the OS image. This can be used for locating files
                        in the image without having to mount it.

Uses:

endef

export HelpOsm_Msg
help-os-modding:
	@echo "$$HelpOsm_Msg" | less
endif
