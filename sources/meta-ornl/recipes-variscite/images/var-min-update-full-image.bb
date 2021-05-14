SUMMARY = "DART Minimal Base OS w/Update Recipe"
LICENSE = "MIT"

IMAGE_FEATURES += "ssh-server-dropbear splash "

require ornl-min-image.bb

# DART boot is organized for SWUpdate with two rootfs (ping/pong).
# the kernel, dtb, uboot in a /boot/ folder on both rootfs
IMAGE_INSTALL_append = " \
	kernel-image \
	kernel-devicetree \
	ksz-initscripts \
	mfgtest \
	packagegroup-core-full-cmdline \
	postinstall \
	swupdate \
	swupdate-www \
	u-boot-variscite \
"
