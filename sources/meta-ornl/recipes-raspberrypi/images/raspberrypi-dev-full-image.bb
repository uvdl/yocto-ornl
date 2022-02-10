SUMMARY = "Base Dev image for Raspberry Pi 4"

IMAGE_FEATURES += "ssh-server-dropbear splash "

LICENSE = "MIT"

require recipes-core/images/ornl-dev-image.bb

# NOTE if using Gatesgarth use Networkmanager-nmcli it is separated out into
# different packages for that version

IMAGE_INSTALL_append = " \
	gstreamer1.0 \
	packagegroup-core-full-cmdline \
	mender-client \
	perf \
	u-boot \
"
