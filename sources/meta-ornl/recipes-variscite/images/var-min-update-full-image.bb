SUMMARY = "DART Minimal Base OS w/Update Recipe"
LICENSE = "MIT"

IMAGE_FEATURES += "ssh-server-dropbear splash "

require recipes-core/images/ornl-min-image.bb

# DART boot is organized for SWUpdate with two rootfs (ping/pong).
# the kernel, dtb, uboot in a /boot/ folder on both rootfs
IMAGE_INSTALL_append = " \
	imx-test \
	mfgtest \
	packagegroup-core-full-cmdline \
"

COMPATIBLE_MACHINE = "imx6ul-var-dart"
