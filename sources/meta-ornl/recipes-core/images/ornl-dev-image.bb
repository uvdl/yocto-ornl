# Copyright (C) 2015 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Basically everything but the kitchen sink build."
LICENSE = "MIT"

inherit core-image distro_features_check extrausers

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

IMAGE_FEATURES += " \
    debug-tweaks \
    tools-sdk \
    splash \
    package-management \
    ssh-server-openssh \
    hwcodecs \
    tools-debug \
"

CORE_IMAGE_EXTRA_INSTALL += " \
	packagegroup-core-full-cmdline \
	packagegroup-tools-bluetooth \
	packagegroup-imx-tools-audio \
	packagegroup-fsl-tools-gpu \
	packagegroup-fsl-tools-gpu-external \
	packagegroup-fsl-tools-testapps \
	packagegroup-fsl-tools-benchmark \
	packagegroup-fsl-gstreamer1.0 \
	packagegroup-fsl-gstreamer1.0-full \
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
	strace \
	screen \
	systemd-analyze \
	minicom \
	openssl \
	imx-test \
	networkmanager \
	v4l-utils \
	dtc \
	gpsd \
	gps-utils \
	libgps \
	ntp \
	ntp-bin \
	postinstall \
"
