SUMMARY = "DART Development Base OS w/Update Recipe"
LICENSE = "MIT"

IMAGE_FEATURES += "ssh-server-dropbear splash "

require recipes-core/images/ornl-dev-image.bb

# DART boot is organized for SWUpdate with two rootfs (ping/pong).
# the kernel, dtb, uboot in a /boot/ folder on both rootfs
IMAGE_INSTALL_append = " \
    swupdate \
    swupdate-www \
    kernel-image \
    kernel-devicetree \
    ksz-initscripts \
    u-boot-variscite \
"
