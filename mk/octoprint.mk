#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Octoprint
#----------------------------------------------------------------------------

# For Octoprint.
# USE_OCTOPRINT = YES
# USE_OCTOPRINT = NO

# OctoPrint on an Orange PI Zero.
# USE_OPIZ = YES
# USE_OPIZ = NO

# OctoPrint on a Raspberry PI 3.
# USE_RPI3 = YES
# USE_RPI3 = NO

# OctoPrint on a Raspberry PI 4.
# USE_RPI4 = YES
# USE_RPI4 = NO

# MODEL_OPTIONS are appended in case the model defines cases for the boards.
MODEL_OPTIONS += USE_OCTOPRINT=YES

ifeq (${USE_OPIZ},YES)
# Installation instructions are at:
#  https://daumemo.com/installing-octoprint-on-orangepi-zero-part-1/
MODEL_OPTIONS += USE_OPIZ=YES

# Bullseye is Debian based.
OS_VERSION = Armbian_22.02.1_Orangepizero_bullseye_current_5.15.25

OS_IMAGE = ${OS_VERSION}.img
OS_IMAGE_FILE = ${OS_VERSION}.img.xz
OS_IMAGE_URL = https://redirect.armbian.com/orangepizero/Bullseye_current

UseXz = YES
else ifeq (${USE_RPI3},YES)
MODEL_OPTIONS += USE_RPI3=YES

# Pre-configured Raspberry PI OS (Raspian) image.
OS_VERSION = 0.18.0-1.7.3-20220323100241
OS_IMAGE_FILE = octopi-${OS_VERSION}.zip
OS_IMAGE = octopi-${OS_VERSION}.img
OS_IMAGE_URL = https://github.com/OctoPrint/OctoPi-UpToDate/releases/download/${OS_VERSION}/${OS_IMAGE_FILE}

UseZip = YES
else ifeq (${USE_RPI4},YES)
MODEL_OPTIONS += USE_RPI4=YES

# Pre-configured Raspberry PI OS (Raspian) image.
OS_VERSION = 0.18.0-1.7.3-20220323100241
OS_IMAGE_FILE = octopi-${OS_VERSION}.zip
OS_IMAGE = octopi-${OS_VERSION}.img
OS_IMAGE_URL = https://github.com/OctoPrint/OctoPi-UpToDate/releases/download/${OS_VERSION}/${OS_IMAGE_FILE}

UseZip = YES
else
  $(error Platform has not been specified.)
endif

${DOWNLOADS_DIR}/${OS_IMAGE_FILE}:
	mkdir -p $(@D)
	wget -O $@ ${OS_IMAGE_URL}

${OS_IMAGE_DIR}/${OS_IMAGE}: \
  ${DOWNLOADS_DIR}/${OS_IMAGE_FILE}
	mkdir -p $(@D)
	$(info Extracting $<)
	$(info Compressed file type: $(suffix $<))
    ifeq (${UseZip},YES)
	  unzip $< -d $(@D)
	  touch $@
    endif
    ifeq (${UseXz},YES)
	  unxz -c $< > $@
    endif

.PHONY os_image_file:
os_image_file: ${DOWNLOADS_DIR}/${OS_IMAGE_FILE}

.PHONY os_image:
os_image: ${OS_IMAGE_DIR}/${OS_IMAGE}

MOD_DEPS += ${OS_IMAGE_DIR}/${OS_IMAGE}
