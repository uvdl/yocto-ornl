SUMMARY = "Base production image for Technologic Systems boards"

IMAGE_FEATURES += "ssh-server-dropbear splash "

LICENSE = "MIT"

require recipes-core/images/ornl-prod-image.bb

IMAGE_INSTALL_append = " \
	packagegroup-core-full-cmdline \
	perf \
    python3 \
    python2 \
    perl \
"