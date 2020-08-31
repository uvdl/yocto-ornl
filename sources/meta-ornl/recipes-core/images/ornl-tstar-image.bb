SUMMARY = "Stargazer production image"

IMAGE_FEATURES += "ssh-server-dropbear splash"

# https://wiki.yoctoproject.org/wiki/FAQ:How_do_I_set_or_change_the_root_password
EXTRA_USERS_PARAMS = "usermod -P root root;"

LICENSE = "MIT"

inherit core-image

CORE_IMAGE_EXTRA_INSTALL = "ornl-packagegroup-prod postinstall"