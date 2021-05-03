SUMMARY = "This is the Variscite specific update image for just production dependencies"

IMAGE_FEATURES += "ssh-server-dropbear splash "

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

LICENSE = "MIT"

require recipes-core/images/ornl-prod-image.bb

# DART boot is organized for SWUpdate with two rootfs (ping/pong).
# the kernel, dtb, uboot in a /boot/ folder on both rootfs
IMAGE_INSTALL_append = " \
    packagegroup-imx-tools-audio \
    packagegroup-fsl-gstreamer1.0-full \
    packagegroup-fsl-gstreamer1.0 \
    packagegroup-fsl-tools-gpu \
    packagegroup-fsl-tools-gpu-external \
    imx-test \
    ksz-initscripts \
    swupdate \
    swupdate-www \
    kernel-image \
    kernel-devicetree \
    u-boot-variscite \
"

COMPATIBLE_MACHINE = "var-som-mx6-ornl"