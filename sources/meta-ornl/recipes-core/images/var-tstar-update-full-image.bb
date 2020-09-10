SUMMARY = "Generic Production DART Update Image"

IMAGE_FEATURES += "ssh-server-dropbear splash "

LICENSE = "MIT"

require ornl-tstar-image.bb

# Do to how the DART boot is organized for SWUpdate to work we have to have
# the kernel, dtb, uboot in a /boot/ folder on both rootfs
IMAGE_INSTALL_append = " \
    swupdate \
    swupdate-www \
    kernel-image \
    kernel-devicetree \
    u-boot-variscite \
"