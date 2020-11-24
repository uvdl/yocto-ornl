COMPATIBLE_MACHINE = "var-som-mx6-ornl"
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

LOCALVERSION_var-som-mx6-ornl = "-mx6"

SRC_URI_append_var-som-mx6-ornl = " \
									file://0001-adding-iris2-support.patch \
									file://0002-adding-more-iris2-support.patch \
			   	  "

COMPATIBLE_MACHINE_var-som-mx6-ornl = "var-som-mx6-ornl"