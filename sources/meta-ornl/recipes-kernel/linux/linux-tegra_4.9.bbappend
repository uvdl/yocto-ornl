FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

LOCALVERSION = "-tegra"

SRC_URI_append += " \
    file://pixc-kernel.patch \
"

COMPATIBLE_MACHINE = "(jetson-nano-devkit|jetson-nano-devkit-emmc|jetson-xavier-nx-devkit|jetson-xavier-nx-devkit-emmc)"