SUMMARY = "Minimal Base Production Image"

IMAGE_FEATURES += " read-only-rootfs"

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

LICENSE = "MIT"

inherit core-image

IMAGE_INSTALL_append_var-som-mx6-ornl += " \
	postinstall \
"


IMAGE_INSTALL_append = " \
	ornl-packagegroup-prod \
	python3 \
	python3-pip \
"
