SUMMARY = "DART Dev Update Recipe"

IMAGE_FEATURES += "ssh-server-dropbear splash "

LICENSE = "MIT"

require recipes-core/images/ornl-dev-image.bb

# Do to how the DART boot is organized for SWUpdate to work we have to have
# the kernel, dtb, uboot in a /boot/ folder on both rootfs
IMAGE_INSTALL_append = " \
	imx-test \
	ksz-initscripts \
	mfgtest \ 
	packagegroup-fsl-gstreamer1.0 \ 
	packagegroup-fsl-gstreamer1.0-full \
	packagegroup-fsl-tools-benchmark \
	packagegroup-fsl-tools-gpu \
	packagegroup-fsl-tools-gpu-external \
	packagegroup-fsl-tools-testapps \
	packagegroup-imx-tools-audio \ 
	packagegroup-tools-bluetooth \
	packagegroup-core-full-cmdline \
	postinstall \
	perf \
    swupdate \
    swupdate-www \
    kernel-image \
    kernel-devicetree \
    u-boot-variscite \
	dhcp-server \
"

COMPATIBLE_MACHINE = "var-som-mx6-ornl"