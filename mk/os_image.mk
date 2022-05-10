#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# OS Image
#----------------------------------------------------------------------------

#+
# Download, unpack, mount, and unmount OS image files.
# Provides callable functions to mount and unmount so the images can be
# modified.
# Currently a maximum of two partitions are assumed to be the boot and
# root (not to be confused with /root). Symbolic links are created to
# point to the corresponding directories.
#-

$(info Using OS variant: ${OS_VARIANT})

OsImage = ${${OS_VARIANT}_OS_IMAGE}
OsImageFile = ${${OS_VARIANT}_OS_IMAGE_FILE}
OsImageUrl = ${${OS_VARIANT}_OS_IMAGE_URL}
OsImageUnpack = ${${OS_VARIANT}_OS_UNPACK}
OsImageP1Name = ${${OS_VARIANT}_OS_P1_NAME}
OsImageP1Offset = ${${OS_VARIANT}_OS_P1_OFFSET}
OsImageP1Size = ${${OS_VARIANT}_OS_P1_SIZE}
OsImageP2Name = ${${OS_VARIANT}_OS_P2_NAME}
OsImageP2Offset = ${${OS_VARIANT}_OS_P2_OFFSET}
OsImageP2Size = ${${OS_VARIANT}_OS_P2_SIZE}
OsImageBootDir = ${${OS_VARIANT}_OS_BOOT_DIR}
OsImageRootDir = ${${OS_VARIANT}_OS_ROOT_DIR}

${DOWNLOADS_DIR}/${OsImageFile}:
	mkdir -p $(@D)
	wget -O $@ ${OsImageUrl}

${OS_IMAGE_DIR}/${OsImage}: \
  ${DOWNLOADS_DIR}/${OsImageFile}
	mkdir -p $(@D)
	echo Extracting $<
	echo Compressed file type: $(suffix $<)
	echo Image unpack method: ${OsImageUnpack}
    ifeq (${OsImageUnpack},ZIP)
	  unzip $< -d $(@D)
	  touch $@
    else ifeq (${OsImageUnpack},XZ)
	  unxz -c $< > $@
    else
      $(error Unsupported OS image unpack method)
    endif

os_image_file: ${DOWNLOADS_DIR}/${OsImageFile}

os_image: ${OS_IMAGE_DIR}/${OsImage}

# Need to handle images with more than one partition and to calc
# the correct offset for each offset (use partx).
define mount-os-image =
	@mkdir ${OS_IMAGE_MNT_DIR}/p1
	@echo "Mounting: p1"; \
	sudo mount -v -o offset=${OsImageP1Offset},sizelimit=${OsImageP1Size} ${OS_IMAGE_DIR}/${OsImage} ${OS_IMAGE_MNT_DIR}/p1
	@if [ "${OsImageP2Name}" = "p2" ]; then \
	  mkdir ${OS_IMAGE_MNT_DIR}/p2; \
	fi
	@if [ "${OsImageP2Name}" = "p2" ]; then \
	  echo "Mounting: p2"; \
	  sudo mount -v -o offset=${OsImageP2Offset},sizelimit=${OsImageP2Size} ${OS_IMAGE_DIR}/${OsImage} ${OS_IMAGE_MNT_DIR}/p2; \
	fi
	@ln -s ${OS_IMAGE_MNT_DIR}/${OsImageBootDir} ${OS_IMAGE_MNT_DIR}/boot
	@ln -s ${OS_IMAGE_MNT_DIR}/${OsImageRootDir} ${OS_IMAGE_MNT_DIR}/root
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
mount_os_image: ${OS_IMAGE_DIR}/${OsImage}
	$(call mount-os-image)

.PHONY: unmount_os_image
unmount_os_image:
	-$(call unmount-os-image)

.PHONY: os_image_partitions
os_image_partitions:
	fdisk -l --bytes ${OS_IMAGE_DIR}/${OsImage}
	mount | grep ${OS_IMAGE_MNT_DIR}

MOD_DEPS += ${OS_IMAGE_DIR}/${OsImage}
