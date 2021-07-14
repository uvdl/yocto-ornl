FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

LOCALVERSION = "-tegra"

SRC_URI_append += " \
    file://tegra_disable_displays.patch \
"

COMPATIBLE_MACHINE = "jetson-nano-devkit"