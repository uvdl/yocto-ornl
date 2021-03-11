# Copyright (C) 2015 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Development Support - Everything but the kitchen sink"
LICENSE = "MIT"

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

inherit core-image distro_features_check extrausers

IMAGE_FEATURES += " \
	debug-tweaks \
	hwcodecs \
	splash \
	ssh-server-openssh \
	tools-debug \
	tools-sdk \
"

IMAGE_INSTALL_append += " \
	bind-utils \
	cockpit \
	cockpit-ws \
	cockpit-users \
	cockpit-shell \
	cockpit-networkmanager \
	cockpit-systemd \
	default-eth0 \
	dtc \
	elp-h264 \
	flex \
	gcc \
	git \
	gpsd \
	gps-utils \
	gstd \
	gstreamer1.0-plugins-ugly \
	gst-interpipe \
	gst-pylibgstc \
	htop \
	imx-test \
	iotop \
	iperf3 \
	ksz-initscripts \
	libgps \
	libsodium \
	libsodium-dev \
	libtool \
	libxml2-dev \
	libxslt-dev \
	m4 \
	make \
	mfgtest \
	minicom \
	networkmanager \
	nodejs \
	ntp \
	ntp-bin \
	openssl \
	openssl-bin \
	packagegroup-core-full-cmdline \
	packagegroup-fsl-gstreamer1.0 \
	packagegroup-fsl-gstreamer1.0-full \
	packagegroup-fsl-tools-benchmark \
	packagegroup-fsl-tools-gpu \
	packagegroup-fsl-tools-gpu-external \
	packagegroup-fsl-tools-testapps \
	packagegroup-imx-tools-audio \
	packagegroup-tools-bluetooth \
	perf \
	pkgconfig \
	postinstall \
	powertop \
	python-compiler \
	python3 \
	python3-bottle \
	python3-dev \
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
	screen \
	strace \
	sudo \
	systemd-analyze \
	tcpdump \
	v4l-utils \
	webcam-tools \
	x264 \
	x265 \
"
