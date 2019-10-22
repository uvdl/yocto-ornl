# Copyright (C) 2015 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Display-enabled Image for python3 programs."
LICENSE = "MIT"

inherit core-image distro_features_check extrausers

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

IMAGE_FEATURES += " \
    splash \
    package-management \
    ssh-server-dropbear \
    hwcodecs \
    tools-debug \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '', \
       bb.utils.contains('DISTRO_FEATURES',     'x11', 'x11-base x11-sato', \
                                                       '', d), d)} \
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
	${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston-init', '', d)} \
        ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'weston-xwayland xterm', '', d)} \
        ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xterm', '', d)} \
        ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'packagegroup-core-x11-sato-games', '', d)} \
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
"
