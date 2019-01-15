FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " file://settings"

COMPATIBLE_MACHINE_var-som-mx6-ornl = "(var-som-mx6-ornl)"