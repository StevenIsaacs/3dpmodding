#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# OS Image
#----------------------------------------------------------------------------
define OsImageHelp
Make segment: os_image.mk

This segment is used to download, unpack, mount and unmount image files.
Using the mount feature other segments can modify the contents of os image
as if it were part of the file system. Typically these modules install a
first time script which runs the first time the OS is booted. See other
segments for more information.

Defined in mod.mk:
  USE_OPIZ      Use an Orange PI zero.
  USE_RPI3      Use a Raspberry PI 3.
  USE_RPI4      Use a Raspberry PI 4.
  NOTE: These options are mutually exclusive.

Defined in the segment which included this file:
  OS_VARIANT    Which variant of the OS to use. Determined by which USE_<board>
                option was specified in mod.mk.
                Currently - ${OS_VARIANT}
                Selected by USE_${OS_VARIANT}

Defined in options.mk:
  DOWNLOADS_DIR Where to put downladed packaged (e.g. compressed) image files.
  OS_IMAGE_DIR  Where to put unpackaged OS image files.
  ${OS_VARIANT}_OS_IMAGE
                The OS image (typically .img).
  ${OS_VARIANT}_OS_IMAGE_FILE
                The OS image package file.
  ${OS_VARIANT}_OS_IMAGE_URL
                Where to download the OS image package file from.
  ${OS_VARIANT}_OS_UNPACK
                The tool to use to unpack the OS image package.
  ${OS_VARIANT}_OS_P1_NAME
                The name of the mount point for the first partition.
  ${OS_VARIANT}_OS_P1_OFFSET
                The offset in bytes to the start of the first partition.
  ${OS_VARIANT}_OS_P1_SIZE
                The size in bytes of the first partition.
  ${OS_VARIANT}_OS_P2_NAME
                The mount point for the second partition if it exists.
                Leave undefined if there is no second partiton.
  ${OS_VARIANT}_OS_P2_OFFSET
                The offset in bytes to the start of the second partition.
  ${OS_VARIANT}_OS_P2_SIZE
                The size in bytes of the second partition.
  ${OS_VARIANT}_OS_BOOT_DIR
                Path to the boot directory.
                (${${OS_VARIANT}_OS_BOOT_DIR}).
  ${OS_VARIANT}_OS_ROOT_DIR
                Path to the root directory.
                (${${OS_VARIANT}_OS_ROOT_DIR}).

Defines:
  mount-os-image      A callable macro to mount the OS image partitions.
                      An example is the mount_os_image target. Other make
                      segments can call this macro to mount partitions before
                      installing or modifying files in the partitions.
  unmount-os-image    A callable macro to unmount the OS image partitions.
                      An example is the unmount_os_image target. Other make
                      segments can call this macro to unmount partitions.
                      WARNING: If unmount-os-image is not called then
                      subsequent attempts to mount the partitions will fail.

Command line targets:
  help-os_image       Display this help.
  os_image_file       Download the OS image package file.
  os_image            Unpack the OS image package file.
  mount_os_image      Mount the OS image partitions (uses sudo).
  unmount_os_image    Unmount the OS image partitions (uses sudo).
  os_image_partitions
                      Display the partitions in an OS image and where they
                      are moounted. This can be used to determine offsets
                      and sizes. NOTE: The displayed size is in bytes but
                      the offsets are the number of 512 byte sectors.

Uses:

endef
export OsImageHelp
help-os_image:
	@echo "$$OsImageHelp"

#+
# Download, unpack, mount, and unmount OS image files.
# Provides callable functions to mount and unmount so the images can be
# modified.
# Currently a maximum of two partitions are assumed to be the boot and
# root (not to be confused with /root). Symbolic links are created to
# point to the corresponding directories.
#-

$(info Using OS variant: ${OS_VARIANT})

