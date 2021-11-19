SUMMARY = "Base Dev image for Technologic Systems boards"

IMAGE_FEATURES += "ssh-server-dropbear splash "

LICENSE = "MIT"

require recipes-core/images/ornl-dev-image.bb

IMAGE_INSTALL_append = " \
    gstreamer1.0 \
	packagegroup-core-full-cmdline \
	perf \
    python2 \
    u-boot-ts \
"