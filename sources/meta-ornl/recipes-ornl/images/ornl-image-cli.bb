# Copyright (C) 2015 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Minimist Console Image for python3 programs."
LICENSE = "MIT"

inherit core-image distro_features_check

IMAGE_FEATURES += " \
    package-management \
    ssh-server-dropbear \
    tools-debug \
"

CORE_IMAGE_EXTRA_INSTALL += " \
	packagegroup-core-full-cmdline \
	nodejs \
	flex \
	gcc \
	git \
	m4 \
	make \
	iperf3 \
	libtool \
	libsodium \
	libsodium-dev \
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
	systemd-analyze \
	strace \
	screen \
	minicom \
	openssl \
	imx-test \
	networkmanager \
	dtc \
	gpsd \
	gps-utils \
	libgps \
	ntp \
	ntp-bin \
"
