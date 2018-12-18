FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

LOCALVERSION_var-som-mx6-ornl = "-mx6"


SRC_URI += "file://defconfig"

COMPATIBLE_MACHINE_var-som-mx6-ornl = "var-som-mx6-ornl"
