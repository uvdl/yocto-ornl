# Copyright (C) 2015 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)
DESCRIPTION = "Just the needed packages for the Ground Robotics build"

IMAGE_FEATURES += " ssh-server-openssh "

LICENSE = "MIT"

inherit core-image

IMAGE_INSTALL_append += " \
    ornl-packagegroup-prod \
    ${@base_contains("MACHINE", "var-som-mx6-ornl", "packagegroup-imx-tools-audio", "",d)} \
    ${@base_contains("MACHINE", "var-som-mx6-ornl", "packagegroup-fsl-gstreamer1.0-full", "",d)} \
    ${@base_contains("MACHINE", "var-som-mx6-ornl", "packagegroup-fsl-gstreamer1.0", "",d)} \
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
    gst-pylibgstc \
    gstd \
    gst-interpipe \
    ${@base_contains("MACHINE", "var-som-mx6-ornl", "ksz-initscripts", "",d)} \
"