SUMMARY = "Minimum Build Variscite Update Image"

IMAGE_FEATURES += "ssh-server-dropbear splash "

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

LICENSE = "MIT"

require recipes-core/images/ornl-min-image.bb

# Do to how the DART boot is organized for SWUpdate to work we have to have
# the kernel, dtb, uboot in a /boot/ folder on both rootfs
IMAGE_INSTALL_append = " \
	imx-test \
	kernel-devicetree \
	kernel-image \
	ksz-initscripts \
	packagegroup-core-full-cmdline \
	postinstall \
	swupdate \
	swupdate-www \
	u-boot-variscite \
"

COMPATIBLE_MACHINE = "var-som-mx6-ornl"
