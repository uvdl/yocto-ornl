SUMMARY = "DART Minimal Base OS w/Update Recipe"
LICENSE = "MIT"

IMAGE_FEATURES += "ssh-server-dropbear splash "

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

require ornl-min-image.bb

# DART boot is organized for SWUpdate with two rootfs (ping/pong).
# the kernel, dtb, uboot in a /boot/ folder on both rootfs
IMAGE_INSTALL_append = " \
    swupdate \
    swupdate-www \
    kernel-image \
    kernel-devicetree \
    u-boot-variscite \
"
