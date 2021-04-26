# Copyright (C) 2015 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Core Networking, Python and Video Compositing support"
LICENSE = "MIT"

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

inherit core-image extrausers

IMAGE_FEATURES += " \
	hwcodecs \
	ssh-server-openssh \
"

IMAGE_INSTALL_append += " \
	ornl-packagegroup-prod \
	git \
	libsodium \
	libsodium-dev \
	python3-pyyaml \
	python3-netifaces \
	libxml2-dev \
	libxslt-dev \
	webcam-tools \
	bind-utils \
	libtool \
	pkgconfig \
	gstd \
	gst-interpipe \
"
