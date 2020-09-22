FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

LOCALVERSION_var-som-mx6-ornl = "-mx6"


SRC_URI += "file://defconfig \
	   "

SRC_URI_append_var-som-mx6-ornl = "file://0001-creating-iris2-dtb.patch \
				   file://0002-adding-ksz9897-support.patch \
			   	  "

COMPATIBLE_MACHINE_var-som-mx6-ornl = "var-som-mx6-ornl"
