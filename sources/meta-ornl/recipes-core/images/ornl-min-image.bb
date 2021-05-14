# Copyright (C) 2015 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Minimal Image w/SWUpdate (read-only filesystem)"
LICENSE = "MIT"

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

inherit core-image distro_features_check extrausers

IMAGE_FEATURES += " \
	read-only-rootfs \
"

IMAGE_INSTALL_append += " \
	bind-utils \
	default-eth0 \
	libsodium \
	libsodium-dev \
	make \
	networkmanager \
	ntp \
	ntp-bin \
	openssl \
	openssl-bin \
	pkgconfig \
	python3 \
"
