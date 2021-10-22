FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

LOCALVERSION = "-tegra"

SRC_URI_append += " \
    file://tegra_disable_displays.patch \
"

SRC_URI_append_jetson-xavier-nx-devkit += " \
    file://uart0_high_speed.patch \
"

COMPATIBLE_MACHINE = "(jetson-nano-devkit|jetson-xavier-nx-devkit)"