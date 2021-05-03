DESCRIPTION = "Artifact recipe for kiwi raspberry pi image"
SECTION = ""

inherit swupdate

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Note: sw-description is mandatory
SRC_URI = " \
	file://sw-description \
	file://emmcsetup.lua \
"

# IMAGE_DEPENDS: list of Yocto images that contains a root filesystem
# it will be ensured they are built before creating swupdate image
IMAGE_DEPENDS = "rpi-dev-image-swu"

# SWUPDATE_IMAGES: list of images that will be part of the compound image
# the list can have any binaries - images must be in the DEPLOY directory
SWUPDATE_IMAGES = " \
	rpi-dev-image-swu \
"

# Images can have multiple formats - define which image must be
# taken to be put in the compound image
SWUPDATE_IMAGES_FSTYPES[rpi-dev-image-swu] = ".ext4.gz"

COMPATIBLE_MACHINE = "raspberrypi4-64"
