# Copyright (C) 2015 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Minimal Image SWUpdate (read-only filesystem)"
LICENSE = "MIT"

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

inherit core-image

IMAGE_FEATURES += " read-only-rootfs"

IMAGE_INSTALL_append = " \
	ornl-packagegroup-prod \
	postinstall \
	python-compiler \
	python3 \
	python3-pip \
"
