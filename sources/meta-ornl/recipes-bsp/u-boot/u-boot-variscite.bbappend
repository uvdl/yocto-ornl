COMPATIBLE_MACHINE = "var-som-mx6-ornl"
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

LOCALVERSION = "-mx6"

SRC_URI_append = " \
					file://0001-adding-iris2-support.patch \
					file://0002-adding-more-iris2-support.patch \
			   	  "

COMPATIBLE_MACHINE = "var-som-mx6-ornl"