_OsImage = ${${OS_VARIANT}_OS_IMAGE}
_OsImageFile = ${${OS_VARIANT}_OS_IMAGE_FILE}
_OsImageUrl = ${${OS_VARIANT}_OS_IMAGE_URL}
_OsImageUnpack = ${${OS_VARIANT}_OS_UNPACK}
_OsImageP1Name = ${${OS_VARIANT}_OS_P1_NAME}
_OsImageP1Offset = ${${OS_VARIANT}_OS_P1_OFFSET}
_OsImageP1Size = ${${OS_VARIANT}_OS_P1_SIZE}
_OsImageP2Name = ${${OS_VARIANT}_OS_P2_NAME}
_OsImageP2Offset = ${${OS_VARIANT}_OS_P2_OFFSET}
_OsImageP2Size = ${${OS_VARIANT}_OS_P2_SIZE}
_OsImageBootDir = ${${OS_VARIANT}_OS_BOOT_DIR}
_OsImageRootDir = ${${OS_VARIANT}_OS_ROOT_DIR}

${DOWNLOADS_DIR}/${_OsImageFile}:
	mkdir -p $(@D)
	wget -O $@ ${_OsImageUrl}

${OS_IMAGE_DIR}/${_OsImage}: \
  ${DOWNLOADS_DIR}/${_OsImageFile}
	mkdir -p $(@D)
	echo Extracting $<
	echo Compressed file type: $(suffix $<)
	echo Image unpack method: ${_OsImageUnpack}
    ifeq (${_OsImageUnpack},ZIP)
	  unzip $< -d $(@D)
	  touch $@
    else ifeq (${_OsImageUnpack},XZ)
	  unxz -c $< > $@
    else
      $(error Unsupported OS image unpack method)
    endif

os_image_file: ${DOWNLOADS_DIR}/${_OsImageFile}

os_image: ${OS_IMAGE_DIR}/${_OsImage}

# Need to handle images with more than one partition and to calc
# the correct offset for each offset (use partx).
define mount-os-image =
	@mkdir ${OS_IMAGE_MNT_DIR}/p1
	@echo "Mounting: p1"; \
	sudo mount -v -o offset=${_OsImageP1Offset},sizelimit=${_OsImageP1Size} ${OS_IMAGE_DIR}/${_OsImage} ${OS_IMAGE_MNT_DIR}/p1
	@if [ "${_OsImageP2Name}" = "p2" ]; then \
	  mkdir ${OS_IMAGE_MNT_DIR}/p2; \
	fi
	@if [ "${_OsImageP2Name}" = "p2" ]; then \
	  echo "Mounting: p2"; \
	  sudo mount -v -o offset=${_OsImageP2Offset},sizelimit=${_OsImageP2Size} ${OS_IMAGE_DIR}/${_OsImage} ${OS_IMAGE_MNT_DIR}/p2; \
	fi
	@ln -s ${OS_IMAGE_MNT_DIR}/${_OsImageBootDir} ${OS_IMAGE_MNT_DIR}/boot
	@ln -s ${OS_IMAGE_MNT_DIR}/${_OsImageRootDir} ${OS_IMAGE_MNT_DIR}/root
endef

define unmount-os-image =
	@echo "Unmounting: p1"; \
	sudo umount ${OS_IMAGE_MNT_DIR}/p1; \
	rmdir ${OS_IMAGE_MNT_DIR}/p1
	@if [ -d ${OS_IMAGE_MNT_DIR}/p2 ]; then \
	  echo "Unmounting: p2"; \
	  sudo umount ${OS_IMAGE_MNT_DIR}/p2; \
	  rmdir ${OS_IMAGE_MNT_DIR}/p2; \
	fi; \
	rm ${OS_IMAGE_MNT_DIR}/boot; \
	rm ${OS_IMAGE_MNT_DIR}/root
endef

.PHONY: mount_os_image
mount_os_image: ${OS_IMAGE_DIR}/${_OsImage}
	$(call mount-os-image)

.PHONY: unmount_os_image
unmount_os_image:
	-$(call unmount-os-image)

.PHONY: os_image_partitions
os_image_partitions:
	fdisk -l --bytes ${OS_IMAGE_DIR}/${_OsImage}
	mount | grep ${OS_IMAGE_MNT_DIR}

MOD_DEPS += ${OS_IMAGE_DIR}/${_OsImage}
