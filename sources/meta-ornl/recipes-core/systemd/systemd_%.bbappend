FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI += "file://0021-systemd-udevd.service.in-Set-MountFlags-as-shared-to.patch \
"

# remove additional packages pulled in by systemd
# https://stackoverflow.com/questions/52144173/systemd-customization

PACKAGECONFIG_remove = "timedated timesyncd"
