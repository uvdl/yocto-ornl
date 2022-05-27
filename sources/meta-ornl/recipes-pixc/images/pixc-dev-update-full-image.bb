SUMMARY = "DART Development Base OS w/Update Recipe"
LICENSE = "MIT"

IMAGE_FEATURES += "ssh-server-dropbear splash "

require recipes-core/images/ornl-dev-image.bb

# DART boot is organized for SWUpdate with two rootfs (ping/pong).
# the kernel, dtb, uboot in a /boot/ folder on both rootfs
IMAGE_INSTALL_append = " \
	imx-test \
	kernel-devicetree \
	kernel-image \
	ksz-initscripts \
	mfgtest \
	packagegroup-core-full-cmdline \
	packagegroup-fsl-gstreamer1.0 \
	packagegroup-fsl-gstreamer1.0-full \
	packagegroup-fsl-tools-benchmark \
	packagegroup-fsl-tools-gpu \
	packagegroup-fsl-tools-gpu-external \
	packagegroup-fsl-tools-testapps \
	packagegroup-imx-tools-audio \
	packagegroup-tools-bluetooth \
	perf \
	swupdate \
	swupdate-www \
	u-boot-variscite \
"

COMPATIBLE_MACHINE = "(pix-c3|var-som-6ul)"
