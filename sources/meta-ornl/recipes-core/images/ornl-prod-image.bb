# Copyright (C) 2015 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Core Networking, Python and Video Compositing support"
LICENSE = "MIT"

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

inherit core-image distro_features_check extrausers

IMAGE_FEATURES += " \
	hwcodecs \
	ssh-server-openssh \
"

IMAGE_INSTALL_append += " \
	bind-utils \
	default-eth0 \
	dtc \
	elp-h264 \
	flex \
	git \
	gpsd \
	gps-utils \
	gstd \
	gst-interpipe \
	libgps \
	libsodium \
	libsodium-dev \
	libtool \
	libxml2-dev \
	libxslt-dev \
	m4 \
	make \
	minicom \
	networkmanager \
	nodejs \
	ntp \
	ntp-bin \
	openssl \
	openssl-bin \
	packagegroup-cockpit \
	pkgconfig \
	python-compiler \
	python3 \
	python3-bottle \
	python3-future \
	python3-lxml \
	python3-mavproxy \
	python3-netifaces \
	python3-pexpect \
	python3-pip \
	python3-protobuf \
	python3-pymavlink \
	python3-pynmea2 \
	python3-pyserial \
	python3-pytz \
	python3-pyyaml \
	python3-requests \
	python3-uptime \
	python3-urllib3 \
	v4l-utils \
	webcam-tools \
	x264 \
	x265 \
"
