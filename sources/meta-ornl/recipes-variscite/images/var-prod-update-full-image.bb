SUMMARY = "DART Production Base OS w/Update Recipe"
LICENSE = "MIT"

IMAGE_FEATURES += "ssh-server-dropbear splash "

require ornl-prod-image.bb

# DART boot is organized for SWUpdate with two rootfs (ping/pong).
# the kernel, dtb, uboot in a /boot/ folder on both rootfs
IMAGE_INSTALL_append = " \
	imx-test \
	iperf3 \
	kernel-image \
	kernel-devicetree \
	ksz-initscripts \
	mfgtest \
	packagegroup-core-full-cmdline \
	packagegroup-fsl-gstreamer1.0 \
	packagegroup-fsl-gstreamer1.0-full \
	packagegroup-fsl-tools-gpu \
	packagegroup-fsl-tools-gpu-external \
	packagegroup-imx-tools-audio \
	postinstall \
	swupdate \
	swupdate-www \
	u-boot-variscite \
"
