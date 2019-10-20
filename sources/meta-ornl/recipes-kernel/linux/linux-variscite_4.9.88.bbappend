FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${MACHINE}:"

LOCALVERSION_var-som-mx6-ornl = "-mx6"

SRCBRANCH_var-som-mx6-ornl = "feature/low-power"
SRCREV_var-som-mx6-ornl = "e45746bda1f2d42a2e30f24e8c3e1a0ff0824691"

KERNEL_SRC_var-som-mx6-ornl ?= "git://github.com/uvdl/linux-imx.git;protocol=git"

SRC_URI_append_var-som-mx6-ornl = " \
									${KERNEL_SRC};branch=${SRCBRANCH} \
									file://ornl_defconfig \
									"

KERNEL_DEFCONFIG_var-som-mx6-ornl = "${WORKDIR}/ornl_defconfig"

COMPATIBLE_MACHINE_var-som-mx6-ornl = "var-som-mx6-ornl"
