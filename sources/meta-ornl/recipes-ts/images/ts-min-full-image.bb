SUMMARY = "Base min image for Technologic Systems boards"

IMAGE_FEATURES += "ssh-server-dropbear splash "

LICENSE = "MIT"

require recipes-core/images/ornl-min-image.bb

IMAGE_INSTALL_append = " \
	packagegroup-core-full-cmdline \
	perf \
"