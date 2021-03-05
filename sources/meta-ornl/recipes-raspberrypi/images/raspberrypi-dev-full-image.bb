SUMMARY = "Base Dev image for Raspberry Pi 4"

IMAGE_FEATURES += "ssh-server-dropbear splash "

LICENSE = "MIT"

require recipes-core/images/ornl-dev-image.bb

# Do to how the DART boot is organized for SWUpdate to work we have to have
# the kernel, dtb, uboot in a /boot/ folder on both rootfs
IMAGE_INSTALL_append = " \
    gstreamer1.0 \
	packagegroup-core-full-cmdline \
	perf \
"