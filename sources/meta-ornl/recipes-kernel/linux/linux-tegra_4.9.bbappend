FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

LOCALVERSION = "-tegra"

SRC_URI_append_jetson-nano-devkit += " \
    file://pixc-kernel.patch \
"

SRC_URI_append_jetson-xavier-nx-devkit += " \
    file://xavier-nx-hdmi.patch \
    file://xavier-nx-rpi-camera.patch \
"

SRC_URI_append_jetson-xavier-nx-devkit-emmc += " \
    file://xavier-nx-hdmi.patch \
    file://xavier-nx-rpi-camera.patch \
"

COMPATIBLE_MACHINE = "(jetson-nano-devkit|jetson-nano-devkit-emmc|jetson-xavier-nx-devkit|jetson-xavier-nx-devkit-emmc)"