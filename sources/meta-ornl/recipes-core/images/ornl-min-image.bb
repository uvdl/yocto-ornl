SUMMARY = "Minimal Base Production Image"

IMAGE_FEATURES += " read-only-rootfs"

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

LICENSE = "MIT"

inherit core-image

IMAGE_INSTALL_append = " \
	bind-utils \
	default-eth0 \
	libsodium \
	libsodium-dev \
	make \
	networkmanager \
	ntp \
	ntp-bin \
	openssl \
	openssl-bin \
	packagegroup-cockpit \
	pkgconfig \
	python3 \
"
