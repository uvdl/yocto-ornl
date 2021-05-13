SUMMARY = "DART Dev Update Recipe"

IMAGE_FEATURES += "ssh-server-dropbear splash "

LICENSE = "MIT"

require recipes-core/images/ornl-dev-image.bb

# Do to how the DART boot is organized for SWUpdate to work we have to have
# the kernel, dtb, uboot in a /boot/ folder on both rootfs
IMAGE_INSTALL_append = " \
	dhcp-server \
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
	postinstall \
	swupdate \
	swupdate-www \
	u-boot-variscite \
"

COMPATIBLE_MACHINE = "var-som-mx6-ornl"
