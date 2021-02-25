# Copyright (C) 2015 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Minimal Image SWUpdate (read-only filesystem)"
LICENSE = "MIT"

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

inherit core-image distro_features_check extrausers

IMAGE_FEATURES += " read-only-rootfs"

IMAGE_INSTALL_append = " \
	default-eth0 \
	dtc \
	gpsd \
	gps-utils \
	flex \
	imx-test \
	iperf3 \
	libgps \
	libtool \
	make \
	minicom \
	m4 \
	networkmanager \
	nodejs \
	ntp \
	ntp-bin \
	openssl \
	packagegroup-core-full-cmdline \
	packagegroup-fsl-tools-gpu \
	packagegroup-fsl-tools-gpu-external \
	postinstall \
	python-compiler \
	python3 \
	python3-lxml \
	python3-pip \
	python3-protobuf \
	python3-requests \
	python3-pexpect \
	python3-pyserial \
	python3-pytz \
	python3-urllib3 \
	python3-pynmea2 \
	python3-pymavlink \
	python3-future \
	python3-mavproxy \
	v4l-utils \
"
