FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

SRC_URI_append += " file://tegra_disable_hdmi.patch"

COMPATIBLE_MACHINE = "jetson-nano-devkit"