# Copyright (C) 2015 Freescale Semiconductor
# Released under the MIT license (see COPYING.MIT for the terms)
DESCRIPTION = "Basically everything but the kitchen sink build."

IMAGE_FEATURES += " \
    debug-tweaks \
    tools-sdk \
    splash \
    package-management \
    ssh-server-openssh \
"

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

LICENSE = "MIT"

inherit core-image

IMAGE_INSTALL_append += " \
	packagegroup-imx-tools-audio \
	packagegroup-fsl-gstreamer1.0 \
	packagegroup-fsl-gstreamer1.0-full \
	git \
	libsodium \
	libsodium-dev \
    python3-netifaces \
    python3-yaml \
    uvcdynctrl \
    libxml2-dev \
    libxslt-dev \
"