SUMMARY = "Minimal Base Production Image"

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

LICENSE = "MIT"

inherit core-image extrausers

IMAGE_INSTALL_append = " \
	bind-utils \
	chrony \
	chronyc \
	libsodium \
	libsodium-dev \
	make \
	networkmanager \
	openssl \
	openssl-bin \
	pkgconfig \
	vim \
"

