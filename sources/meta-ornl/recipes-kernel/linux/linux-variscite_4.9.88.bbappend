FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

LOCALVERSION_var-som-mx6-ornl = "-mx6"

SRCBRANCH_var-som-mx6-ornl = "feature/iris2"
SRCREV_var-som-mx6-ornl = "8be2b9f63a54d7d89f17c983e6ca5f55daacd166"
KERNEL_SRC_var-som-mx6-ornl ?= "git://github.com/uvdl/linux-imx.git;protocol=git"

SRC_URI_append_var-som-mx6-ornl = " \
									${KERNEL_SRC};branch=${SRCBRANCH} \
									file://ornl_defconfig \
									"

KERNEL_DEFCONFIG_var-som-mx6-ornl = "${WORKDIR}/ornl_defconfig"

COMPATIBLE_MACHINE_var-som-mx6-ornl = "var-som-mx6-ornl"