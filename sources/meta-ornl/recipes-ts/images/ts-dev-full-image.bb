SUMMARY = "Base Dev image for Technologic Systems boards"

IMAGE_FEATURES += "ssh-server-dropbear splash "

LICENSE = "MIT"

require recipes-core/images/ornl-dev-image.bb

IMAGE_INSTALL_append = " \
    iperf \
	packagegroup-core-full-cmdline \
	perf \
    u-boot-ts \
"