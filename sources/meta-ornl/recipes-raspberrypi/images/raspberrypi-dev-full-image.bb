SUMMARY = "Base Dev image for Raspberry Pi 4"

IMAGE_FEATURES += "ssh-server-dropbear splash "

LICENSE = "MIT"

require recipes-core/images/ornl-dev-image.bb

# Networkmanager nmcli is here because in Gatesgarth it is separated out into
# different packages

IMAGE_INSTALL_append = " \
    gstreamer1.0 \
	packagegroup-core-full-cmdline \
	networkmanager-nmcli \
	perf \
	swupdate \
    swupdate-www \
	u-boot \
"
