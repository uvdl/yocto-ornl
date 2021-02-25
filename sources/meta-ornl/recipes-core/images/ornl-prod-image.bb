# Copyright (C) 2015 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Core networking and Python support"
LICENSE = "MIT"

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

inherit core-image

IMAGE_FEATURES += " ssh-server-openssh "

IMAGE_INSTALL_append += " \
	bind-utils \
	git \
	gstd \
	gst-interpipe \
	ksz-initscripts \
	libsodium \
	libsodium-dev \
	libtool \
	libxml2-dev \
	libxslt-dev \
	packagegroup-imx-tools-audio \
	packagegroup-fsl-gstreamer1.0-full \
	packagegroup-fsl-gstreamer1.0 \
	packagegroup-prod \
	pkgconfig \
	python3-pyyaml \
	python3-netifaces \
	webcam-tools \
"
