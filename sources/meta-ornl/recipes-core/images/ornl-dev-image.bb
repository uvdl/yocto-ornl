# Copyright (C) 2015 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Basically everything but the kitchen sink build."
LICENSE = "MIT"

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

inherit core-image distro_features_check extrausers utils

IMAGE_FEATURES += " \
    debug-tweaks \
    tools-sdk \
    splash \
    ssh-server-openssh \
    hwcodecs \
    tools-debug \
"

IMAGE_INSTALL_append += " \
	bind-utils \
	default-eth0 \
	dtc \
	flex \
	gcc \
	git \
	gpsd \
	gps-utils \
	gstd \
	gst-interpipe \
	gst-pylibgstc \
	${@base_contains("MACHINE", "var-som-mx6-ornl", "imx-test", "",d)} \
	iperf3 \
	${@base_contains("MACHINE", "var-som-mx6-ornl", "ksz-initscripts", "",d)} \
	libgps \
	libsodium \
	libsodium-dev \
	libtool \
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
	packagegroup-core-full-cmdline \
	${@base_contains("MACHINE", "var-som-mx6-ornl", "packagegroup-fsl-gstreamer1.0", "",d)} \
	${@base_contains("MACHINE", "var-som-mx6-ornl", "packagegroup-fsl-gstreamer1.0-full", "",d)} \
	${@base_contains("MACHINE", "var-som-mx6-ornl", "packagegroup-fsl-tools-benchmark", "",d)} \
	${@base_contains("MACHINE", "var-som-mx6-ornl", "packagegroup-fsl-tools-gpu", "",d)} \
	${@base_contains("MACHINE", "var-som-mx6-ornl", "packagegroup-fsl-tools-gpu-external", "",d)} \
	${@base_contains("MACHINE", "var-som-mx6-ornl", "packagegroup-fsl-tools-testapps", "",d)} \
	${@base_contains("MACHINE", "var-som-mx6-ornl", "packagegroup-imx-tools-audio", "",d)} \
	${@base_contains("MACHINE", "var-som-mx6-ornl", "packagegroup-tools-bluetooth", "",d)} \
	pkgconfig \
	postinstall \
	python-compiler \
	python3 \
	python3-dev \
	python3-future \
	python3-lxml \
	python3-netifaces \
	python3-pexpect \
	python3-pip \
	python3-protobuf \
	python3-pynmea2 \
	python3-pyserial \
	python3-pytz \
	python3-pyyaml \
	python3-requests \
	python3-urllib3 \
	python3-pymavlink \
	python3-mavproxy \
	strace \
	screen \
	strace \
	sudo \
	systemd-analyze \
	v4l-utils \
	webcam-tools \
	x265 \
	tcpdump \
	htop \
	iotop \
	perf \
	powertop \
"

