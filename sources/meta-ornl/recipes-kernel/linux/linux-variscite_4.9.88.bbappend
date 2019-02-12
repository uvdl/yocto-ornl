FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

LOCALVERSION_var-som-mx6-ornl = "-mx6"

SRC_URI_append_var-som-mx6-ornl = " \
									file://ornl_defconfig \
									file://0001-adding-iris2-dts.patch \
									file://0002-adding-ksz9897-driver.patch \
			   	  "

KERNEL_DEFCONFIG_var-som-mx6-ornl = "${WORKDIR}/ornl_defconfig"

COMPATIBLE_MACHINE_var-som-mx6-ornl = "var-som-mx6-ornl"